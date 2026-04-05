# Amplitude Dashboard Build Sheet

Use this to build the first production dashboard in Amplitude with minimal ambiguity.

## Dashboard name

- Zodian Product Health v1

## Global dashboard settings

- Timezone: local product timezone
- Default date range: last 14 days
- Comparison: previous period
- Counting method: unique users for funnel and conversion charts, totals for event-volume charts

## Section 1: Activation

### Chart A1

- Name: Onboarding completion funnel
- Type: Funnel
- Steps:
  1. `onboarding_start`
  2. `onboarding_identity_revealed`
  3. `onboarding_complete`
- Conversion window: 1 day
- Count by: unique users

### Chart A2

- Name: Onboarding step dropoff
- Type: Segmentation
- Event: `onboarding_step_completed`
- Group by: `step`
- Interval: daily

### Chart A3

- Name: Onboarding skip usage
- Type: Segmentation
- Event: `onboarding_skip`
- Group by: `step`
- Interval: daily

## Section 2: Ritual loop

### Chart R1

- Name: Daily ritual funnel
- Type: Funnel
- Steps:
  1. `daily_returned`
  2. `ritual_revealed`
  3. `ritual_completed`
- Conversion window: 1 day
- Count by: unique users

### Chart R2

- Name: Daily return types
- Type: Segmentation
- Event: `daily_returned`
- Group by: `returnType`
- Interval: daily

### Chart R3

- Name: Ritual completion by sign pair
- Type: Segmentation
- Event: `ritual_completed`
- Group by: `westernSign`
- Secondary group by: `chineseSign` (if volume allows)
- Interval: weekly

## Section 3: Streak health

### Chart S1

- Name: Streak at-risk volume
- Type: Segmentation
- Event: `streak_at_risk`
- Interval: daily

### Chart S2

- Name: Streak restarts volume
- Type: Segmentation
- Event: `streak_restarted`
- Interval: daily

### Chart S3

- Name: Streak milestone updates
- Type: Segmentation
- Event: `streak_updated`
- Group by: `streak`
- Interval: weekly

### Chart S4

- Name: Streak save rate
- Type: Formula
- Numerator: users with `ritual_completed` and prior `streak_at_risk` same day
- Denominator: users with `streak_at_risk`
- Interval: daily

## Section 4: Engagement depth

### Chart E1

- Name: Blueprint open rate
- Type: Formula
- Numerator: `blueprint_viewed`
- Denominator: `ritual_revealed`
- Interval: daily

### Chart E2

- Name: Blueprint opens by source
- Type: Segmentation
- Event: `blueprint_viewed`
- Group by: `source`
- Interval: daily

### Chart E3

- Name: Chat open rate
- Type: Formula
- Numerator: `chat_opened`
- Denominator: `ritual_revealed`
- Interval: daily

## Section 5: Monetization

### Chart M1

- Name: Premium conversion funnel
- Type: Funnel
- Steps:
  1. `premium_cta_tapped`
  2. `premium_viewed`
  3. `premium_purchased`
- Conversion window: 7 days
- Count by: unique users

### Chart M2

- Name: Trial start funnel
- Type: Funnel
- Steps:
  1. `premium_viewed`
  2. `premium_trial_started`
- Conversion window: 7 days
- Count by: unique users

### Chart M3

- Name: Premium prompt action mix
- Type: Segmentation
- Event: `premium_prompt_action`
- Group by: `action`
- Secondary group by: `source`
- Interval: daily

### Chart M4

- Name: Premium plan interest
- Type: Segmentation
- Event: `premium_plan_selected`
- Group by: `plan`
- Interval: daily

### Chart M5

- Name: Premium dismiss rate
- Type: Formula
- Numerator: `premium_dismissed`
- Denominator: `premium_viewed`
- Interval: daily

## Monitoring charts

### Chart Q1

- Name: Event volume sanity
- Type: Segmentation
- Events:
  - `onboarding_start`
  - `daily_returned`
  - `premium_viewed`
  - `premium_purchased`
- Interval: daily

### Chart Q2

- Name: Source coverage health
- Type: Data table or segmentation
- Event: `premium_viewed`
- Group by: `source`
- Check: no large unknown/null bucket

## Suggested targets for v1

- Onboarding completion >= 55%
- Ritual completion from daily_returned >= 65%
- Blueprint open rate >= 20%
- Premium conversion from premium_viewed >= 4%
- Streak save rate >= 45%

## Weekly review cadence

1. Activation and ritual funnel first.
2. Streak health second.
3. Premium funnel third.
4. Pick one biggest dropoff and ship one focused fix.

## Notes

- If your Amplitude workspace does not support Formula charts in your plan, build equivalent ratio charts outside Amplitude for now.
- Keep event names in sync with [docs/analytics-playbook.md](docs/analytics-playbook.md) and [docs/amplitude-dashboard-spec.md](docs/amplitude-dashboard-spec.md).