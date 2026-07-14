# Today’s Lens title + read Visual QA v1

**Commit:** `929d638 Add versioned title-read Today’s Lens UI`
**Result:** `UI_READY_AFTER_BLOCKING_FIXES`
**Code changed during QA:** none

## Build and runtime

- Xcode 26.6 (17F113); scheme `Zodian`; Debug iOS Simulator build.
- Destination: iPhone 17 Pro, iOS 26.4 (`29ECF2BB-C796-4B41-B2BB-F62A3EEFD81A`).
- Command: `xcodebuild -project Zodian.xcodeproj -scheme Zodian -configuration Debug -destination 'platform=iOS Simulator,id=29ECF2BB-C796-4B41-B2BB-F62A3EEFD81A' -derivedDataPath /tmp/ZodianVisualQAV1DerivedData -quiet build`
- Result: exit 0. No compiler errors or emitted warnings.
- The earlier failure was an Xcode `build.db` lock from concurrent builds in the default DerivedData directory. CoreSimulator was responsive, the destination was valid, and the isolated build and app launch succeeded.

## Scenario results

| Scenario | Result | Evidence |
| --- | --- | --- |
| Home reveal and controls | PASS | Reduced Motion tap revealed the read; Save completed and persisted locally. [01](01-initial-launch.png), [03](03-home-control-revealed.png), [04](04-home-control-saved.png) |
| Home candidate title/read | BLOCKED | No candidate provider or router integration reaches Home. `HomeView` directly constructs `DailyLensContent(control:)`. |
| Full Daily candidate title/read | BLOCKED | `DailyRitualView` also directly constructs control content; no app navigation or candidate fixture exposed this flow. |
| Production six-field fallback | FAIL | Current production control content takes the title/read branch, hiding its legacy fields. [03](03-home-control-revealed.png) |
| Loading, retry, no-content, unavailable-candidate fallback | NOT VERIFIED | No deterministic runtime fixture is wired for these states; candidate routing is not integrated. |
| Save / completion | PASS for current control flow | Save, completion state, and unsave-capable control appeared after runtime Save. [04](04-home-control-saved.png) |
| Candidate archive | BLOCKED | Candidate data is not routable in the app; saved-read archive is additionally premium-gated in this simulator. |
| Control archive unchanged | FAIL by implementation review | Saving a control writes canonical title/read, and archive prefers that versioned content, suppressing legacy fields. |
| Share invocation | PARTIAL | The native share service reached `ready to interact` in simulator logs. Its hosted visual UI rendered blank in this simulator, so image/text contents were not visually inspectable. [05](05-home-control-share-sheet.png), [06](06-home-control-share-sheet-settled.png) |
| Notification deep link | NOT VERIFIED | No local notification/push test fixture was supplied. |
| VoiceOver order and labels | PARTIAL | Accessibility tree combines title/read before Save then Share. Under Reduce Motion the action becomes tap, but its label still says “Tap and hold.” |
| Large Dynamic Type | FAIL | At `accessibility-extra-extra-extra-large`, the title/read remain fixed-size; the paragraph does not truncate. [07](07-home-control-large-dynamic-type.png) |
| Current Pro / dark portrait | PASS | No clipping or overlap observed. [03](03-home-control-revealed.png) |
| Smaller current phone / dark portrait | PASS | iPhone 17e inspection showed no clipping or overlap. [09](09-iphone17e-small-layout.png) |
| Light appearance | N/A | Requesting light mode left the app dark, consistent with its forced dark presentation. [08](08-home-light-appearance-request.png) |
| Existing analytics / completion hooks | PASS by execution and code trace | Reveal executed; save completed. Existing opened, saved, shared, expanded, and unsaved hooks remain in Home. |

## Defects

### BLOCKING — production control no longer uses the six-field presentation

