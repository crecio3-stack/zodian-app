# Identity Reasoning Engine v1

Development-only, two-stage identity content generation. This directory is not
read by the app and does not write to production identity data.

## Run

```sh
OPENAI_API_KEY=... deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/generate.ts --western Aries --chinese Rat \
  --output /tmp/aries-rat.json
```

The command makes two independent structured-output requests:

1. `reasonIdentity` creates an internal `IdentityReasoningPlan`.
2. `writeIdentity` consumes that plan and creates the seven reader-facing
   sections.

The plan is not included in the output unless `--debug-reasoning` is supplied.
Only the reviewed pairs (`Aries × Rat`, `Pisces × Horse`, and `Taurus × Horse`)
are accepted by default. Pass `--allow-unreviewed-pair` deliberately during
future development.

## Verify

```sh
deno test scripts/identity-reasoning/identity_engine_test.ts
```

`fixtures/libra-snake.editorial-benchmark.json` is an immutable editorial
benchmark. It is reference material, not model output, not production content,
and not a universal template.
