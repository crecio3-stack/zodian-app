# Zodian Manual QA Checklist

Production-minded device QA worksheet for the current app state.

How to use:
- Run this on a physical device when possible.
- Mark each case as `PASS`, `FAIL`, or `N/A`.
- If a case fails, capture:
  - device + iOS version
  - exact combo/user state
  - whether it reproduces after relaunch
  - screenshot/video if visual

Failure severity:
- `Critical`: launch failure, broken persistence, broken onboarding truth, double rewards, orphaned data, blank share flow, broken navigation
- `High`: incorrect content, unread mismatch, premium gating issues, saved match inconsistency, relaunch truth problems
- `Medium`: layout/polish issues that do not corrupt state
- `Low`: purely cosmetic polish

Fixability guidance:
- `Codex-safe`: likely safe for implementation directly in code
- `Manual/Product review`: likely needs a product decision or explicit UX decision
- `Mixed`: likely code + product framing/tuning together

---

## Top 5 Highest-Risk Checks First

| Priority | Check | Why |
|---|---|---|
| 1 | Onboarding completion -> relaunch -> same user/identity loads correctly | Core app truth starts here |
| 2 | Today’s Lens awards once and stays correct after relaunch | High risk for points/streak trust |
| 3 | Connect like/pass/undo updates deck, saved matches, and relaunch state correctly | Cross-screen state risk |
| 4 | Match deletion removes both saved match and related chat thread | Data cleanup risk |
| 5 | Identity share works on first tap and exports correct card-only image | Recent feature, likely regression point |

---

## Top 5 Most Likely Regression Areas

| Area | Why |
|---|---|
| Connect -> Matches -> Match Detail -> Chat sync | Multiple local state + persistence touchpoints |
| Relaunch persistence | UserDefaults + SwiftData + screen hydration interactions |
| Free vs premium gating | Cross-screen logic and expectation mismatch risk |
| Identity content lookup/fallback | New 144-entry content system now powers multiple screens |
| Long text / pills / short detail cards | Already surfaced as a real UI regression area |

---

## 1. Fresh Install / Onboarding

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 1.1 | Fresh launch path | Delete app / clean install | Install and launch app | App opens to onboarding entry, not main tabs | Critical | Codex-safe | Pass |  |
| 1.2 | Complete onboarding | Fresh install | Enter name and birthday, continue through flow | Identity reveal appears and CTA advances to main app | Critical | Codex-safe | Pass |  |
| 1.3 | Relaunch after onboarding | Completed onboarding | Force close app and relaunch | App opens to main tabs and does not return to onboarding | Critical | Codex-safe | Pass |  |
| 1.4 | Primary user load | Existing install | Complete onboarding, relaunch, inspect user-specific screens | Same user identity persists across Home/Blueprint/Profile | Critical | Codex-safe | Pass |  |
| 1.5 | Onboarding reset full return | Completed onboarding | Profile -> reset onboarding | App returns to onboarding cleanly | Critical | Codex-safe | Pass |  |

## 2. Identity + Blueprint Content

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 2.1 | Known combo resolution | Use known combo such as `libra-snake` | Complete onboarding, inspect reveal, Blueprint, Profile | Same title/tagline/sign identity appears consistently | Critical | Codex-safe | Pass |  |
| 2.2 | Expanded combo resolution | Use newer combo such as `capricorn-dragon` or `taurus-pig` | Complete onboarding, inspect Blueprint and Profile | Fully populated combo-specific content appears | High | Codex-safe | Pass |  |
| 2.3 | Cross-screen identity consistency | Any completed onboarding | Compare onboarding reveal title with Blueprint hero and Profile content | No mismatched identity titles/signs | High | Codex-safe | Pass |  |
| 2.4 | Blueprint premium locks | Free account | Open Blueprint and scroll locked sections | Premium content is gated/blurred and prompt appears clearly | High | Mixed | Pass |  |
| 2.5 | Long title/tagline wrap | Use a longer identity title/tagline | Inspect onboarding reveal, Blueprint, Profile | No clipping, absurd truncation, or broken hierarchy | High | Codex-safe | Pass |  |

## 3. Today’s Lens

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 3.1 | First Today’s Lens reveal | Completed onboarding, no reveal today | Open Home and reveal Today’s Lens | Reveal completes and lens shows | Critical | Codex-safe | Pass |  |
| 3.2 | Same-day reveal protection | Already revealed today | Revisit Home and try again | No second reward is granted | Critical | Codex-safe | Pass |  |
| 3.3 | Lens completion | Same day, lens not yet complete | Open Today’s Lens and complete flow | Completion awards once | High | Codex-safe | Pass |  |
| 3.4 | Reading persistence | After reveal | Leave Home, return later, optionally relaunch | Reading state remains coherent for the day | High | Codex-safe | Pass |  |
| 3.5 | Today’s Lens debug reset | Developer reset available | Profile -> reset Today’s Lens, return Home | Home card returns to unrevealed state | Medium | Codex-safe | Pass |  |

