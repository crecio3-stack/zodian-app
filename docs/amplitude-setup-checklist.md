# Amplitude Setup Checklist (30 Minutes)

Use this checklist to stand up the first usable Zodian dashboard quickly.

## 0) Preconditions

- Amplitude project exists.
- Mobile app can generate events locally.
- You can run simulator smoke routes.

## 1) Verify instrumentation (5 minutes)

1. Run simulator smoke checks.
2. Open Analytics Debug screen in app.
3. Trigger onboarding, daily ritual, blueprint, and premium flows.
4. Confirm queued events include at least:
   - onboarding_start
   - onboarding_complete
   - daily_returned
   - ritual_revealed
   - ritual_completed
   - premium_cta_tapped
   - premium_viewed
   - premium_purchased or premium_trial_started

## 2) Create dashboard shell (3 minutes)

1. Create dashboard: Zodian Product Health v1.
2. Add sections:
   - Activation
   - Ritual Loop
   - Streak Health
   - Engagement Depth
   - Monetization

## 3) Build high-signal charts first (10 minutes)

Add these in order:

1. Onboarding funnel
   - onboarding_start -> onboarding_identity_revealed -> onboarding_complete
2. Ritual loop funnel
   - daily_returned -> ritual_revealed -> ritual_completed
3. Premium conversion funnel
   - premium_cta_tapped -> premium_viewed -> premium_purchased
4. Blueprint open rate
   - blueprint_viewed / ritual_revealed
5. Streak risk trend
   - streak_at_risk daily count

## 4) Add chart breakdowns (5 minutes)

1. Premium funnels by source.
2. Premium plan selection by plan.
3. Daily returns by returnType.
4. Onboarding step completed by step.

## 5) Create schema health checks (4 minutes)

Add quick validation charts/tables:

1. premium_viewed grouped by source
   - Goal: minimal unknown or null source.
2. blueprint_viewed grouped by source
   - Goal: source populated.
3. onboarding_step_completed grouped by step and stepIndex
   - Goal: both properties present.
4. daily_returned grouped by returnType
   - Goal: returnType present and coherent.

## 6) Set review cadence (3 minutes)

1. Daily check:
   - Event volume sanity
   - Property presence sanity
2. Weekly check:
   - Funnel dropoff largest regression
   - One focused fix assigned
3. Bi-weekly check:
   - Retention and monetization trend changes

## Ready-to-use references

- Build details: docs/amplitude-dashboard-build-sheet.md
- Dashboard strategy: docs/amplitude-dashboard-spec.md
- Event and metric definitions: docs/analytics-playbook.md
- Manual simulator test flow: docs/simulator-qa-runbook.md