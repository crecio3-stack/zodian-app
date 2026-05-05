# Zodian TestFlight Launch Checklist

Production-minded checklist for preparing the first meaningful TestFlight build.

Use this before each candidate build you intend to distribute beyond your own device.

---

## 1. Build Readiness

- [ ] Xcode build succeeds on the target scheme
- [ ] Manual smoke test passes on physical device
- [ ] No known critical persistence bugs remain
- [ ] No known blank-screen / blocked-navigation issues remain
- [ ] Onboarding share flow works on first tap
- [ ] App launches correctly after force close / relaunch

---

## 2. Core User Flows To Re-Verify

- [ ] Fresh install -> onboarding -> identity reveal -> main app
- [ ] Blueprint and Profile show the same identity content
- [ ] Daily Reveal completes and awards points once
- [ ] Daily Ritual completes and awards once
- [ ] Connect swipe like/pass works
- [ ] Connect card scrolls vertically without fighting deck swipe
- [ ] Saved match appears in Matches
- [ ] Match detail opens correctly
- [ ] Chat opens correctly and unread clears after reading
- [ ] Delete saved match removes related chat
- [ ] Relaunch preserves user, points, streak, and saved content

---

## 3. Product Framing Before TestFlight

- [ ] Decide whether local chat is framed as prototype, beta, or launch behavior
- [ ] Decide whether premium is “real” for this build or a preview unlock path
- [ ] Remove or clearly frame placeholder screens if they could confuse testers
- [ ] Confirm any dev-only reset tools are acceptable for this build
- [ ] Confirm no misleading “coming soon” or fake-live behavior appears in critical paths

---

## 4. Analytics / Logging Readiness

- [ ] Analytics events are visibly logging during internal runs
- [ ] Onboarding completion logs
- [ ] Identity share presentation logs
- [ ] Daily reveal + ritual completion logs
- [ ] Swipe / match save / match delete logs
- [ ] Chat opened / first message sent logs
- [ ] Paywall viewed / premium activated logs

Reference:
- `ANALYTICS_EVENT_TAXONOMY.md`
- `APP_STORE_METADATA.md`
- `Releases/`

---

## 5. App Store Connect / Distribution Prep

- [ ] Set version number
- [ ] Set build number
- [ ] Confirm app name, subtitle, and metadata feel current
- [ ] Add internal release notes
- [ ] Add external tester notes if sending beyond internal group
- [ ] Define who should receive this build
- [ ] Define what feedback you most want from this build

---

## 6. Known Limitations To Call Out

Suggested areas to be explicit about if still applicable:

- [ ] Local chat behavior is prototype/local-only
- [ ] Connect profiles are curated sample profiles, not live nearby users
- [ ] Premium flow is not final commerce
- [ ] Some archive/settings destinations are placeholders
- [ ] Content is local/bundled and may evolve in future builds

---

## 7. Recommended Tester Focus Areas

Ask testers to focus on:

1. Onboarding clarity and delight
2. Daily Reveal and Daily Ritual usefulness
3. Connect swipe quality and saved match behavior
4. Portrait quality, variety, and framing across Connect surfaces
5. Match detail + chat flow
6. Relaunch persistence and overall polish

---

## 8. Ship / Hold Decision

Ship this TestFlight build only if:

- [ ] No critical failures remain
- [ ] Core loop works without supervision
- [ ] Product framing is honest enough for tester expectations
- [ ] You know what feedback you want to learn from this build

Hold the build if:

- [ ] identity or persistence truth is questionable
- [ ] deleting/resetting data leaves stale state
- [ ] premium/free behavior is still confusing
- [ ] prototype behavior is likely to be mistaken for fully live production behavior
