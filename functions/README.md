# Cloud Functions for FixRight

This folder contains Firebase Cloud Functions that:

- Translate incoming messages (using Google Cloud Translation API)
- Call configured AI providers (OpenAI, Claude, Gemini, DeepSeek, or custom) to generate assistant replies
- Send FCM notifications to recipients

## Configuration

### Step 1: Enable Google Cloud Translation API (optional, for translation)

1. Go to Google Cloud Console: https://console.cloud.google.com
2. Select your Firebase project
3. Enable "Cloud Translation API"
4. Set environment variable (or use `firebase functions:config:set`):

```bash
firebase functions:config:set translate.project_id="YOUR_GCLOUD_PROJECT_ID"
```

### Step 2: Configure AI Providers via Admin CLI

The included `admin.js` script allows you to configure AI providers in Firestore.

First, download your Firebase service account key:
1. Go to Firebase Console > Project Settings > Service Accounts
2. Click "Generate New Private Key" and save it as `serviceAccountKey.json` in the `functions/` folder

Then, run the admin CLI:

```bash
cd functions
npm install
node admin.js add --type <provider-type> --name "<display-name>" --endpoint "<api-url>" --key "<api-key>" [--model "<model-id>"]
```

### Supported Providers & Examples

#### OpenAI (GPT-4, GPT-3.5)
```bash
node admin.js add \
  --type openai \
  --name "GPT-4" \
  --endpoint "https://api.openai.com/v1/chat/completions" \
  --key "sk-..." \
  --model "gpt-4"
```

#### Anthropic Claude
```bash
node admin.js add \
  --type claude \
  --name "Claude Opus" \
  --endpoint "https://api.anthropic.com/v1/messages" \
  --key "sk-ant-..." \
  --model "claude-3-opus-20240229"
```

#### Google Gemini
```bash
node admin.js add \
  --type gemini \
  --name "Gemini Pro" \
  --endpoint "https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent" \
  --key "AIzaSy..." \
  --model "gemini-pro"
```

#### DeepSeek
```bash
node admin.js add \
  --type deepseek \
  --name "DeepSeek Chat" \
  --endpoint "https://api.deepseek.com/chat/completions" \
  --key "sk-..." \
  --model "deepseek-chat"
```

#### Custom Provider (any OpenAI-compatible endpoint)
```bash
node admin.js add \
  --type custom \
  --name "My Custom LLM" \
  --endpoint "https://my-llm-server.com/v1/chat" \
  --key "custom-key-here"
```

### Admin CLI Commands

```bash
# List all configured providers
node admin.js list

# Enable/Disable a provider
node admin.js enable --id <provider-id>
node admin.js disable --id <provider-id>

# Delete a provider
node admin.js delete --id <provider-id>

# Set default provider (used when multiple are enabled)
node admin.js set-default --id <provider-id>

# Help
node admin.js help
```

## Deployment

### Deploy Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### Verify Deployment

Check the Firebase Console > Functions to see deployed functions and logs.

## Security Notes

- **API Keys**: Keep API keys secret; do not commit `serviceAccountKey.json` to source control.
- **Firestore Security Rules**: Restrict access to `admin/config` collection to authenticated admins only.
- **Rate Limiting**: Consider adding rate limits to Cloud Functions to control costs.
- **Encryption**: For production, consider encrypting API keys in Firestore (requires additional setup).

## Firestore Structure

Providers are stored in Firestore at:

```
admin/
  config/ (document)
    providers/ (subcollection)
      {provider-id}/ (document)
        type: "openai" | "claude" | "gemini" | "deepseek" | "custom"
        name: "Display Name"
        apiEndpoint: "https://..."
        apiKey: "secret-key"
        model: "model-id" (optional)
        enabled: true
        settings: {...}
        createdAt: timestamp
        updatedAt: timestamp
```

## Advanced Customization

Edit `index.js` to:
- Change the default prompt template
- Add more provider types (call new `call<Provider>()` functions)
- Add fallback logic if no AI provider is configured
- Customize assistant response filtering/validation

## Troubleshooting

- **"No AI providers configured"**: Use `admin.js list` to verify providers are added and enabled.
- **API errors**: Check Cloud Functions logs in Firebase Console. Ensure API endpoint and key are correct.
- **Translation not working**: Verify `translate.project_id` is set and Google Cloud Translation API is enabled.

