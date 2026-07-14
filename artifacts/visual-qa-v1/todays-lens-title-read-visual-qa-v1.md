# Today’s Lens title + read Visual QA v1

**Commit audited:** `929d638 Add versioned title-read Today’s Lens UI`
**Date:** 2026-07-13
**Recommendation:** `QA_BLOCKED_BY_TOOLING` — do not clear for TestFlight from this audit.

## Build verification

- **Xcode:** 26.6 (17F113)
- **Destination:** iPhone 17 Pro, iOS 26.4, UDID `29ECF2BB-C796-4B41-B2BB-F62A3EEFD81A` (booted)
- **Command:**

  ```sh
  xcodebuild -project Zodian.xcodeproj -scheme Zodian -configuration Debug \
    -destination 'platform=iOS Simulator,id=29ECF2BB-C796-4B41-B2BB-F62A3EEFD81A' \
    -derivedDataPath /tmp/CodexTodaysLensVisualQAV1 -quiet build
  ```

- **Result:** PASS (`exit 0`)
- **Warnings:** one pre-existing deprecation warning in `Screens/Connect/MatchDetailView.swift:86` (`onChange(of:perform:)`), plus the normal ad-hoc signing note. No compiler errors.
- **Launch:** PASS. The installed `com.ianrecio.zodian` app launches on the booted simulator.

The earlier build interruption was not a compiler or destination failure: the simulator was booted and responsive. A follow-up build collided with the still-running first build’s `build.db`; the isolated Derived Data build above completed successfully.

## Visual evidence index

| File | What it actually shows | Result |
| --- | --- | --- |
| `01-initial-launch.png` | Home, control content, unrevealed hold state; dark current-Pro portrait. | Home reveal entry state visible. |
| `02-home-reduce-motion-unrevealed.png` | Launch/splash screen, despite its filename. | Not evidence of the named Home/Reduce Motion scenario. |
| `03-home-control-revealed.png` | Home, control content, revealed title/read card; dark current-Pro portrait. | One title, one flowing read, and Save/Share controls are visible; no Watch, Move, quote, or Behind the Lens section appears. |

No screenshots were fabricated for unvisited flows.

## QA result by scenario

| Scenario | Result | Evidence / limitation |
| --- | --- | --- |
| Candidate title/read on Home | FAIL | `DailyLensContentRouter` has no call site and `HomeView.dailyLensContent(for:)` always creates production-control content. Candidate content cannot reach Home. The available Home screenshots exercise control content only. |
| Candidate title/read on Full Daily | FAIL | `DailyRitualView` also always creates production-control content. Shared renderer use is present in source, but candidate runtime presentation could not be reached. |
| Production six-field fallback | FAIL | The renderer falls back only when the control title or `ritualText` is blank. Candidate availability/blocked/incomplete/disabled states do not feed this branch because the router is not consumed. |
| Loading, refresh, retry, no-content | BLOCKED | Only launch splash evidence is available. The permitted UI automation service could not connect to Simulator, so these states could not be navigated or triggered. |
| Candidate save/archive | FAIL | Candidate content is not reachable. |
| Control save/archive unchanged | FAIL (HIGH) | Saving all controls through `SavedDailyReading(content:)` stores canonical title/read and clears `love`, `work`, `growth`, `caution`, and `opportunity`; the saved-detail path then prefers the versioned title/read. This is not the required unchanged six-field control archive behavior. |
| Candidate share | FAIL | Candidate content is not reachable. |
| Control six-field share unchanged | FAIL (HIGH) | Home always passes control content to `DailyLensSharePayload`, whose text/image comprise title/read only. The former six-field control share is replaced. |
| Notification/deep link | BLOCKED | No permitted interactive route was available; no deep-link handler was found for an alternate safe route. |
| Accessibility | PARTIAL / BLOCKED | `DailyLensTitleReadView` has a combined label in source. Dynamic Type, VoiceOver order, button labels, truncation, and Reduce Motion could not be exercised. |
| Device/layout coverage | PARTIAL | Current Pro-sized iPhone, dark, portrait: visually observed. Small phone and light appearance: not observed. |
| Analytics/completion | BLOCKED | Source retains save/share tracking calls and completion calls, but no runtime events were exercised or inspected. |

## Defects

### HIGH — candidate routing is not integrated into either presentation surface

- **Reproduction:** Launch the current build and attempt to exercise a candidate. No consumer instantiates `DailyLensContentRouter`; `HomeView` and `DailyRitualView` directly construct `DailyLensContent(control:)`.
- **Affected files:** `Screens/Home/HomeView.swift:1318`, `Screens/Daily/DailyRitualView.swift:270`, `Services/Daily/DailyLensContentRouter.swift:14`.
- **Expected:** Candidate mode can supply accepted title/read content, with documented production fallback when unavailable, blocked, incomplete, or disabled.
- **Actual:** Candidate mode is unreachable; the candidate router has no call sites.
- **Screenshot:** none — this is an integration-path absence, not a visual rendering defect.
- **Recommended fix:** Wire the existing router into the actual daily content-loading path, preserving the current fallback policy. Then rerun candidate and control QA; do not use a visual mock to bypass the integration.

### HIGH — control archive is converted to title/read rather than preserving six-field data

- **Reproduction:** Save a normal control read from Home.
- **Affected files:** `Screens/Home/HomeView.swift:1548`, `Models/SavedDailyReading.swift:145`, `Screens/Profile/ProfileSettingsDetailViews.swift:900`.
- **Expected:** Candidate archives contain only canonical title/read; existing control archives preserve their six-field representation.
- **Actual:** The convenience initializer is used for control content too, clears all five legacy field values, and saved detail prefers the versioned title/read.
- **Screenshot:** blocked by Simulator UI automation; source path is deterministic.
- **Recommended fix:** Preserve the existing control-save initializer/path and use the title/read archive initializer only for candidate provenance.

### HIGH — control sharing is converted to title/read only

- **Reproduction:** Share a normal control read from Home.
- **Affected files:** `Screens/Home/HomeView.swift:1721`, `Models/DailyLensConsumerContract.swift:96`.
- **Expected:** Candidate share is title/read only; existing control share remains six-field.
- **Actual:** All content is converted to `DailyLensSharePayload`, whose rendered and text payloads contain only title/read.
- **Screenshot:** blocked by Simulator UI automation; source path is deterministic.
- **Recommended fix:** Branch sharing by provenance so production controls retain the existing share renderer/payload.

## Tooling blocker

The CoreSimulator service itself is healthy: the valid iPhone 17 Pro is booted, the app is installed, and the real isolated `xcodebuild` succeeded. The permitted Computer Use bridge is the failed component:

```text
sky.get_app_state({ app: "com.apple.iphonesimulator" })
Sky Computer Use service startup request failed
```

Xcode’s corresponding connection attempt failed with `Sky Computer Use native pipe startup failed`. Because the QA skill permits UI interaction only through that bridge, no safe tap, long-press, navigation, share, accessibility, or notification-deep-link verification was available. `simctl` can launch and capture screenshots but cannot drive these interactions.

## Changed files

- No application code or configuration changed.
- This audit artifact only: `artifacts/visual-qa-v1/todays-lens-title-read-visual-qa-v1.md`.
