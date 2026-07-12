# Canonical Identity → Today’s Lens model-writing comparison

Provider: openai:gpt-5.6-terra. Twenty deterministic baseline outputs remain the
control group; twenty model-written outputs are experimental.

Accepted first attempt: 17\
Accepted after retry: 2\
Rejected: 1\
Total provider attempts: 24

## Average rubric scores

| Criterion               | Deterministic | Model-written |
| ----------------------- | ------------: | ------------: |
| identitySpecificity     |          3.10 |          3.21 |
| behavioralConcreteness  |          2.75 |          2.89 |
| scenarioRelevance       |          3.90 |          4.00 |
| canonicalGrounding      |          3.50 |          3.63 |
| internalCoherence       |          4.00 |          4.00 |
| fieldDifferentiation    |          5.00 |          5.00 |
| contemporaryVoice       |          4.00 |          4.00 |
| usefulness              |          4.00 |          4.00 |
| nonPredictiveDiscipline |          5.00 |          5.00 |
| repetitionControl       |          4.00 |          4.00 |

## Field-by-field comparison

### work-speaking-up — Libra × Snake

**Scenario:** speaking up vs waiting · work

**Baseline title:** Name The Missing Part

**Model title:** Name the Condition

**Notes:** model changes the recognition line; model preserves a distinct action
field; model is more compressed

**Validation:** accepted · retries 1

### work-speaking-up — Taurus × Horse

**Scenario:** speaking up vs waiting · work

**Baseline title:** Start Before Resentment

**Model title:** Name the Handoff

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### love-trust — Libra × Snake

**Scenario:** trust vs caution · love

**Baseline title:** Let Actions Count

**Model title:** What Follows Warmth

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### love-trust — Taurus × Horse

**Scenario:** trust vs caution · love

**Baseline title:** Room To Stay

**Model title:** Room Within Closeness

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### home-change — Libra × Snake

**Scenario:** stability vs change · home

**Baseline title:** The Pattern Has Shifted

**Model title:** One Useful Change

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### home-change — Taurus × Horse

**Scenario:** stability vs change · home

**Baseline title:** Change One Thing

**Model title:** Make Room First

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### friends-harmony — Libra × Snake

**Scenario:** harmony vs honesty · friends

**Baseline title:** Keep It Honest

**Model title:** REJECTED

**Notes:** model output rejected; no field comparison available

**Validation:** rejected (move must be one sentence of 10-24 words) · retries 2

### friends-harmony — Taurus × Horse

**Scenario:** harmony vs honesty · friends

**Baseline title:** Keep Your Evening

**Model title:** Change the Plan

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### money-comfort — Libra × Snake

**Scenario:** comfort vs restraint · money

**Baseline title:** The Useful Choice

**Model title:** Read the Fine Print

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### money-comfort — Taurus × Horse

**Scenario:** comfort vs restraint · money

**Baseline title:** Comfort With A Limit

**Model title:** Room for Later

**Notes:** model changes the recognition line; model preserves a distinct action
field; model is more compressed

**Validation:** accepted · retries 0

### rest-responsibility — Libra × Snake

**Scenario:** responsibility vs autonomy · rest

**Baseline title:** Not Yours To Solve

**Model title:** Leave It Settled

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### rest-responsibility — Taurus × Horse

**Scenario:** responsibility vs autonomy · rest

**Baseline title:** A Real Day Off

**Model title:** Leave It Unfixed

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### confidence-recognition — Libra × Snake

**Scenario:** recognition vs humility · confidence

**Baseline title:** Let It Count

**Model title:** Let It Land

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### confidence-recognition — Taurus × Horse

**Scenario:** recognition vs humility · confidence

**Baseline title:** Stand In The Win

**Model title:** Name the Upkeep

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### routine-freedom — Libra × Snake

**Scenario:** consistency vs freedom · routine

**Baseline title:** Enough Of The Pattern

**Model title:** Care, Then Ceremony

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### routine-freedom — Taurus × Horse

**Scenario:** consistency vs freedom · routine

**Baseline title:** Keep The Useful Part

**Model title:** Keep the Point

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### conflict-directness — Libra × Snake

**Scenario:** directness vs patience · conflict

**Baseline title:** The Honest Sentence

**Model title:** Ask It Again

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 1

### conflict-directness — Taurus × Horse

**Scenario:** directness vs patience · conflict

**Baseline title:** Before It Becomes Final

**Model title:** Name the First Shift

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### opportunity-expansion — Libra × Snake

**Scenario:** security vs expansion · opportunity

**Baseline title:** Trust The Pattern

**Model title:** The First Test

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

### opportunity-expansion — Taurus × Horse

**Scenario:** security vs expansion · opportunity

**Baseline title:** Leave Some Ground

**Model title:** Room to Choose

**Notes:** model changes the recognition line; model preserves a distinct action
field; model adds explanatory detail

**Validation:** accepted · retries 0

## Recommendation

Revise the writing prompt and rerun before any production consideration. This
mock pass proves the injectable contract, focused-context boundary, strict
parsing, and comparison audit, but it cannot establish that live model writing
is more specific or more grounded than the deterministic control.
