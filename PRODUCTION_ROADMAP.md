# Zodian Production Roadmap

This file is the working source of truth for getting Zodian from prototype state to a production-ready v1.

## Current Priority Order

1. SwiftData and local data safety
2. End-to-end QA across all major flows
3. Decide which prototype features are true v1 features
4. Add analytics and crash/error monitoring
5. Gradual architecture cleanup
6. UX polish and consistency
7. Targeted automated tests

## North Star

The goal is not to add the most features.
The goal is to make Zodian stable, trustworthy, measurable, and coherent enough to ship confidently.

## Phase 1: Data Safety

Goal:
Protect the app from launch failures, broken migrations, and unsafe local data changes.

Why this comes first:
If persistence breaks, the app becomes unreliable no matter how polished the UI is.

Key outcomes:
- App can survive model evolution without breaking existing installs
- Destructive actions clean up dependent local data correctly
- Development resets are predictable and safe
- Launch failures caused by data loading are easier to recover from

Tasks:
- Audit every SwiftData model for fields likely to cause migration pain
- Identify where optional fields would reduce schema-risk over time
- Define a migration strategy for future model changes
- Review delete cleanup rules for matches, chat, readings, streak-related records, and profile state
- Add resilience around model container initialization and recovery behavior
- Make sure development reset/wipe flows are complete and easy to use

Definition of done:
- No known unsafe delete paths remain
- A documented migration strategy exists
- App launch behavior is understood even if local data is invalid

## Phase 2: Flow QA

Goal:
Verify that the full product loop works as a user experiences it, not just as isolated screens.

Why this comes second:
Most meaningful bugs now will come from interactions between screens and systems.

Primary flows to test:
- Onboarding -> Home
- Today’s Lens -> save flow
- Streak and reward progression
- Connect -> pass / like / undo
- Save match -> Matches list
- Match detail -> Chat
- Unread chat -> read state clear on open
- Delete saved match -> related chat removed
- Profile edits and reset flows

QA checklist expectations:
- Empty states behave correctly
- Re-entry into flows works after relaunch
- Navigation works from every surfaced entry point
- No stale counts, stale badges, or stale previews remain

Definition of done:
- A repeatable QA checklist exists
- The major user flows have been manually validated end-to-end

## Phase 3: V1 Boundary Decisions

Goal:
Decide what is truly in the first shippable version and what remains prototype/demo/preview.

Why this matters:
Unclear product boundaries create wasted engineering work and misleading UX.

Features to classify:
- Local chat with fake replies
- Saved matches
- Connect swiping
- Generated match/profile logic
- Rewards/streak system
- Archive/settings placeholder flows

Each feature should be tagged as one of:
- Ship in v1
- Ship as preview/beta
- Hide until later
- Requires backend before shipping

Important principle:
Do not present prototype logic as fully real if it could mislead users.

Definition of done:
- A clear v1 feature list exists
- Non-v1 surfaces are either hidden or explicitly framed

## Phase 4: Analytics and Monitoring

Goal:
Measure user behavior and detect failures quickly once the app is in real hands.

Why this matters:
Without instrumentation, product decisions become guesswork.

Analytics events to track:
- Onboarding completed
- Today’s Lens completed
- Today’s Lens saved
- Swipe liked
- Swipe passed
- Match saved
- Match deleted
- Chat opened
- First message sent
- Reward redeemed
- Premium/paywall viewed

Monitoring needs:
- Crash reporting
- Non-fatal error logging
- Key persistence failures
- Important save/delete failures

Definition of done:
- Event taxonomy exists
- Analytics provider chosen and integrated
- Crash/error monitoring integrated

## Phase 5: Architecture Cleanup

Goal:
Reduce state complexity without destabilizing active product behavior.

Why this is later:
Architecture cleanup is valuable, but only after core product direction and data safety are clearer.

Approach:
- Avoid a giant refactor
- Extract responsibilities from `AppStore` one at a time
- Keep behavior stable while reducing coupling

Likely extraction candidates:
- Premium/access logic
- Onboarding/profile state
- Today’s Lens/streak/reward logic
- Match/chat-specific local state

Definition of done:
- `AppStore` no longer owns too many unrelated responsibilities
- Feature logic becomes easier to test and reason about

## Phase 6: UX Polish

Goal:
Make the app feel premium in edge cases, not just in hero moments.

Focus areas:
- Empty states
- Disabled states
- Success feedback
- Error feedback
- Delete confirmations
- Long text handling
- Missing image fallbacks
- Consistent spacing/typography hierarchy
- Loading and transition polish

Definition of done:
- The app feels intentional across normal and edge states
- No obvious “prototype seams” remain in core flows

## Phase 7: Automated Tests

Goal:
Add a focused safety net around the logic most likely to regress.

Initial test priorities:
- Streak progression
- Reward unlock logic
- Swipe/free-limit behavior
- Match deletion also deletes chat
- Unread count behavior
- Saved match filtering behavior

Principle:
Start small and strategic. Do not try to test everything first.

Definition of done:
- Core regression-prone logic has test coverage
- New logic changes can be validated faster and with more confidence

## Immediate Next Tasks

These are the next concrete tasks we should likely work on first:

1. Audit all SwiftData models and list migration-risky fields
2. Review model container startup and define failure/recovery behavior
3. Verify all delete cleanup paths for local data
4. Create a manual end-to-end QA checklist for the current app
5. Decide whether local chat is v1, beta, preview, or hidden

## Working Rules

To stay aligned, we should follow these rules:

- No major new features before data safety and QA improve
- No broad refactors unless they unlock a roadmap priority
- Prototype behavior must not be mistaken for production truth
- When in doubt, prioritize stability over surface area

## Status

Current phase:
- Phase 1: Data Safety

Current focus:
- SwiftData hardening
- deletion safety
- launch resilience

Next checkpoint:
- finish a model audit
- define migration-risk hotspots
- create the first QA checklist draft
