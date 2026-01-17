/**
 * Admin Server for FixRight
 * Serves the admin UI and manages AI provider configuration
 * 
 * Usage:
 *   node admin-server.js
 * 
 * Then open: http://localhost:5000
 */

const express = require('express');
const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, '../admin')));

// Initialize Firebase Admin
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || './serviceAccountKey.json';
if (!fs.existsSync(serviceAccountPath)) {
  console.error(`\n❌ Service account key not found at ${serviceAccountPath}`);
  console.error('📥 Download it from: Firebase Console > Project Settings > Service Accounts > Generate new private key\n');
  process.exit(1);
}

const serviceAccount = require(path.resolve(serviceAccountPath));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// API Routes

// GET all providers
app.get('/api/providers', async (req, res) => {
  try {
    const snap = await db.collection('admin').doc('config').collection('providers').get();
    const providers = snap.docs.map(doc => ({id: doc.id, ...doc.data()}));
    res.json(providers);
  } catch (e) {
    console.error('Error fetching providers:', e);
    res.status(500).json({error: 'Failed to fetch providers'});
  }
});

// GET single provider
app.get('/api/providers/:id', async (req, res) => {
  try {
    const doc = await db.collection('admin').doc('config').collection('providers').doc(req.params.id).get();
    if (!doc.exists) return res.status(404).json({error: 'Provider not found'});
    res.json({id: doc.id, ...doc.data()});
  } catch (e) {
    res.status(500).json({error: 'Failed to fetch provider'});
  }
});

// POST create provider
app.post('/api/providers', async (req, res) => {
  try {
    const {type, name, apiEndpoint, apiKey, model} = req.body;

    if (!type || !name || !apiEndpoint || !apiKey) {
      return res.status(400).json({error: 'Missing required fields'});
    }

    const id = `${type}-${Date.now()}`;
    await db.collection('admin').doc('config').collection('providers').doc(id).set({
      type,
      name,
      apiEndpoint,
      apiKey, // TODO: Encrypt in production
      model: model || null,
      enabled: true,
      settings: {},
      createdAt: admin.firestore.Timestamp.now(),
      updatedAt: admin.firestore.Timestamp.now(),
    });

    res.json({id, type, name, apiEndpoint, model, enabled: true});
  } catch (e) {
    console.error('Error creating provider:', e);
    res.status(500).json({error: 'Failed to create provider'});
  }
});

// PATCH update provider
app.patch('/api/providers/:id', async (req, res) => {
  try {
    const {name, apiEndpoint, apiKey, model, enabled} = req.body;
    const updates = {updatedAt: admin.firestore.Timestamp.now()};

    if (name) updates.name = name;
    if (apiEndpoint) updates.apiEndpoint = apiEndpoint;
    if (apiKey) updates.apiKey = apiKey;
    if (model) updates.model = model;
    if (typeof enabled === 'boolean') updates.enabled = enabled;

    await db.collection('admin').doc('config').collection('providers').doc(req.params.id).update(updates);
    res.json({id: req.params.id, ...updates});
  } catch (e) {
    res.status(500).json({error: 'Failed to update provider'});
  }
});

// DELETE provider
app.delete('/api/providers/:id', async (req, res) => {
  try {
    await db.collection('admin').doc('config').collection('providers').doc(req.params.id).delete();
    res.json({success: true});
  } catch (e) {
    res.status(500).json({error: 'Failed to delete provider'});
  }
});

// PUT set default provider
app.put('/api/config/default-provider', async (req, res) => {
  try {
    const {providerId} = req.body;
    await db.collection('admin').doc('config').set({defaultProvider: providerId}, {merge: true});
    res.json({defaultProvider: providerId});
  } catch (e) {
    res.status(500).json({error: 'Failed to set default provider'});
  }
});

// GET config
app.get('/api/config', async (req, res) => {
  try {
    const doc = await db.collection('admin').doc('config').get();
    res.json(doc.data() || {});
  } catch (e) {
    res.status(500).json({error: 'Failed to fetch config'});
  }
});

// Serve admin UI
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../admin/index.html'));
});

app.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════╗
║  ✅ FixRight Admin Server Running      ║
║  🌐 http://localhost:${PORT}          ║
║  📋 Manage AI Providers                ║
╚════════════════════════════════════════╝
  `);
});