## 4. Streaks / Rewards / Points Consistency

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 4.1 | Points after reveal | Note current points | Complete Today’s Lens | Points increase once and match across Home/Profile | Critical | Codex-safe | Pass |  |
| 4.2 | Points after ritual | Note points after reveal | Complete ritual | Ritual reward is added once and remains consistent | High | Codex-safe | Pass |  |
| 4.3 | Streak consistency | Existing streak > 0 if possible | Compare Home header, Profile stats, reward progress | Same streak value appears everywhere | High | Codex-safe | Fail | Day is not updating, unless first install does not count as a day towards reward |
| 4.4 | Milestone unlock behavior | Near milestone if possible | Trigger reward milestone progression | Correct unlock/progress updates without duplicate grants | High | Mixed | Pass |  |
| 4.5 | Relaunch after state changes | After reveal/ritual/points changes | Force close and relaunch | Points, streak, and reward state remain unchanged | Critical | Codex-safe | Pass |  |

## 5. Connect Swiping / Like / Pass / Undo

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 5.1 | Deck loads | Completed onboarding | Open Connect | Deck appears with profiles and filters | High | Codex-safe | Pass |  |
| 5.2 | Swipe like from deck | Active Connect deck | Swipe right on top profile | Card leaves deck and saved match is created | Critical | Codex-safe | Pass |  |
| 5.3 | Swipe pass from deck | Active Connect deck | Swipe left on top profile | Card leaves deck and does not immediately reappear | High | Codex-safe | Pass |  |
| 5.4 | Preview Match actions | Active Connect deck | Tap Preview Match, then Like/Pass/Save | Actions behave same as deck interactions | Critical | Codex-safe | Pass |  |
| 5.5 | Undo last swipe | Perform a like or pass | Tap undo banner | Last swipe reverses correctly and deck looks sane | High | Codex-safe | Pass |  |
| 5.6 | Filter switching | Existing Connect deck | Switch all filters | Deck reloads cleanly without blank/stuck state | Medium | Codex-safe | Pass |  |

## 6. Free vs Premium Behavior

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 6.1 | Free swipe limit | Free account, fresh day | Swipe until limit is reached | Limit banner appears and more discovery is blocked | Critical | Codex-safe | Pass |  |
| 6.2 | Premium bypass | Premium or unlocked trial state | Continue swiping beyond free limit | No free-limit block is applied | Critical | Mixed | Pass |  |
| 6.3 | Blueprint premium gating | Free account | Open Blueprint locked sections | Premium sections remain gated | High | Mixed | Pass |  |
| 6.4 | Premium status persistence | Premium or trial state | Relaunch app | Premium/free behavior remains stable | High | Mixed | Pass |  |
| 6.5 | Premium sheet entry points | Free account | Open premium sheet from Blueprint/Profile | Sheet opens and dismisses cleanly | Medium | Codex-safe | Pass |  |

## 7. Matches / Match Detail

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 7.1 | Saved match appears | Like or save a Connect profile | Open Matches tab | New match appears with correct content/image | Critical | Codex-safe | Pass |  |
| 7.2 | Match filters | Have several saved matches if possible | Use All / High Match / Recent / Intentional | Filtering behaves correctly and empty states make sense | Medium | Codex-safe | Pass |  |
| 7.3 | Match detail consistency | Open saved match | Compare list item vs detail content | Detail reflects saved match content correctly | High | Codex-safe |  |  |
| 7.4 | Layout on short detail cards | Open a match with short values | Inspect Potential Friction / Intent / quick stat pills | Content is left aligned and pills do not clip | High | Codex-safe |  |  |
| 7.5 | Start conversation from detail | In Match Detail | Tap Start Conversation | Opens Chat for the correct match | High | Codex-safe |  |  |

## 8. Chat Unread / Read Behavior

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 8.1 | Empty thread state | Saved match with no messages | Open Chat | Empty state and starter prompts show | Medium | Codex-safe |  |  |
| 8.2 | Send first message | Empty thread | Send starter prompt or typed message | User message saves and local auto-reply appears | High | Codex-safe |  |  |
| 8.3 | Unread badge in Matches | Leave thread after match reply arrives | Return to Matches | Unread badge/count appears | High | Codex-safe |  |  |
| 8.4 | Mark thread read on open | Have unread reply from match | Open Chat, then go back to Matches | Unread badge clears after opening thread | Critical | Codex-safe |  |  |
| 8.5 | Relaunch unread persistence | Leave unread message, relaunch app | Open Matches then Chat | Unread state persists until thread is opened, then clears | Critical | Codex-safe |  |  |

