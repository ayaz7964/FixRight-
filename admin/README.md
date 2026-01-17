# FixRight Admin Panel

Simple web UI for managing AI provider configurations.

## Setup

### 1. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** > **Service Accounts** tab
4. Click **Generate New Private Key**
5. Save the JSON file as `serviceAccountKey.json` in this folder (`admin/`)

### 2. Install Dependencies

```bash
npm install
```

### 3. Run the Server

```bash
npm start
```

Then open: **http://localhost:5000**

## Features

### Add AI Provider
- Select provider type (OpenAI, Claude, Gemini, DeepSeek, Custom)
- Fill in API endpoint and key
- Specify model ID
- Click Save

### Manage Providers
- View all configured providers
- Edit provider details
- Enable/disable providers
- Set default provider
- Delete providers

## Supported Providers

| Provider | Endpoint | Model Examples |
|----------|----------|------------------|
| **OpenAI** | https://api.openai.com/v1/chat/completions | gpt-4, gpt-3.5-turbo |
| **Claude** | https://api.anthropic.com/v1/messages | claude-3-opus-20240229 |
| **Gemini** | https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent | gemini-pro |
| **DeepSeek** | https://api.deepseek.com/chat/completions | deepseek-chat |
| **Custom** | Your endpoint | Your model |

## API Endpoints

### Providers

```
GET    /api/providers              # List all
GET    /api/providers/:id          # Get one
POST   /api/providers              # Create
PATCH  /api/providers/:id          # Update
DELETE /api/providers/:id          # Delete
```

### Config

```
GET  /api/config                      # Get config
PUT  /api/config/default-provider     # Set default
```

## Environment Variables

```bash
PORT=5000                              # Server port
FIREBASE_SERVICE_ACCOUNT_KEY=./serviceAccountKey.json
```

## Security Notes

- **Keep `serviceAccountKey.json` secret** - add to `.gitignore`
- Restrict admin access in your deployment
- In production, authenticate admins before allowing access
- Consider encrypting API keys in Firestore

## Development

With nodemon installed:

```bash
npm run dev
```

This will auto-restart the server on file changes.

## Deployment

Deploy to Firebase Hosting or your own server:

```bash
# Firebase Hosting
firebase deploy --only hosting:admin

# Or any Node.js host (Heroku, AWS, etc.)
npm start
```
