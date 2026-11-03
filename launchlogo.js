const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium-1194/chrome-linux/chrome' });
  for (const scale of [2, 3]){
    const page = await browser.newPage({ viewport: { width: 800, height: 400 }, deviceScaleFactor: scale * 220 / 100 / 3.2 });
    await page.goto('http://127.0.0.1:8880/launchlogo.html'); await page.waitForFunction(() => document.body.dataset.ready === '1');
    await page.waitForTimeout(300);
    const el = await page.$('#l svg');
    await el.screenshot({ path: '/home/claude/slate-app/Slate/Assets.xcassets/LaunchLogo.imageset/launch-logo@' + scale + 'x.png', omitBackground: true });
    console.log(scale, await page.evaluate(() => [document.body.dataset.w, document.body.dataset.h]));
    await page.close();
  }
  await browser.close();
})();
