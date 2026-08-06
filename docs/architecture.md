# Verified architecture

Inspected 2026-08-06. Diagrams describe repository architecture; live routing, applied migrations, and deployed versions remain unresolved.

## Components

- **Scheduler:** shared Los Angeles-time scheduler computes content date, acquires a generation lease, advances chunks, validates, and publishes at the permitted window.
- **Manager:** `manage-daily-ritual-batch` authenticates admin requests and owns batch actions, readiness, publication, corrective paths, and scheduler adapters.
- **Generator/writer/prompt:** `generate-daily-rituals` selects versioned generation paths; shared writers and prompt files produce structured output.
- **Provider transport:** provider-facing paths call the Responses API where configured; development/shadow paths have explicit server-side auth boundaries.
- **Validators:** row, writer, voice, compression, safety, diversity, JSON-shape, batch, and publication validators are version/path-specific.
- **Storage/contracts:** `daily_ritual_batches` and `daily_ritual_batch_rows`, lifecycle contracts, constraints, guards, and publication RPCs define persistence.
- **Reader:** `get-daily-ritual` selects published rows and returns the consumer envelope.
- **iOS:** Daily services route and cache responses; models decode the contract; Daily screens/presentation builders render the read and feedback.

## Generation flow

```text
scheduler -> manager -> batch contract -> generator -> writer/prompt -> provider
                                      \-> row metadata and staged rows
```

Verified in scheduler, manager, generator, and shared writer code. The live trigger and deployed routing are unresolved.

## Validation/publication flow

```text
staged rows -> row/writer validators -> publication validation -> READY
             -> database completeness/state guards -> publication RPC/path -> PUBLISHED
```

Verified by batch contract, migrations, manager validation, and publication code. Which migration set is applied live is unresolved.

## App read flow

```text
iOS Daily service/router -> get-daily-ritual -> published batch rows -> response models
                         -> cache/presentation -> Daily Lens screens
```

Verified in `Services/Daily/`, models, screens, and reader function. Live endpoint routing and environment selection are unresolved.

## Scheduler flow

```text
clock -> Los Angeles schedule context -> resolve batch -> lease/chunks
      -> validate/readiness -> midnight publication or retryable result
```

Verified in `midnight_scheduler.ts` and tests. Cron/provider deployment wiring is unresolved.
