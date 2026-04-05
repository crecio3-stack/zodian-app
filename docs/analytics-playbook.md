# Analytics Playbook

This document maps the current Zodian analytics events to the product funnel and the core metrics worth tracking first.

## Funnel map

### Onboarding

- `onboarding_start`
  Fired when the welcome screen is viewed.
- `onboarding_step_viewed`
  Fired on each onboarding step screen.
- `onboarding_step_completed`
  Fired when the user advances from a step.
- `onboarding_identity_revealed`
  Fired when the identity card is flipped for the first time.
- `onboarding_identity_shared`
  Fired when the onboarding reveal is shared.
- `onboarding_complete`
  Fired when the user enters the main app from onboarding.
- `onboarding_skip`
  Fired when an optional onboarding step is skipped.

### Core ritual loop

- `daily_returned`
  Fired once per app day on Home with return context.
- `ritual_revealed`
  Fired when today&apos;s ritual is revealed.
- `ritual_completed`
  Fired when today&apos;s ritual is completed.
- `streak_at_risk`
  Fired when the user returns with only the grace window left.
- `streak_restarted`
  Fired when a missed streak is reset and today becomes day one again.
- `streak_updated`
  Fired for milestone streak updates.

### Blueprint and deeper engagement

- `blueprint_viewed`
  Fired when the Cosmic Blueprint screen is opened.
- `blueprint_theory_opened`
  Fired when the user opens the theory explainer from Blueprint.
- `chat_opened`
  Fired when Astrology Chat is opened.

### Premium funnel

- `premium_cta_tapped`
  Fired when a premium entry CTA is pressed.
- `premium_prompt_viewed`
  Fired when a premium prompt or modal appears.
- `premium_prompt_action`
  Fired when the user chooses an action on a premium prompt.
- `premium_viewed`
  Fired when the premium screen is shown.
- `premium_plan_selected`
  Fired when the user switches plan tabs.
- `premium_dismissed`
  Fired when the premium screen is closed.
- `premium_trial_started`
  Fired when a trial begins.
- `premium_purchased`
  Fired when premium is enabled through the purchase path.

## First metrics to build

### Activation

- Onboarding completion rate:
  `onboarding_complete / onboarding_start`
- Identity reveal rate:
  `onboarding_identity_revealed / onboarding_start`
- First ritual completion rate:
  `ritual_completed / onboarding_complete`

### Engagement

- Blueprint open rate:
  `blueprint_viewed / ritual_revealed`
- Chat open rate:
  `chat_opened / ritual_revealed`
- Daily return rate:
  count users with `daily_returned` on the next calendar day

### Retention and streak health

- Streak risk rate:
  `streak_at_risk / daily_returned`
- Streak save rate:
  users with `ritual_completed` after `streak_at_risk` on the same day
- Streak restart rate:
  `streak_restarted / daily_returned`

### Monetization

- Paywall view rate:
  `premium_viewed / premium_cta_tapped`
- Premium conversion rate:
  `premium_purchased / premium_viewed`
- Trial start rate:
  `premium_trial_started / premium_viewed`

## Useful event properties

- `source`
  Where a screen, prompt, or premium entry was opened from.
- `westernSign` and `chineseSign`
  Lets you segment by identity mix.
- `plan`
  Premium plan selected on the paywall.
- `streak`, `previousStreak`, `gapDays`, `returnType`
  Core retention context.

## Local verification flow

1. Open the app and run through onboarding.
2. Reveal and complete a ritual.
3. Open Blueprint, Chat, and Premium from different entry points.
4. Open the in-app analytics debug screen and verify the queued events and payloads.
5. Flush the queue after verifying if you want a clean next run.