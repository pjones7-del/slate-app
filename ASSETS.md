# Slate for iPhone: asset catalog (v0.1, 11/3/2026; launch logo 11/8)

The PNGs aren't kept in the project (it holds text only). icon-1024.png is icon 127 since 11/3 (slate/icons/icon127.html: the thin
now line on the L's left edge, stopping 12 above it, the word at 85's height; rendered at 1024 by icon.js, saved as RGB with no
alpha channel, which App Store Connect requires; before it, 124 for an hour and 85). launch-logo@2x.png and @3x.png are the board's title
lockup since 11/8: SLATE with a plain L and one thin gold line down its left edge, cap to baseline (the stem's left .36, icon 127's
proportion), rendered with a transparent background by launchlogo.html and launchlogo.js in this repo, 233 points wide (466x146 and
699x219), the size the board's opening animation starts at. Before it, the R2 lockup (gold from the cap down fading to cream). The Contents.json files:

`Slate/Assets.xcassets/AppIcon.appiconset/Contents.json`

```json
{
  "images" : [
    { "filename" : "icon-1024.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

`Slate/Assets.xcassets/Contents.json`

```json
{
  "info" : { "author" : "xcode", "version" : 1 }
}
```

`Slate/Assets.xcassets/LaunchBackground.colorset/Contents.json`

```json
{
  "colors" : [
    {
      "color" : { "color-space" : "srgb", "components" : { "alpha" : "1.000", "blue" : "0x22", "green" : "0x17", "red" : "0x10" } },
      "idiom" : "universal"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

`Slate/Assets.xcassets/LaunchLogo.imageset/Contents.json`

```json
{
  "images" : [
    { "idiom" : "universal", "scale" : "1x" },
    { "filename" : "launch-logo@2x.png", "idiom" : "universal", "scale" : "2x" },
    { "filename" : "launch-logo@3x.png", "idiom" : "universal", "scale" : "3x" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```
