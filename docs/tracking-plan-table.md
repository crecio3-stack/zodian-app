# Tracking Plan Table

Use this as the operational source of truth for analytics ownership and rollout quality.

Status legend:

- `draft` = defined but not fully validated
- `implemented` = emitted in app code
- `validated` = verified in simulator and analytics debug screen
- `monitored` = included in Amplitude dashboard

## Event Tracking Plan

| Event | Funnel Stage | Trigger Surface | Required Properties | Optional Properties | Owner | Status | Validation Method | Dashboard Chart |
|---|---|---|---|---|---|---|---|---|
| onboarding_start | Activation | Onboarding welcome view | none | entry | PM + Mobile | implemented | Simulator onboarding start | Onboarding funnel |
| onboarding_step_viewed | Activation | Each onboarding step screen | step, stepIndex | hasExistingName, westernSign, chineseSign | Mobile | implemented | Step navigation walkthrough | Onboarding step dropoff |
| onboarding_step_completed | Activation | Continue action on each step | step, stepIndex | nameLength, birthYear | Mobile | implemented | Complete all steps once | Onboarding step dropoff |
| onboarding_skip | Activation | Skip action | step, stepIndex | none | Mobile | implemented | Use skip on Name screen | Onboarding skip usage |
| onboarding_identity_revealed | Activation | Reveal card first flip | westernSign, chineseSign | archetype, hasName | Mobile | implemented | Reveal identity once | Onboarding funnel |
| onboarding_identity_shared | Activation | Share from reveal step | westernSign, chineseSign, method | none | Mobile | implemented | Share flow in reveal screen | Activation breakdown |
| onboarding_complete | Activation | Enter app from reveal | westernSign, chineseSign | archetype, hasName | PM + Mobile | implemented | Complete onboarding end-to-end | Onboarding funnel |
| daily_returned | Core Loop | Home daily return context | todayDate, returnType | gapDays, lastCompletedDate, revealed, completed, streak | Mobile | implemented | Open app on multiple day scenarios | Daily ritual funnel |
| ritual_revealed | Core Loop | Home ritual reveal action | westernSign, chineseSign | date | Mobile | implemented | Reveal ritual on Home | Daily ritual funnel |
| ritual_completed | Core Loop | Home/Daily completion action | westernSign, chineseSign | starDustEarned | Mobile | implemented | Complete ritual action | Daily ritual funnel |
| streak_at_risk | Retention | Daily return with grace risk | streak, lastCompletedDate | daysSinceLast, daysUntilReset | PM + Mobile | implemented | Simulate missed-day return | Streak at-risk volume |
| streak_restarted | Retention | Completion after missed streak | previousStreak, previousLastCompletedDate, resumedOn | none | PM + Mobile | implemented | Complete ritual after missed day | Streak restarts volume |
| streak_updated | Retention | Milestone streak persist | streak | source | Mobile | implemented | Reach milestone in dev test | Streak milestone updates |
| blueprint_viewed | Engagement | Blueprint screen view | source, westernSign, chineseSign | sectionCount | Mobile | implemented | Open blueprint from each source | Blueprint opens by source |
| blueprint_theory_opened | Engagement | Theory link on blueprint | source, westernSign, chineseSign | none | Mobile | implemented | Tap theory link on blueprint | Engagement depth |
| chat_opened | Engagement | Home chat entry | source | none | Mobile | implemented | Open chat from Home | Chat open rate |
| premium_cta_tapped | Monetization | Premium entry CTA | source | none | Mobile | implemented | Open premium from all sources | Premium conversion funnel |
| premium_prompt_viewed | Monetization | Prompt/modal displayed | source, title | none | Mobile | implemented | Trigger locked prompt/modal | Prompt quality chart |
| premium_prompt_action | Monetization | Prompt choice action | source, title, action | none | Mobile | implemented | Choose each prompt action path | Prompt action mix |
| premium_viewed | Monetization | Premium screen view | source | defaultPlan, isPremium | Mobile | implemented | Open premium screen | Premium conversion funnel |
| premium_plan_selected | Monetization | Plan switch action | source, plan | none | Mobile | implemented | Toggle monthly/yearly | Premium plan interest |
| premium_dismissed | Monetization | Close premium screen | source, plan | none | Mobile | implemented | Close premium screen | Premium dismiss rate |
| premium_trial_started | Monetization | Trial action | entryPoint | plan, flow | Mobile | implemented | Start trial in premium | Trial start funnel |
| premium_purchased | Monetization | Purchase action | source or entryPoint | plan, flow | Mobile | implemented | Purchase path in premium | Premium conversion funnel |

## Property Contract Checks

| Property | Required On Events | Null Allowed | Check Frequency | Owner |
|---|---|---|---|---|
| source | premium_cta_tapped, premium_viewed, blueprint_viewed | No | Daily | Mobile |
| step | onboarding_step_viewed, onboarding_step_completed, onboarding_skip | No | Daily | Mobile |
| stepIndex | onboarding_step_viewed, onboarding_step_completed, onboarding_skip | No | Daily | Mobile |
| returnType | daily_returned | No | Daily | PM + Mobile |
| plan | premium_plan_selected, premium_dismissed | No | Daily | Mobile |
| westernSign, chineseSign | onboarding_identity_revealed, blueprint_viewed, ritual_revealed, ritual_completed | Preferred | Weekly | PM |

## Validation Workflow

1. Run simulator route smoke checks:
   `npm run qa:sim-smoke 8081`
2. Run local lint:
   `npm run lint -- --quiet`
3. Open analytics debug screen in app and verify event payload fields.
4. Mark status to `validated` for events verified in current build.
5. Mark status to `monitored` once charted in Amplitude dashboard.

## Ownership Notes

- Replace placeholder owners with actual names.
- Keep this table updated whenever event names or property contracts change.
- Update alongside:
  - docs/analytics-playbook.md
  - docs/amplitude-dashboard-spec.md
  - docs/amplitude-dashboard-build-sheet.md