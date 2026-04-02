# Zodian AI Proxy (with request signing)

This example server shows how to protect an OpenAI proxy with a simple HMAC signature scheme.

Environment
- OPENAI_API_KEY - server-side OpenAI secret
- SHARED_SECRET - hex secret shared with trusted clients
- SIGN_TTL_SEC - allowed timestamp window in seconds (default 300)

Signature scheme (client):
- ts = Math.floor(Date.now()/1000).toString()
- payload = ts + '.' + JSON.stringify(body)
- signature = HMAC_SHA256(secret, payload) as hex
- Headers: x-zodian-ts: ts, x-zodian-signature: signature

Server verifies timestamp and performs timingSafeEqual check.

Dev utilities:
- node signing/generate_key.js => prints a SHARED_SECRET to use in env

Security notes:
- This is a simple scheme designed for mobile-to-server authenticity. Do NOT consider it a replacement for a full auth system.
- In production, use per-user keys, rotate secrets, rate-limit, and require authenticated requests.
