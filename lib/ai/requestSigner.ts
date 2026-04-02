// filepath: /Users/christianrecio/zodian/lib/ai/requestSigner.ts
// Client-side request signer for Zodian's AI proxy.
// Exports an async function that returns headers to attach to the request.

export async function signRequest(body: any, secret?: string): Promise<Record<string,string>> {
  if (!secret) {
    throw new Error('signRequest: no secret provided. For mobile apps, keep the shared secret on a secure server or use a per-user signing flow.');
  }

  const ts = Math.floor(Date.now() / 1000).toString();
  const payload = `${ts}.${typeof body === 'string' ? body : JSON.stringify(body)}`;

  // Prefer Node-style crypto when available (server-side testing)
  try {
    // @ts-ignore
    if (typeof require === 'function') {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const crypto = require('crypto');
      const sig = crypto.createHmac('sha256', secret).update(payload).digest('hex');
      return {
        'x-zodian-ts': ts,
        'x-zodian-signature': sig,
      };
    }
  } catch (e) {
    // fallthrough to Web Crypto
  }

  // Browser / React Native (Web Crypto) - async
  if (typeof (globalThis as any).crypto !== 'undefined' && (globalThis as any).crypto.subtle) {
    const enc = new TextEncoder();
    const keyData = enc.encode(secret);
    const key = await (globalThis as any).crypto.subtle.importKey('raw', keyData, { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
    const sigBuf = await (globalThis as any).crypto.subtle.sign('HMAC', key, enc.encode(payload));
    const arr = Array.from(new Uint8Array(sigBuf));
    const hex = arr.map(b => b.toString(16).padStart(2, '0')).join('');
    return {
      'x-zodian-ts': ts,
      'x-zodian-signature': hex,
    };
  }

  throw new Error('No supported crypto available. For React Native, install expo-crypto or crypto-js and implement an HMAC SHA256 helper.');
}

/* Example usage (Node):
const body = { westernSign: 'Aries', chineseSign: 'Dragon', dateISO: '2026-04-01', weekday: 'Thursday' };
const headers = await signRequest(body, process.env.SHARED_SECRET);
const res = await fetch('http://localhost:3001/generate-daily-ritual', { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(body) });
*/