## 9. Delete / Reset Flows

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 9.1 | Delete saved match removes chat | Saved match with messages | Delete match from Matches | Match disappears and related chat is gone | Critical | Codex-safe |  |  |
| 9.2 | Reset Connect history | Have saved matches, passed profiles, swipe events, chats | Profile -> Reset Connect history | Connect-specific data clears, core user state stays | Critical | Codex-safe |  |  |
| 9.3 | Reset onboarding full wipe | Have readings, points, streak, matches, chats, profile data | Profile -> Reset onboarding | Full local app state resets back to onboarding | Critical | Codex-safe |  |  |
| 9.4 | Connect profile image cleanup | Have a connect profile photo set | Reset onboarding | No stale photo remains after reset | High | Codex-safe |  |  |
| 9.5 | Recovery screen path | Dev-only, simulate broken persistence if possible | Launch app | Recovery view appears instead of crash | Critical | Mixed |  |  |

## 10. Relaunch Persistence Checks

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 10.1 | User persistence | Completed onboarding | Force close and relaunch | Correct user still loaded | Critical | Codex-safe |  |  |
| 10.2 | Points/streak persistence | Earn reveal/ritual progress | Force close and relaunch | Points and streak remain correct | Critical | Codex-safe |  |  |
| 10.3 | Saved artifacts persistence | Create saved reading/match/chat | Relaunch app | Items remain present and linked | Critical | Codex-safe |  |  |
| 10.4 | Connect exclusion persistence | Pass or save some profiles | Relaunch and revisit Connect | Excluded profiles do not immediately reappear | High | Codex-safe |  |  |
| 10.5 | Premium/free persistence | Premium or trial state | Relaunch | Gating state remains stable | High | Mixed |  |  |

## 11. Share Flow for Cosmic Identity

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 11.1 | Top-right icon placement | Reach onboarding reveal | Inspect header | Share icon feels inset and aligned, not edge-hugging | Low | Codex-safe |  |  |
| 11.2 | CTA share first-tap behavior | Reach onboarding reveal | Tap `Share Your Identity ✦` once | Share sheet opens correctly on first tap | Critical | Codex-safe |  |  |
| 11.3 | Header share first-tap behavior | Reach onboarding reveal | Tap top-right share icon once | Same first-tap success as CTA share | Critical | Codex-safe |  |  |
| 11.4 | Share payload correctness | Share sheet visible | Inspect share preview/content | Card-only image is shared, with dynamic identity title text | High | Codex-safe |  |  |
| 11.5 | Tarot card visual fidelity | Compare live reveal to shared image | Share and inspect preview/image | Shared image preserves tarot-like proportions and glow | High | Codex-safe |  |  |
| 11.6 | Reopen share repeatedly | Open, dismiss, and reopen share | Repeat both buttons | No blank share controller or stale payload behavior | High | Codex-safe |  |  |

## 12. Content Fallback Checks

| ID | Test Case | Setup | Exact Steps | Expected Result | Severity | Fix Path | Status | Notes |
|---|---|---|---|---|---|---|---|---|
| 12.1 | Multi-combo confidence sweep | Test several distinct birthday combos | Run onboarding and inspect Blueprint/Profile | Combo-specific content appears across a representative spread | High | Codex-safe |  |  |
| 12.2 | Missing entry resilience | Dev-only, remove one content entry if testing locally | Open affected combo | App does not crash; fallback content appears | Critical | Codex-safe |  |  |
| 12.3 | Bundled JSON integrity | Fresh install and relaunch | Inspect onboarding/Blueprint/Profile identity content | No empty-state identity caused by missing resource bundle | Critical | Codex-safe |  |  |
| 12.4 | Fallback styling integrity | Trigger fallback if possible | View fallback content in Blueprint/Profile | Fallback remains styled and readable, not broken/raw | High | Codex-safe |  |  |

---

## Suggested Device Run Order

1. Fresh install run
   - Sections 1, 2, 11
2. Core daily state run
   - Sections 3, 4, 10
3. Connect run
   - Sections 5, 6
4. Match/chat run
   - Sections 7, 8
5. Destructive/reset run
   - Sections 9, 10
6. Fallback/content confidence run
   - Section 12

---

## Tester Notes

- Any failure involving:
  - wrong user loaded
  - double reward
  - blank share sheet
  - stale unread badge
  - deleted match still having chat
  - onboarding returning unexpectedly
  
  should be treated as release-blocking until understood.
