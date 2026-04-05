# Simulator QA Runbook

Use this checklist for manual QA across onboarding, Home, Daily, and Premium in iOS Simulator.

## Setup

1. Start Metro.

```bash
npx expo start
```

2. Run route smoke checks (optional but recommended).

```bash
npm run qa:sim-smoke
```

3. Open Expo Go in simulator and load the project URL if needed.

## Onboarding QA

### Welcome -> Name -> Birthdate -> Reveal -> Theory

- Confirm explicit Back buttons are removed on Name, Birthdate, Reveal, and Theory.
- Confirm swipe-back gesture still works between onboarding screens.
- Confirm Step 3 button spacing above `Reveal My Identity` looks visually balanced.
- Confirm Name skip path works and routes to Birthdate.
- Confirm Reveal card can flip and still enters app.

Expected events to see in `analytics-debug`:

- `onboarding_start`
- `onboarding_step_viewed`
- `onboarding_step_completed`
- `onboarding_identity_revealed`
- `onboarding_complete`

## Home QA

- Confirm ritual card still flips and reveals content.
- Confirm streak warning banner appears when streak is at risk.
- Confirm streak recovery banner appears after a reset then completion.
- Confirm `Cosmic Blueprint`, `Go Deeper`, and chat CTAs still navigate correctly.

Expected events:

- `daily_returned`
- `streak_at_risk` when applicable
- `ritual_revealed`
- `ritual_completed`
- `blueprint_viewed`

## Daily QA

- Confirm complete action updates status and shows toast.
- Confirm restart-specific completion copy appears if streak restarted.
- Confirm `Go Deeper` lock path opens premium prompt when appropriate.
- Confirm share action still works and reward toast logic remains intact.

Expected events:

- `ritual_completed`
- `streak_restarted` when applicable
- premium prompt events if locked flow triggered

## Premium QA

Open Premium from these sources:

- Home Go Deeper
- Daily Go Deeper
- Match unlock more
- Profile premium card
- Rewards upsell
- Connections beta

For each source:

- Confirm premium screen opens.
- Confirm close and plan switch actions work.
- Confirm trial/purchase actions still execute in dev flow.

Expected events:

- `premium_cta_tapped` with source
- `premium_prompt_viewed` / `premium_prompt_action` where prompt is shown
- `premium_viewed` with source
- `premium_plan_selected`
- `premium_dismissed`
- `premium_trial_started` / `premium_purchased`

## Regression checks

- `npm run lint -- --quiet` passes.
- No red screen or navigation dead-end.
- Analytics queue in debug screen refreshes, flushes, and clears.

## Exit criteria

- All critical flows above execute without crash.
- Event payloads include expected key properties (`source`, signs, plan, streak fields).
- No visual blockers in onboarding, Home, Daily, or Premium.