- **Reproduction:** Launch a normal production-control session, reveal Today’s Lens.
- **Expected:** Existing control content keeps the six-field UI (including available Watch, Move, pull quote, and deeper read); title/read is reserved for accepted candidate content.
- **Actual:** Normal control is wrapped as a ready `DailyLensContent`, so Home and Full Daily show only title/read. Screenshot [03](03-home-control-revealed.png) contains no legacy sections.
- **Affected:** `Models/DailyLensConsumerContract.swift:77`, `Screens/Home/HomeView.swift:1277`, `Screens/Daily/DailyRitualView.swift:271`.
- **Recommended fix:** Branch presentation by provenance/version: candidate content may use `DailyLensTitleReadView`; production control must continue through its existing six-field renderer.

### BLOCKING — candidate UI cannot be exercised or reached in the app

- **Reproduction:** Launch the committed app and reveal Today’s Lens.
- **Expected:** An accepted candidate has a routable Home and Full Daily path, with a deterministic local QA fixture when the provider is unavailable.
- **Actual:** The router is defined but unused; Home and Full Daily instantiate only `DailyLensContent(control:)`. Candidate title/read, archive, and share requirements therefore cannot be runtime-verified.
- **Affected:** `Screens/Home/HomeView.swift:1318`, `Screens/Daily/DailyRitualView.swift:271`, `Services/Daily/DailyLensContentRouter.swift`.
- **Recommended fix:** Wire the approved candidate/control router into both consumers and add a non-production QA fixture for accepted and unavailable candidate states.

### HIGH — saving a control rewrites its archive and share behavior as title/read

- **Reproduction:** Save a normal production-control Lens; open the saved detail once archive access is available.
- **Expected:** Control archive and control share preserve the existing six-field behavior.
- **Actual:** Home saves every control as canonical title/read; `versionedLensContent` then returns a title/read payload even for `production-control-v1`, and archive prefers that payload.
- **Affected:** `Screens/Home/HomeView.swift:1548`, `Models/SavedDailyReading.swift:194`, `Screens/Profile/ProfileSettingsDetailViews.swift:900`.
- **Recommended fix:** Persist canonical title/read only for candidate content, or explicitly route `production-control-v1` saved reads through the legacy archive/share path.

### MEDIUM — title/read does not participate in Dynamic Type

- **Reproduction:** Set the simulator to `accessibility-extra-extra-extra-large`, relaunch, and inspect the revealed Lens.
- **Expected:** Title and paragraph scale with the preferred content size while retaining readable layout.
- **Actual:** The title/read match standard-size rendering because `DailyLensTitleReadView` accepts fixed `.system(size:)` fonts. [07](07-home-control-large-dynamic-type.png)
- **Affected:** `Screens/Daily/DailyLensTitleReadView.swift:6`.
- **Recommended fix:** Use scalable text styles or `Font.custom(_:size:relativeTo:)`, retaining the visual hierarchy while honoring Dynamic Type.

### LOW — Reduced Motion accessibility label describes the wrong gesture

- **Reproduction:** Enable Reduce Motion and focus the unrevealed Lens with VoiceOver.
- **Expected:** The label states that a tap reveals the Lens.
- **Actual:** Reduced Motion uses an `onTapGesture`, but the combined accessibility label still says “Tap and hold.”
- **Affected:** `Screens/Home/HomeView.swift:803-809`.
- **Recommended fix:** Make the accessibility label conditional on `reduceMotion`.

## Screenshot index

1. [Initial Home, unrevealed](01-initial-launch.png)
2. [Home, unrevealed with Reduce Motion](02-home-reduce-motion-unrevealed.png)
3. [Home, revealed production control](03-home-control-revealed.png)
4. [Home, saved / completed production control](04-home-control-saved.png)
5. [Native share service initial host](05-home-control-share-sheet.png)
6. [Native share service settled host](06-home-control-share-sheet-settled.png)
7. [Home at accessibility-extra-extra-extra-large](07-home-control-large-dynamic-type.png)
8. [Light appearance requested; app remains dark](08-home-light-appearance-request.png)
9. [iPhone 17e smaller-phone layout](09-iphone17e-small-layout.png)

## Recommendation

`UI_READY_AFTER_BLOCKING_FIXES`.

Do not make further visual refinements yet. Restore the control/candidate provenance split and supply a reachable candidate QA path; then rerun Home, Full Daily, archive, and share QA with accepted candidate content plus a real six-field control fixture.
