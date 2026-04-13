# Zodian TestFlight Bug Tracker

Use this as a lightweight running tracker during TestFlight.

---

## Active Bugs

| ID | Title | Area | Severity | Build Found | Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| TF-001 |  |  |  |  |  |  |  |
| TF-002 |  |  |  |  |  |  |  |
| TF-003 |  |  |  |  |  |  |  |

---

## Status Meanings

- `Needs repro`: report received, not yet reproduced
- `Reproduced`: confirmed locally
- `Needs product decision`: behavior may be intentional or unclear
- `Ready to fix`: clear engineering task
- `Fixed in next build`: fix is done, awaiting verification in distributed build
- `Verified`: confirmed fixed
- `Won’t fix`: intentionally deferred or rejected

---

## Severity Guide

- `Critical`: launch failure, broken onboarding truth, broken persistence, blank share flow, destructive data bug
- `High`: cross-screen inconsistency, unread mismatch, broken premium gating, missing core content
- `Medium`: feature works but with visible UX or state issues
- `Low`: cosmetic or minor polish issue

---

## Suggested Workflow

1. Log the bug in this tracker.
2. Create a detailed entry using `BUG_TRIAGE_TEMPLATE.md`.
3. Reproduce on your own device.
4. Classify as `Codex-safe`, `Mixed`, or `Manual / product review`.
5. Fix highest-severity issues first.
6. Re-verify using the relevant section of `MANUAL_QA_CHECKLIST.md`.
