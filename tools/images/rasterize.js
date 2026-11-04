// Exporte assets/ui/svg/*.svg en PNG 256 × 256 à fond transparent (assets/ui/png), avec Chromium.
// Usage : node tools/images/rasterize.js
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

(async () => {
  const root = path.resolve(__dirname, '..', '..');
  const svgDir = path.join(root, 'assets', 'ui', 'svg');
  const pngDir = path.join(root, 'assets', 'ui', 'png');
  fs.mkdirSync(pngDir, { recursive: true });
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 256, height: 256 }, deviceScaleFactor: 1 });
  for (const file of fs.readdirSync(svgDir).filter((f) => f.endsWith('.svg'))) {
    const svg = fs.readFileSync(path.join(svgDir, file), 'utf8');
    await page.setContent(`<html><body style="margin:0;background:transparent">${svg}</body></html>`);
    await page.screenshot({ path: path.join(pngDir, file.replace('.svg', '.png')), omitBackground: true,
      clip: { x: 0, y: 0, width: 256, height: 256 } });
  }
  await browser.close();
})();
