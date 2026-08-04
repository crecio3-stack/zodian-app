# Zodian Identity Editorial Layer v1

## Product purpose

The identity layer represents what is consistently true about an identity across many situations. It captures enduring editorial tendencies rather than daily events. It never predicts or chooses today’s story; it only gives Story Engine reliable editorial context.

## Stable identity

Identity contains long-lived recurring motivations, internal conflicts, blind spots, strengths, emotional patterns, and interpersonal dynamics. These remain relatively stable from day to day.

## Distillation

The layer distills approved canonical identity knowledge into concise editorial notes. It must not contain copied source passages, horoscope prose, astrology explanations, chart mechanics, zodiac symbolism, or mystical language. It represents editorial understanding, not source material.

## Story separation

Identity is not today’s story. Story Engine later decides which identity tendency matters today, which tension becomes relevant, and which thread deserves attention. Identity remains constant; story changes daily.

## Provenance

Every editorial identity profile should trace to approved canonical identity sources. Future implementations may retain source identifiers. No copyrighted source prose may propagate into downstream systems.

## Voice

Internal editorial language only: short, neutral, descriptive, and not reader-facing.

## v1 boundary

This is an isolated, shadow-only profile contract. It does not generate prose, choose a story, or connect to Story Engine, the current writer, generation, validation, batching, publication, resolver, scheduled routing, provider model, database, deployment, or cron job 26.

## Validation boundary

The validator is a small deterministic tripwire. It checks plainly empty, overlong, source-passage-like, astrological, horoscope-like, advice-like, or second-person notes. It does not perform semantic validation or infer whether every statement is canonically supported.

Copied-source detection is not semantic plagiarism detection. The validator uses excessive passage length as a deterministic tripwire; it cannot prove whether text was copied. Source fidelity and copyright safety will later be enforced through controlled provenance and transformation workflows. Raw source passages must never be stored in the editorial profile.
