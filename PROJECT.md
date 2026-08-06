# Zodian project

## What it is

Zodian is an iOS product combining zodiac identity content, Today’s Lens daily readings, saved readings/people, pattern features, and Connect experiences. This description is based on the repository inspected 2026-08-06.

Today’s Lens is the daily, identity-specific horoscope/read surface. It combines a Western sign and an Eastern sign into a reader-facing daily read, then delivers the selected content through the backend reader endpoint and the iOS Daily screens. The repository’s canonical identity matrix is 12 Western signs × 12 Eastern signs = 144 combinations; the batch contract requires one row for every pair so a complete dated batch is deterministic rather than a partial sample.

## Layout

- `App/`, `Screens/`, `Models/`, `Services/`, `DesignSystem/`, `Resources/`: Swift iOS application.
- `supabase/functions/`: Deno Edge Functions, shared runtime contracts, writers, validators, and batch management.
- `supabase/migrations/`: database schema, constraints, RPCs, publication and scheduler changes.
- `scripts/`: local audits, fixtures, tests, canaries, and development tooling.
- `artifacts/`: generated review and experiment artifacts; not a source-of-truth architecture directory.

## iOS structure

`App/ZodianApp.swift` and `App/AppStore.swift` compose the app. Screens are grouped by Home, Daily, Blueprint, Connect, Profile, Onboarding, and related surfaces. Daily delivery is represented by `Services/Daily/DailyRitualService.swift`, `DailyLensContentRouter.swift`, cache/presentation services, and `Models/DailyLensConsumerContract.swift` / `DailyRitualResponse.swift`.

## Backend and Today’s Lens

The verified backend includes `generate-daily-rituals`, `manage-daily-ritual-batch`, and `get-daily-ritual`, plus isolated development, beta, shadow, and experimental functions. Production, beta, and development are explicit content environments in the batch contract. Shadow functions are isolated candidate/observation paths; experimental scripts and previews are not production architecture. The legacy Beta generator currently returns a disabled response in its source, but live deployment must still be verified.

Responsibilities are separated: the manager creates/transitions/validates/publishes batches and adapts the scheduler; the generator chooses the batch contract, calls the writer/provider where authorized, and records rows/metadata; writer prompts and shared writers shape output; validators check shape, voice, safety, diversity, and publication readiness; publication RPCs expose a complete batch; the reader API selects published content; iOS services route, cache, decode, and present it.

Batch terms: `CREATED`, `GENERATING`, `VALIDATING`, `READY`, `PUBLISHED`, `FAILED`, `CANCELLED`, and `SUPERSEDED` are the verified statuses. A corrective batch may supersede an earlier publication; it is not an edit-in-place operation.

The production scheduler contract uses `America/Los_Angeles`, stages the next content date in a pre-midnight window, and permits publication at midnight. iOS availability uses local app/date logic as well as the API response; the relationship to live user-local behavior must be verified in the active client and deployment before making operational claims.

Canonical source locations include `supabase/functions/_shared/daily-ritual-batches/`, the current deployed-facing generator and manager functions, migrations, and `Services/Daily/`. Experimental or shadow paths include files/functions with `shadow`, `candidate`, `preview`, `pilot`, or `experimental` in their names; names alone do not establish routing.

## Where to look first

- Daily app behavior: `Services/Daily/`, `Models/DailyLensConsumerContract.swift`, `Models/DailyRitualResponse.swift`, and Daily screens.
- Batch lifecycle/publication: `supabase/functions/_shared/daily-ritual-batches/`, `manage-daily-ritual-batch`, and `supabase/migrations/`.
- Current generation/writer behavior: `generate-daily-rituals/index.ts` and its imported shared writer files.
- Editorial rules/tests: `supabase/functions/generate-daily-rituals/*.md`, shared writer files/tests, and `scripts/dev/` Today’s Lens tests.
- Live operations: verify deployed metadata, scheduler state, batch state, and routing; source alone is insufficient.

## Time-sensitive facts

Always verify live: deployed function versions and routing; applied migrations; current batch/publication state; provider/model configuration; secrets/configuration presence; cron trigger and schedule; active beta/production overrides; and actual app backend environment. The inspection date above is not a deployment timestamp.

Terminology: a **batch** is a dated, environment-scoped set of 144 rows; a **row** is one Western/Eastern pair; **generator**, **validator**, and **publication** versions are recorded metadata; **production**, **beta**, and **development** are distinct content environments; **superseded** is the controlled replacement state for a published batch.

Stable facts are repository contracts and migrations. Observed versions, deployed functions, cron configuration, current batch state, and live routing are time-sensitive; this document does not treat them as permanent facts.
