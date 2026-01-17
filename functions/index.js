const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {TranslationServiceClient} = require('@google-cloud/translate');
const fetch = require('node-fetch');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Use Google Cloud Translation API if configured, else fallback to disabled
const GCLOUD_PROJECT_ID = process.env.GCLOUD_PROJECT_ID || functions.config().translate?.project_id || null;

const translateClient = new TranslationServiceClient();

// Helper: detect language and translate text to targetLang
async function translateIfNeeded(text, targetLang) {
  if (!GCLOUD_PROJECT_ID) return {originalLanguage: null, translatedText: null};
  try {
    // Detect language
    const [detected] = await translateClient.detectLanguage({
      parent: `projects/${GCLOUD_PROJECT_ID}/locations/global`,
      content: text,
    });
    const originalLanguage = detected.languages && detected.languages[0] ? detected.languages[0].languageCode : null;

    if (!originalLanguage) return {originalLanguage: null, translatedText: null};

    if (targetLang && targetLang !== originalLanguage) {
      const [translation] = await translateClient.translateText({
        parent: `projects/${GCLOUD_PROJECT_ID}/locations/global`,
        contents: [text],
        mimeType: 'text/plain',
        targetLanguageCode: targetLang,
      });
      const translatedText = translation.translations && translation.translations[0] ? translation.translations[0].translatedText : null;
      return {originalLanguage, translatedText};
    }

    return {originalLanguage, translatedText: null};
  } catch (e) {
    console.error('Translate error', e);
    return {originalLanguage: null, translatedText: null};
  }
}

// Helper: call AI provider (reads configured provider from Firestore)
async function callAI(prompt, language) {
  try {
    // Fetch enabled providers from Firestore
    const providersSnap = await db
      .collection('admin')
      .doc('config')
      .collection('providers')
      .where('enabled', '==', true)
      .limit(1)
      .get();

    if (providersSnap.empty) {
      console.log('No AI providers configured');
      return null;
    }

    const providerDoc = providersSnap.docs[0];
    const provider = providerDoc.data();

    const {type, apiEndpoint, apiKey, model} = provider;

    if (!apiEndpoint || !apiKey) {
      console.error('Provider config incomplete');
      return null;
    }

    // Route to provider-specific handler
    let reply = null;
    switch (type) {
      case 'openai':
        reply = await callOpenAI(apiEndpoint, apiKey, model, prompt);
        break;
      case 'claude':
        reply = await callClaude(apiEndpoint, apiKey, model, prompt);
        break;
      case 'gemini':
        reply = await callGemini(apiEndpoint, apiKey, model, prompt);
        break;
      case 'deepseek':
        reply = await callDeepSeek(apiEndpoint, apiKey, model, prompt);
        break;
      case 'custom':
        reply = await callCustom(apiEndpoint, apiKey, prompt);
        break;
      default:
        console.error('Unknown provider type:', type);
    }

    return reply;
  } catch (e) {
    console.error('callAI error', e);
    return null;
  }
}

// OpenAI API handler
async function callOpenAI(endpoint, key, model, prompt) {
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${key}`,
      },
      body: JSON.stringify({
        model: model || 'gpt-3.5-turbo',
        messages: [{role: 'user', content: prompt}],
        temperature: 0.7,
        max_tokens: 150,
      }),
    });
    if (!res.ok) throw new Error(`OpenAI error: ${res.status}`);
    const data = await res.json();
    return data.choices?.[0]?.message?.content || null;
  } catch (e) {
    console.error('OpenAI call error:', e);
    return null;
  }
}

// Anthropic Claude API handler
async function callClaude(endpoint, key, model, prompt) {
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': key,
        'anthropic-version': '2023-06-01',
      },
      body: JSON.stringify({
        model: model || 'claude-3-sonnet-20240229',
        max_tokens: 150,
        messages: [{role: 'user', content: prompt}],
      }),
    });
    if (!res.ok) throw new Error(`Claude error: ${res.status}`);
    const data = await res.json();
    return data.content?.[0]?.text || null;
  } catch (e) {
    console.error('Claude call error:', e);
    return null;
  }
}

// Google Gemini API handler
async function callGemini(endpoint, key, model, prompt) {
  try {
    // Gemini endpoint format: https://generativelanguage.googleapis.com/v1beta/models/...
    const url = `${endpoint.replace('{model}', model || 'gemini-pro')}?key=${key}`;
    const res = await fetch(url, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({
        contents: [{parts: [{text: prompt}]}],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 150,
        },
      }),
    });
    if (!res.ok) throw new Error(`Gemini error: ${res.status}`);
    const data = await res.json();
    return data.candidates?.[0]?.content?.parts?.[0]?.text || null;
  } catch (e) {
    console.error('Gemini call error:', e);
    return null;
  }
}

// DeepSeek API handler (OpenAI-compatible)
async function callDeepSeek(endpoint, key, model, prompt) {
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${key}`,
      },
      body: JSON.stringify({
        model: model || 'deepseek-chat',
        messages: [{role: 'user', content: prompt}],
        temperature: 0.7,
        max_tokens: 150,
      }),
    });
    if (!res.ok) throw new Error(`DeepSeek error: ${res.status}`);
    const data = await res.json();
    return data.choices?.[0]?.message?.content || null;
  } catch (e) {
    console.error('DeepSeek call error:', e);
    return null;
  }
}

