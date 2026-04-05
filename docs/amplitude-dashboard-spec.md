# Amplitude Dashboard Spec

This is a practical starter dashboard for current Zodian instrumentation.

## Dashboard sections

1. Onboarding funnel
2. Core ritual loop
3. Retention and streak health
4. Premium conversion
5. Blueprint and chat engagement

## Event catalog in scope

- `onboarding_start`
- `onboarding_step_viewed`
- `onboarding_step_completed`
- `onboarding_identity_revealed`
- `onboarding_identity_shared`
- `onboarding_complete`
- `onboarding_skip`
- `daily_returned`
- `ritual_revealed`
- `ritual_completed`
- `streak_at_risk`
- `streak_restarted`
- `streak_updated`
- `blueprint_viewed`
- `blueprint_theory_opened`
- `chat_opened`
- `premium_cta_tapped`
- `premium_prompt_viewed`
- `premium_prompt_action`
- `premium_viewed`
- `premium_plan_selected`
- `premium_dismissed`
- `premium_trial_started`
- `premium_purchased`

## Key charts

### Onboarding

- Funnel:
  `onboarding_start` -> `onboarding_identity_revealed` -> `onboarding_complete`
- Breakdown:
  by `step` for `onboarding_step_viewed` and `onboarding_step_completed`
- KPI:
  onboarding completion rate = `onboarding_complete / onboarding_start`

### Ritual loop

- Funnel:
  `daily_returned` -> `ritual_revealed` -> `ritual_completed`
- Breakdown:
  `returnType` from `daily_returned`
- KPI:
  ritual completion rate = `ritual_completed / daily_returned`

### Retention and streak

- Trend:
  `streak_at_risk` daily count
- Trend:
  `streak_restarted` daily count
- Derived KPI:
  streak save rate = users with `ritual_completed` after `streak_at_risk` same day / `streak_at_risk`

### Premium

- Funnel:
  `premium_cta_tapped` -> `premium_viewed` -> `premium_purchased`
- Secondary funnel:
  `premium_viewed` -> `premium_trial_started`
- Breakdown:
  by `source` and `plan`
- KPI:
  premium conversion = `premium_purchased / premium_viewed`

### Engagement depth

- Ratio:
  `blueprint_viewed / ritual_revealed`
- Ratio:
  `chat_opened / ritual_revealed`
- Breakdown:
  by sign pair (`westernSign`, `chineseSign`) if volume is sufficient

## Property schema to enforce

- `source`: premium and blueprint entry attribution
- `plan`: monthly/yearly selection context
- `westernSign`, `chineseSign`: content segmentation
- `streak`, `previousStreak`, `gapDays`, `returnType`: retention context
- `step`, `stepIndex`: onboarding step-level analysis

## Validation queries during rollout

- Ensure `premium_viewed` always has `source`.
- Ensure `blueprint_viewed` always has `source`.
- Ensure onboarding step events have `step` and `stepIndex`.
- Ensure `daily_returned` has `returnType` and `gapDays`.

## Suggested dashboard cadence

- Daily: monitor event volume and schema health.
- Weekly: review funnel conversion and streak health trends.
- Bi-weekly: prioritize product changes based on biggest drop-offs.