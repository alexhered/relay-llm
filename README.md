# relay-llm

A small HTTP server in Swift that runs on my Mac. I send a prompt from my phone, the server forwards it to a model on OpenRouter, and sends the answer back.

## Why I built it

I code mostly from my iPhone, and my Mac stays at home. I wanted a cheap way to send prompts from my phone to different models, through one small server that I control. This way my API key stays on my Mac and not in every app on my phone.

It was also a good excuse to learn server-side Swift.

## How it works

```
iPhone  --POST /ask-->  relay-llm (Mac)  --->  OpenRouter API  --->  model
        <--{"reply"}--                   <---
```

- `GET /health` returns `ok`.
- `POST /ask` takes `{"prompt": "...", "model": "optional"}` and returns `{"reply": "..."}`.
- Every `/ask` request needs the header `X-Relay-Token`. It must match the `RELAY_TOKEN` env var, otherwise the server returns 401.
- If no model is sent, it uses `DEFAULT_MODEL` (default: `openai/gpt-4o-mini`).

Built with [Hummingbird 2](https://github.com/hummingbird-project/hummingbird).

## Setup

You need macOS 14+ and Swift 5.9+ (comes with Xcode).

1. Get an API key from [OpenRouter](https://openrouter.ai).
2. Copy the example env file and fill it in:

   ```bash
   cp .env.example .env
   ```

3. Load the variables and run:

   ```bash
   set -a; source .env; set +a
   swift run
   ```

The server listens on port 8080 by default.

## Example

```bash
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -H "X-Relay-Token: $RELAY_TOKEN" \
  -d '{"prompt": "Explain what a Swift actor is in two sentences."}'
```

With a specific model:

```bash
curl -X POST http://localhost:8080/ask \
  -H "Content-Type: application/json" \
  -H "X-Relay-Token: $RELAY_TOKEN" \
  -d '{"prompt": "Hello", "model": "anthropic/claude-3.5-haiku"}'
```

## Notes on security

The token check is very simple. It is fine for my home network, but if you open the server to the internet, put it behind HTTPS (for example with a VPN like Tailscale, or a reverse proxy). Don't expose plain HTTP with your token in it.

## What I learned

- How to set up a Swift Package executable and add a dependency.
- Routing and JSON decoding/encoding with Hummingbird.
- Calling an external API with `URLSession` and `async/await`.
- Keeping secrets in environment variables instead of the code.
- The OpenAI-style chat completions format, which OpenRouter also uses.

## Next steps

- A small iOS client app (SwiftUI) to send prompts from my phone.
- Streaming responses, so the reply shows up while the model is writing.
- Keep conversation history for follow-up questions.
- Some basic tests.
