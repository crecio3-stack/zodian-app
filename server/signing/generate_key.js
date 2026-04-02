// filepath: /Users/christianrecio/zodian/server/signing/generate_key.js
// Simple utility to generate a hex HMAC secret for clients
const crypto = require('crypto');
const secret = crypto.randomBytes(32).toString('hex');
console.log('SHARED_SECRET=' + secret);
