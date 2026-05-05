# Zodian Asset Pipeline

This file defines the minimum-quality pipeline for brand assets used in the app and store listing.

## Current Canonical Outputs

- App Store icon: `Zodian/Assets.xcassets/AppIcon.appiconset/ZodianIcon.png`
- In-app mark: `Zodian/Assets.xcassets/zodianMark.imageset/ZodianInApp.png`
- In-app mark 2x: `Zodian/Assets.xcassets/zodianMark.imageset/ZodianInApp 1.png`
- In-app mark 3x: `Zodian/Assets.xcassets/zodianMark.imageset/ZodianInApp 2.png`

These filenames should remain stable so we do not accumulate duplicate exports with generated names.

## Export Requirements

### App Icon

- Master export size: `1024x1024`
- Format: PNG
- Color profile: sRGB
- Background: fully intentional edge-to-edge artwork
- Transparency: avoid for the App Store icon
- Safe area: keep the focal mark comfortably inset so it still reads at small sizes

### In-App Mark

- Source artwork should match the App Icon family
- Export 1x, 2x, and 3x from the same master composition
- Preserve crisp edges and avoid tiny ornamental detail that disappears in headers or onboarding
- Prefer original rendering unless the asset is explicitly intended as a template

## Quality Checklist

Before replacing icon or logo assets:

- Verify the design still reads at `60x60`, `40x40`, and `29x29`
- Check contrast on both dark surfaces and warm accent surfaces used in-app
- Avoid fuzzy glow edges that turn muddy once scaled down
- Confirm there is one visual focal point, not multiple competing symbols
- Compare the App Icon and in-app mark side by side to make sure they feel like one brand system

## Catalog Hygiene Rules

- Do not keep throwaway export names inside `Assets.xcassets`
- Replace asset files with the canonical names above instead of adding numbered duplicates
- If a new logo direction is being explored, keep source exploration files outside the asset catalog
- Only the final selected exports should live in `AppIcon.appiconset` and `zodianMark.imageset`

## Suggested Workflow

1. Design from a single square master.
2. Export the App Icon at `1024x1024`.
3. Export the in-app mark at 1x, 2x, and 3x from the same artwork family.
4. Replace the canonical files in the asset catalog.
5. Recheck onboarding, Home, and any header surfaces where `zodianMark` appears.
6. Recheck the App Icon in Xcode's asset preview before shipping.
