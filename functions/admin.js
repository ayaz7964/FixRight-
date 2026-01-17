#!/usr/bin/env node

/**
 * Admin tool to configure AI providers in Firestore
 * Usage:
 *   node admin.js add --type openai --name "GPT-4" --endpoint "https://api.openai.com/v1/chat/completions" --key "sk-..." --model "gpt-4"
 *   node admin.js list
 *   node admin.js enable --id openai-gpt4
 *   node admin.js disable --id openai-gpt4
 *   node admin.js delete --id openai-gpt4
 */

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin (ensure you have a service account key)
const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_KEY || './serviceAccountKey.json';
if (!fs.existsSync(serviceAccountPath)) {
  console.error(`Service account key not found at ${serviceAccountPath}`);
  console.error('Download it from Firebase Console > Project Settings > Service Accounts > Generate new private key');
  process.exit(1);
}

const serviceAccount = require(path.resolve(serviceAccountPath));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Helper functions
async function addProvider({type, name, endpoint, key, model}) {
  const id = `${type}-${Date.now()}`;
  const docRef = db.collection('admin').doc('config').collection('providers').doc(id);
  await docRef.set({
    type,
    name,
    apiEndpoint: endpoint,
    apiKey: key,
    model: model || null,
    enabled: true,
    settings: {},
    createdAt: admin.firestore.Timestamp.now(),
    updatedAt: admin.firestore.Timestamp.now(),
  });
  console.log(`✓ Provider added: ${id}`);
}

async function listProviders() {
  const snap = await db.collection('admin').doc('config').collection('providers').get();
  if (snap.empty) {
    console.log('No providers configured.');
    return;
  }
  console.log('Configured AI Providers:');
  snap.forEach((doc) => {
    const data = doc.data();
    const status = data.enabled ? '✓ enabled' : '✗ disabled';
    console.log(`  ${doc.id}: [${status}] ${data.name} (${data.type}) - ${data.model || 'N/A'}`);
  });
}

async function enableProvider(id) {
  const docRef = db.collection('admin').doc('config').collection('providers').doc(id);
  await docRef.update({enabled: true, updatedAt: admin.firestore.Timestamp.now()});
  console.log(`✓ Provider enabled: ${id}`);
}

async function disableProvider(id) {
  const docRef = db.collection('admin').doc('config').collection('providers').doc(id);
  await docRef.update({enabled: false, updatedAt: admin.firestore.Timestamp.now()});
  console.log(`✓ Provider disabled: ${id}`);
}

async function deleteProvider(id) {
  await db.collection('admin').doc('config').collection('providers').doc(id).delete();
  console.log(`✓ Provider deleted: ${id}`);
}

async function setDefaultProvider(id) {
  await db.collection('admin').doc('config').set({defaultProvider: id}, {merge: true});
  console.log(`✓ Default provider set to: ${id}`);
}

// Parse command-line arguments
const [cmd, ...args] = process.argv.slice(2);
const opts = {};
for (let i = 0; i < args.length; i += 2) {
  opts[args[i].replace('--', '')] = args[i + 1];
}

async function main() {
  try {
    switch (cmd) {
      case 'add':
        await addProvider({
          type: opts.type,
          name: opts.name,
          endpoint: opts.endpoint,
          key: opts.key,
          model: opts.model,
        });
        break;
      case 'list':
        await listProviders();
        break;
      case 'enable':
        await enableProvider(opts.id);
        break;
      case 'disable':
        await disableProvider(opts.id);
        break;
      case 'delete':
        await deleteProvider(opts.id);
        break;
      case 'set-default':
        await setDefaultProvider(opts.id);
        break;
      case 'help':
      default:
        console.log(`
Admin CLI for FixRight AI Providers

Usage:
  node admin.js add --type <type> --name "<name>" --endpoint "<url>" --key "<key>" [--model "<model>"]
    Add a new AI provider

  node admin.js list
    List all configured providers

  node admin.js enable --id <providerId>
    Enable a provider

  node admin.js disable --id <providerId>
    Disable a provider

  node admin.js delete --id <providerId>
    Delete a provider

  node admin.js set-default --id <providerId>
    Set default provider

Supported types: openai, claude, gemini, deepseek, custom

Examples:
  node admin.js add --type openai --name "GPT-4" --endpoint "https://api.openai.com/v1/chat/completions" --key "sk-..." --model "gpt-4"
  node admin.js add --type claude --name "Claude Opus" --endpoint "https://api.anthropic.com/v1/messages" --key "sk-ant-..." --model "claude-3-opus-20240229"
  node admin.js add --type deepseek --name "DeepSeek" --endpoint "https://api.deepseek.com/chat/completions" --key "sk-..." --model "deepseek-chat"
  node admin.js list
        `);
    }
  } catch (e) {
    console.error('Error:', e.message);
    process.exit(1);
  }

  process.exit(0);
}

main();