// Custom provider (generic JSON endpoint)
async function callCustom(endpoint, key, prompt) {
  try {
    const res = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${key}`,
      },
      body: JSON.stringify({prompt}),
    });
    if (!res.ok) throw new Error(`Custom provider error: ${res.status}`);
    const data = await res.json();
    return data.reply || data.text || data.result || null;
  } catch (e) {
    console.error('Custom provider call error:', e);
    return null;
  }
}

// Helper: send FCM notification if token is available
async function sendNotification(toUid, payload) {
  try {
    const userDoc = await db.collection('users').doc(toUid).get();
    if (!userDoc.exists) return;
    const data = userDoc.data() || {};
    const token = data.fcmToken;
    if (!token) return;

    await messaging.send({
      token: token,
      notification: {
        title: payload.title || 'New message',
        body: payload.body || '',
      },
      data: payload.data || {},
    });
  } catch (e) {
    console.error('sendNotification error', e);
  }
}

// Decide whether assistant should respond
function shouldCallAssistant(text) {
  if (!text) return false;
  const t = text.toLowerCase();
  // Simple heuristics: questions, help keywords, 'assistant' trigger
  if (t.includes('assistant') || t.includes('help') || t.endsWith('?')) return true;
  return false;
}

exports.onMessageCreate = functions.firestore
  .document('chats/{chatId}/messages/{msgId}')
  .onCreate(async (snap, ctx) => {
    const message = snap.data();
    if (!message) return null;

    // Skip bot messages
    if (message.senderRole && message.senderRole.toLowerCase() === 'bot') return null;

    const chatId = ctx.params.chatId;
    const msgId = ctx.params.msgId;

    const receiverId = message.receiverId;
    const senderId = message.senderId;
    const text = message.originalText || '';

    // Get receiver preferred language
    let receiverLang = 'en';
    try {
      const rdoc = await db.collection('users').doc(receiverId).get();
      if (rdoc.exists) {
        const rdata = rdoc.data() || {};
        receiverLang = rdata.settings?.language || rdata.language || 'en';
      }
    } catch (e) {
      console.error('error reading receiver', e);
    }

    // Translate if needed
    const {originalLanguage, translatedText} = await translateIfNeeded(text, receiverLang);

    // Update message doc with detected language and translated text
    const updates = {};
    if (originalLanguage) updates.originalLanguage = originalLanguage;
    if (translatedText) {
      updates.translatedText = translatedText;
      updates.translatedLanguage = receiverLang;
    }
    if (Object.keys(updates).length > 0) {
      await snap.ref.set(updates, {merge: true});
    }

    // Send notification to receiver
    await sendNotification(receiverId, {title: 'New message', body: text, data: {chatId, msgId}});

    // Optionally call AI assistant
    if (shouldCallAssistant(text)) {
      // Build prompt for assistant: include last few messages if needed (omitted for brevity)
      const prompt = `User message: ${text}\nPlease provide a professional assistant reply.`;
      let assistantReply = null;
      assistantReply = await callAI(prompt, receiverLang);

      // If no external AI, provide a simple fallback reply
      if (!assistantReply) {
        assistantReply = `Hello! The assistant noticed your question and recommends checking the details with the seller. If you want, ask for order details or schedule a call.`;
      }

      // Optionally translate assistant reply to receiver language if needed (we assume assistantReply in receiverLang)
      const botMsgRef = db.collection('chats').doc(chatId).collection('messages').doc();
      await botMsgRef.set({
        messageId: botMsgRef.id,
        senderId: 'assistant',
        receiverId: receiverId,
        senderRole: 'Bot',
        originalText: assistantReply,
        originalLanguage: receiverLang,
        translatedText: null,
        translatedLanguage: null,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: 'sent',
      });

      // Notify the receiver about assistant reply
      await sendNotification(receiverId, {title: 'Assistant', body: assistantReply, data: {chatId, msgId: botMsgRef.id}});
    }

    return null;
  });
