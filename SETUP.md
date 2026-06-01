# 🤖 JARVIS App — Server & App Setup Guide

## Overview

The JARVIS iOS/macOS app connects to any **OpenAI-compatible API gateway** on your homelab. This guide covers everything you need to do on both the **server** and the **app** to get it working.

---

## 📡 Server-Side Setup

### 1. Your gateway must expose an OpenAI-compatible API

The JARVIS app calls these endpoints:

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/chat/completions` | POST | Send messages, receive responses |
| `/v1/models` | GET | Test connection & list available models |

Most self-hosted AI gateways already support this out of the box:

- **LiteLLM** ✅ — Proxy for any LLM (OpenAI, Anthropic, Ollama, etc.)
- **Ollama** ✅ — Has OpenAI-compatible mode
- **Open WebUI** ✅ — Built-in API
- **LocalAI** ✅ — OpenAI drop-in replacement
- **vLLM** ✅ — Native OpenAI API
- **Text Generation WebUI (oobabooga)** ✅ — With `--api` flag

### 2. Bind to `0.0.0.0` (not just `localhost`)

⚠️ **This is the most common issue.** If your gateway only binds to `localhost` or `127.0.0.1`, your phone won't be able to reach it.

**Check:** From another device on your network, try:
```bash
curl http://<YOUR_SERVER_IP>:<PORT>/v1/models
```

If it times out, your server is only listening on localhost. Fix it:

#### LiteLLM
```bash
litellm --host 0.0.0.0 --port 4000
```

#### Ollama
```bash
# Set environment variable before starting
OLLAMA_HOST=0.0.0.0 ollama serve
```

Or in your systemd service file:
```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
```

#### Open WebUI
Already binds to `0.0.0.0` by default on port `8080`.

#### LocalAI
```bash
local-ai --address 0.0.0.0:8080
```

#### Docker (any gateway)
Make sure you're mapping the port:
```bash
docker run -p 4000:4000 ...
```

### 3. Firewall rules

Make sure your server's firewall allows incoming connections on the gateway port:

```bash
# Ubuntu/Debian (ufw)
sudo ufw allow 4000/tcp

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-port=4000/tcp
sudo firewall-cmd --reload

# Check if port is open
sudo ss -tlnp | grep 4000
```

### 4. CORS (only if you get CORS errors)

Most gateways don't need CORS configuration for native app connections. But if you're running behind a reverse proxy (like Nginx/Caddy), make sure it doesn't strip or block requests from non-browser clients.

### 5. Authentication (optional but recommended)

If your gateway supports API keys, set one up:

#### LiteLLM
```bash
litellm --host 0.0.0.0 --port 4000 --master_key sk-your-secret-key
```

#### Ollama
Ollama doesn't have built-in auth. If you need it, put it behind a reverse proxy with basic auth.

### 6. Verify your server is working

From any device on your network, test:

```bash
# Test connection
curl http://<SERVER_IP>:<PORT>/v1/models

# Test chat (replace model name with what you have)
curl http://<SERVER_IP>:<PORT>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "gpt-4o",
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

You should get a JSON response with the AI's reply. If this works, the JARVIS app will work too.

---

## 📱 App-Side Setup

### 1. Build & Run

Open `JARVIS.xcodeproj` in Xcode, select your device/simulator, and hit Run (⌘R).

### 2. Configure the connection

1. Open the app
2. Go to the **Settings** tab (gear icon)
3. Fill in:

| Field | Example | Description |
|-------|---------|-------------|
| **Base URL** | `http://192.168.1.100:4000` | Your server's IP + port. **No trailing slash.** |
| **API Key** | `sk-your-secret-key` | Leave empty if your gateway has no auth |
| **Model** | `gpt-4o` | The model name your gateway recognizes |

4. Tap **Test** — you should see "✅ Connected!" with available models
5. Tap **Save**

### 3. Start chatting

Go back to the **Chat** tab and talk to JARVIS! The AI will respond with text, and when appropriate, will include visual UI blueprints that render as beautiful cards/dashboards.

### 4. Try these prompts to test blueprints

```
"Show me the server status"
"What's the weather like?"
"Show me a dashboard with CPU, memory, and disk usage"
"List my services and their status"
```

The AI has been instructed (via system prompt) to include JSON blueprints when the answer benefits from visual display.

---

## 🔍 Troubleshooting

### "Cannot connect — is the server running?"
- **Check the URL** — make sure it's `http://IP:PORT` (not `https` unless you have TLS)
- **Check the port** — your server might be on a different port
- **Server bound to localhost?** — Rebind to `0.0.0.0` (see step 2 above)
- **Firewall blocking?** — Open the port (see step 3 above)
- **Same network?** — Your phone must be on the same WiFi as your server

### "Connected but unauthorized"
- Your server requires an API key — add it in Settings

### "Server error (HTTP 404)"
- Your gateway might not be at `/v1/chat/completions` — check what endpoints it exposes
- Some gateways use `/api/chat` or `/chat/completions` instead

### "Server error (HTTP 500)"
- The model name might be wrong — check available models with `curl http://IP:PORT/v1/models`
- The server might be overloaded or the model isn't loaded

### App crashes on launch
- Do **Product → Clean Build Folder** (⇧⌘K) in Xcode and rebuild

### No blueprints appearing (just text responses)
- The AI needs to be smart enough to follow the system prompt instructions
- Larger models (GPT-4, Claude 3, Llama 3 70B+) work best for generating blueprints
- Smaller models may ignore the blueprint instructions
- Try explicitly asking: "Show me a dashboard with server stats as a blueprint"

### HTTP not working (macOS)
- The app has `NSAllowsLocalNetworking` enabled for HTTP on local networks
- If your server is remote (not local network), you need HTTPS or change `NSAllowsArbitraryLoads` to `true` in `Info.plist`

---

## 🏗️ Architecture Summary

```
┌─────────────┐         HTTP POST          ┌──────────────────┐
│  JARVIS App  │ ──────────────────────────▶ │  Your AI Gateway  │
│  (iPhone/Mac)│ /v1/chat/completions       │  (LiteLLM/Ollama) │
│              │ ◀────────────────────────── │                    │
│  Renders UI  │   JSON response with       │  Routes to LLM     │
│  from JSON   │   text + blueprint         │  (GPT/Claude/etc)  │
└─────────────┘                             └──────────────────┘
```

The app sends messages to your gateway using the standard OpenAI chat format. The system prompt instructs the AI to include JSON "blueprints" in responses. The app parses these blueprints and renders them as beautiful SwiftUI interfaces.

---

## 🔑 Quick Checklist

- [ ] Server gateway is running and bound to `0.0.0.0`
- [ ] Firewall allows the port
- [ ] `curl http://SERVER:PORT/v1/models` works from another device
- [ ] `curl http://SERVER:PORT/v1/chat/completions` returns an AI response
- [ ] App Settings → Base URL is set to `http://SERVER:PORT`
- [ ] App Settings → API Key is set (if required)
- [ ] App Settings → Model is set to a valid model name
- [ ] App Settings → Test shows "✅ Connected!"
- [ ] Chat tab → messages get real AI responses

