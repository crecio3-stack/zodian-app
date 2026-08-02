# Pexels Portrait Intake

Use this folder as the source drop location for licensed portrait references before they are exported into `Assets.xcassets`.

## Recommended Workflow

1. Download approved portrait files from Pexels.
2. Keep the original download URL and creator attribution notes together in this folder.
3. Export final app-ready crops into `Zodian/Assets.xcassets/<name>.imageset/`.
4. Update `ConnectPortraitCatalog` after new assets are added.

## Suggested Naming

- Original files:
  - `pexels-<creator-or-id>-original.jpg`
  - `pexels-<creator-or-id>-notes.md`
- Final asset names in Xcode:
  - `pexelsFeminine01`
  - `pexelsFeminine02`
  - `pexelsMasculine01`

## Crop Guidance For Connect

- Portrait-oriented image
- Keep face and upper torso readable in the top card hero image
- Favor centered or slightly top-weighted compositions
- Avoid text overlays, watermarks, or overly busy backgrounds

## Product Caution

These are licensed stock portraits, not real in-app users. Keep product framing honest and avoid implying these are live nearby people.
