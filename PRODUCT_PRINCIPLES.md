# Zodian Product Principles

**Document version:** 1.2  
**Effective date:** 2026-06-26  
**Owner:** Zodian Founder/CTO  
**Status:** Governing  
**Brand direction:** [BRAND_MESSAGING.md](BRAND_MESSAGING.md)  
**Governed by:** [ARCHITECTURE_DECISIONS.md](ARCHITECTURE_DECISIONS.md)  
**Constrains:** [DOMAIN_CONTRACTS.md](DOMAIN_CONTRACTS.md), [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md), and [PUBLIC_LAUNCH_CHECKLIST.md](PUBLIC_LAUNCH_CHECKLIST.md)

## Product vision

> **Zodian helps you recognize your Pattern—and understand how it unfolds over time.**

Zodian is a reflective identity product with optional social discovery, not a social network with astrology content.

Zodian is a self-understanding platform. Astrology is the lens; Zodian brings the person into focus by helping them see patterns that have been there all along.

## Decision filter

Every product decision must pass all three tests:

1. Does it reveal something recognizable?
2. Does it deepen understanding rather than repeat a label?
3. Does it become more valuable over time?

If not, it does not belong in the approved architecture.

## Governing principles

| Philosophy | Principle | Implementation rule | ADRs |
|---|---|---|---|
| Mission | Help people recognize recurring identity patterns and understand how perspective changes over time. | The reflective experience must remain complete without Connect. | ADR-001, ADR-003, ADR-006 |
| Design | Time creates value. | Deepen continuity, evidence, comparison, and return before adding surfaces. | ADR-001, ADR-005, ADR-009 |
| Design | Calm clarity over novelty. | Prefer thoughtful, legible, confident behavior over feature accumulation. | ADR-001, ADR-006, ADR-012 |
| Design | One primary job per surface. | Pattern explains; Archive preserves; Memory interprets; Threads reflect; Messages communicate. | ADR-004, ADR-009 |
| Reflection | Reflection before prediction. | Describe identity tensions and grounded choices; do not claim certainty about external events. | ADR-006 |
| Reflection | Evidence before inference. | Exposure is not preference; opening is not saving; saving is not acting. Suppress weak claims. | ADR-007, ADR-009 |
| Reflection | Every Observation is inspectable. | Show what was noticed, over what period, from which evidence, and allow dismissal or correction. | ADR-007, ADR-009 |
| Reflection | Pattern explains; it does not confine. | Increase recognition without presenting identity as fixed or deterministic. | ADR-006 |
| Brand | Astrology is the lens, not the destination. | Product, marketing, App Store, onboarding, paywall, and educational copy must ladder up to self-understanding, clarity, perspective, and recognizable patterns. | BRAND-001 |
| AI | AI explains rather than invents. | Evidence selection and thresholds precede generated language. | ADR-007 |
| AI | Provenance is part of quality. | Record editorial, prompt, validator, model/provider, source, and generation versions. | ADR-007, ADR-009, ADR-012 |
| AI | Silence is a valid result. | Missing insight is preferable to persuasive unsupported output. | ADR-007, ADR-009 |
| Privacy | Private before public. | Publication requires a separate domain, explicit consent, and reversible visibility. | ADR-002, ADR-008 |
| Privacy | Pattern Memory is local-first. | Raw Memory Events and personal Observations stay on-device unless an approved backup is separately enabled. | ADR-002, ADR-015 |
| Privacy | Consent is specific. | Local card creation, public discovery, Archive sync, Memory backup, and ranking consent are distinct. | ADR-002, ADR-008, ADR-010 |
| Ownership | Ownership is stable; credentials are replaceable. | Account ID owns durable records. Installations, Apple credentials, sessions, devices, and migrations prove context or access but never become the owner. | ADR-013 |
| Premium | Premium extends perspective, not accuracy. | Sell longer history and comparison windows; never degrade free truthfulness. | ADR-005, ADR-014 |
| Premium | Safety and agency are never premium. | Privacy, deletion, correction, reporting, blocking, and unpublishing remain free. | ADR-005, ADR-008 |
| Social | Connect extends reflection. | Connect is optional and exists only when relationship context deepens self-understanding. | ADR-001, ADR-003 |
| Social | Threads hold meaning. | Threads preserve private reflection and remain distinct from an inbox. | ADR-004 |
| Social | Messages require mutual authorization. | Messaging requires consent, moderation, blocking, retention, and safety; simulations never represent people. | ADR-004, ADR-010 |

## Operating rules

- No new system, domain, product surface, or architectural concept without an accepted ADR. **ADR-011, ADR-012**
- No persistent model, backend schema, synchronization, or migration while a relevant ADR is Proposed. **ADR-011**
- Optimize the reflective activation funnel before social engagement. **ADR-001**
- Keep generated editorial artifacts separate from real-user records. **ADR-010**
- Target one accepted capability per implementation task unless cross-capability work is purely mechanical and non-behavioral. **ADR-011, ADR-012, ADR-013**
- Resolve conflicts in governance before implementation. **ADR-012**
- During UI refinements, run a lightweight copy audit against [BRAND_MESSAGING.md](BRAND_MESSAGING.md), replacing horoscope-centric, predictive, or mystical language when the change is low-churn and behaviorally true.
