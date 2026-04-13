# Zodian Analytics Event Taxonomy

Current lightweight analytics events wired into the app.

This is intentionally provider-agnostic so we can swap the console logger for a real analytics backend later without changing event names.

## Core Events

| Event | Meaning | Key Properties |
|---|---|---|
| `onboarding_completed` | User finished onboarding and profile save succeeded | `identity_id`, `western_sign`, `chinese_sign`, `name_provided` |
| `identity_share_presented` | Identity share sheet was successfully prepared and presented | `identity_id`, `identity_title`, `source` |
| `daily_reveal_completed` | User completed daily reveal and reward/streak update path ran | `identity_id`, `streak`, `points` |
| `daily_ritual_completed` | User completed the ritual and reward path ran | `identity_id`, `streak`, `points` |
| `swipe_performed` | User performed a like or pass swipe in Connect | `action`, `archetype_id`, `compatibility_score`, `filter`, `is_premium` |
| `match_saved` | A new match was saved | `archetype_id`, `compatibility_score`, `match_style`, `intent`, `source` |
| `match_deleted` | A saved match was deleted from Matches | `match_id`, `archetype_id`, `had_chat_history` |
| `chat_opened` | User opened a match chat thread | `match_id`, `archetype_id`, `unread_count`, `message_count` |
| `first_message_sent` | User sent the first message in a thread | `match_id`, `archetype_id` |
| `paywall_viewed` | Premium/rewards sheet opened | `source`, `premium_active` |
| `premium_activated` | User activated premium from the current local premium flow | `source` |

## Source Values In Use

Common `source` values currently used:
- `onboarding_reveal_header`
- `onboarding_reveal_cta`
- `connect_swipe`
- `connect_preview`
- `blueprint`
- `profile`

## Notes

- These events are currently logged through a lightweight analytics service and console/logger provider.
- Event names should be treated as stable unless we explicitly decide to rename them before a real provider integration.
- Once a production provider is chosen, map these event names directly rather than inventing a second taxonomy.
