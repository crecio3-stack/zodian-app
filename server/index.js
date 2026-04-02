// filepath: /Users/christianrecio/zodian/server/index.js
// Express proxy with request-signature verification.
require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');
const bodyParser = require('body-parser');
const crypto = require('crypto');

const OPENAI_KEY = process.env.OPENAI_API_KEY;
const SHARED_SECRET = process.env.SHARED_SECRET; // HMAC secret shared with clients
const TIMESTAMP_TTL_SEC = Number(process.env.SIGN_TTL_SEC || 300); // 5 minutes

if (!OPENAI_KEY) console.warn('OPENAI_API_KEY not  proxy will not forward to OpenAI.');set 
if (!SHARED_SECRET) console.warn('SHARED_SECRET not  server will accept unsigned requests (development only).');set 

const app = express();
app.use(bodyParser.json());

function computeHmac(secret, ts, body) {
  const payload = `${ts}.${typeof body === 'string' ? body : JSON.stringify(body)}`;
  return crypto.createHmac('sha256', secret).update(payload).digest('hex');
}

function verifySignatureMiddleware(req, res, next) {
  try {
    if (!SHARED_SECRET) return next(); // development: skip verification

    const sig = req.header('x-zodian-signature');
    const ts = req.header('x-zodian-ts');
    if (!sig || !ts) return res.status(401).json({ error: 'missing_signature' });

    const now = Math.floor(Date.now() / 1000);
    const tsNum = Number(ts);
    if (Number.isNaN(tsNum) || Math.abs(now - tsNum) > TIMESTAMP_TTL_SEC) {
      return res.status(401).json({ error: 'stale_timestamp' });
    }

    const expected = computeHmac(SHARED_SECRET, ts, req.body);

    if (!crypto.timingSafeEqual(Buffer.from(expected, 'hex'), Buffer.from(sig, 'hex'))) {
      return res.status(401).json({ error: 'invalid_signature' });
    }

    return next();
  } catch (err) {
    console.error('signature verify failed', err);
    return res.status(401).json({ error: 'signature_error' });
  }
}

app.get('/health', (req, res) => res.json({ ok: true }));

app.post('/generate-daily-ritual', verifySignatureMiddleware, async (req, res) => {
  try {
    const { westernSign, chineseSign, dateISO, weekday } = req.body;
    if (!westernSign || !chineseSign || !dateISO || !weekday) {
      return res.status(400).json({ error: 'missing params' });
    }

    if (!OPENAI_KEY) return res.status(502).json({ error: 'openai_key_missing' });

    const system = `You are Zodian's daily ritual generator. Respond with JSON matching the expected schema.`;
    const user = `Create a short daily ritual for ${westernSign} (${chineseSign}) for ${weekday} ${dateISO}`;

    const payload = {
      model: 'gpt-4o-mini',
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: user },
      ],
      temperature: 0.8,
      max_tokens: 320,
    };

    const resp = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${OPENAI_KEY}` },
      body: JSON.stringify(payload),
    });

    const data = await resp.json();
    const content = data?.choices?.[0]?.message?.content;
    if (typeof content === 'string') {
      try {
        const parsed = JSON.parse(content);
        return res.json(parsed);
      } catch (e) {
        return res.json({ raw: content });
      }
    }

    res.json(data);
  } catch (err) {
    console.error('generate error', err);
    res.status(500).json({ error: 'server_error' });
  }
});

// helper to generate one-off key for CLI / dev
app.get('/generate-test-signature', (req, res) => {
  if (!SHARED_SECRET) return res.status(400).json({ error: 'no_shared_secret' });
  const ts = Math.floor(Date.now() / 1000).toString();
  const sig = computeHmac(SHARED_SECRET, ts, { example: true });
  res.json({ ts, signature: sig });
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log('Zodian AI proxy listening on', PORT));
