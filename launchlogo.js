/* renders the launch-screen logo at @2x and @3x (233 points wide) with a transparent background: node launchlogo.js <outdir>
   (serve this folder on port 8880 first) */
const { chromium } = require('playwright');
(async () => {
  const out = process.argv[2] || '.';
  const browser = await chromium.launch();
  for (const scale of [2, 3]){
    const page = await browser.newPage({ viewport: { width: 400, height: 200 }, deviceScaleFactor: scale });
    await page.goto('http://127.0.0.1:8880/launchlogo.html'); await page.waitForFunction(() => document.body.dataset.ready === '1');
    await page.waitForTimeout(300);
    await (await page.$('#l svg')).screenshot({ path: out + '/launch-logo@' + scale + 'x.png', omitBackground: true });
    console.log(scale, await page.evaluate(() => [document.body.dataset.w, document.body.dataset.h]));
    await page.close();
  }
  await browser.close();
})();
