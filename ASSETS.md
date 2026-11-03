# Slate for iPhone: asset catalog (v0.1, 11/3/2026)

The PNGs aren't kept in the project (it holds text only). icon-1024.png is icon 124 since 11/3 (slate/icons/icon124.html: the thin
now line on the L's left edge, stopping 12 above it; rendered at 1024 by icon.js, saved as RGB with no alpha channel, which App
Store Connect requires; it was icon 85 before). launch-logo@2x.png and @3x.png are the R2 lockup
(the L flush with the cap, gold from the cap down fading to cream at the foot), rendered with a transparent background by
slate/app/launchlogo.html and launchlogo.js (about 233 points wide). The Contents.json files:

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
