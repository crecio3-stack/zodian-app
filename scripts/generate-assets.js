#!/usr/bin/env node
/*
  generate-assets.js
  Small developer utility to generate @1x / @2x raster variants (and optional WebP) for illustration assets.

  Usage:
    node ./scripts/generate-assets.js [path/to/source.png]

  Notes:
  - This script prefers `sharp` if available. Install with: npm install --save-dev sharp
  - If sharp is not available, the script will copy the source to @1x/@2x names as a fallback.
*/

const fs = require('fs');
const path = require('path');

async function main() {
  const src = process.argv[2] || 'assets/illustrations/homeHero.png';
  const abs = path.resolve(src);

  if (!fs.existsSync(abs)) {
    console.error(`Source file not found: ${abs}`);
    process.exit(2);
  }

  const dir = path.dirname(abs);
  const ext = path.extname(abs);
  const base = path.basename(abs, ext);

  const out1 = path.join(dir, `${base}@1x.png`);
  const out2 = path.join(dir, `${base}@2x.png`);
  const out1webp = path.join(dir, `${base}@1x.webp`);
  const out2webp = path.join(dir, `${base}@2x.webp`);

  let sharp;
  try {
    sharp = require('sharp');
  } catch (e) {
    sharp = null;
  }

  if (!sharp) {
    console.warn('`sharp` not found. Falling back to file copies. For resized/export support install sharp (npm i -D sharp)');
    // copy to both outputs
    try {
      fs.copyFileSync(abs, out2);
      fs.copyFileSync(abs, out1);
      console.log('Copied source to:', out1, out2);
      process.exit(0);
    } catch (err) {
      console.error('Failed to copy files:', err);
      process.exit(3);
    }
  }

  try {
    const image = sharp(abs);
    const meta = await image.metadata();
    const width = meta.width || null;
    const height = meta.height || null;

    if (!width || !height) {
      // just copy
      fs.copyFileSync(abs, out2);
      fs.copyFileSync(abs, out1);
      console.log('Metadata missing — copied source to outputs');
      process.exit(0);
    }

    // Create @2x as the original source (re-encoded into PNG to ensure consistency)
    await image.png({ compressionLevel: 9 }).toFile(out2);

    // Create @1x by resizing to half width/height (rounded)
    const w1 = Math.max(1, Math.round(width / 2));
    const h1 = Math.max(1, Math.round(height / 2));
    await image.resize(w1, h1).png({ compressionLevel: 9 }).toFile(out1);

    // Also export WebP variants for smaller size
    await image.webp({ quality: 80 }).toFile(out2webp);
    await image.resize(w1, h1).webp({ quality: 80 }).toFile(out1webp);

    console.log('Generated assets:');
    console.log('  ', out1);
    console.log('  ', out2);
    console.log('  ', out1webp);
    console.log('  ', out2webp);
    process.exit(0);
  } catch (err) {
    console.error('Error processing images:', err);
    process.exit(4);
  }
}

main();
