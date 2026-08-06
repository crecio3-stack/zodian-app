# Production controls

Inspected 2026-08-06. These are verified in source/migrations, not a claim about current live state.

- Lifecycle: `CREATED -> GENERATING -> VALIDATING -> READY -> PUBLISHED`; failures/cancellation are terminal for ordinary transitions; `PUBLISHED -> SUPERSEDED` and controlled superseded replacement are supported.
- A batch represents 144 identity pairs. Database checks and manager validation require complete, valid rows before `READY` or `PUBLISHED`.
- Published and superseded batch metadata and rows are guarded as immutable. A partial unique index allows one published batch per environment/date.
- Generation uses leases and bounded Western-sign chunks. Scheduler code records retryable failures and can resume incomplete work; exact live retry frequency is not verified.
- Production scheduling code uses Los Angeles time, a pre-midnight generation window, and midnight-only publication. The cron trigger and live schedule are unverified here.
- Provider access is bounded by server-side secrets in provider-facing functions; secrets must never be exposed. Exact deployed provider/model configuration is version-specific.
- Deployment boundaries are represented by separate Edge Functions/config and migrations, but no live deployment inventory is verified.
- Recovery includes failed-batch inspection, corrective batch support, and rollback/withdrawal manager actions/RPCs. Use only after authorization and confirm the exact target.
- Historical data is protected by foreign keys/restrict behavior and published-row guards; migrations explicitly avoid copying/updating/deleting existing public rituals in the publication migration.

Do not present any control as guaranteed when it is only present in a dirty source tree or migration not known to be applied.
