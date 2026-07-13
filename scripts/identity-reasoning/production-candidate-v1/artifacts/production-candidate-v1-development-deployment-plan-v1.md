# PCv1 development deployment and smoke-test plan

## Target guard

The only permitted target is **Zodian Development**:

```text
project ref: wlsewblvpyeanfganbkc
```

The workspace was linked to `xyyahrqfmdblvonnaifi` when this plan was created. That is the known production project and must not receive the PCv1 migration or function.

## Current blocker

`Zodian Development` is paused. The Supabase CLI refused to link it and left the local workspace linked to production. No deployment or live test has run.

An administrator must unpause the development project in the Supabase dashboard before continuing.

## Exact development-only procedure

Run these only after the project is unpaused:

```sh
cd /Users/ianrecio/Documents/Zodian
supabase link --project-ref wlsewblvpyeanfganbkc
test "$(tr -d '\n' < supabase/.temp/project-ref)" = "wlsewblvpyeanfganbkc"
supabase migration list
supabase db push --dry-run
```

Inspect the dry run. It must propose only:

```text
20260713090000_production_candidate_v1_isolated_storage.sql
```

Then create an internal endpoint secret without printing it and deploy only the migration and endpoint:

```sh
PCV1_INTERNAL_SECRET="$(openssl rand -hex 32)"
export PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET="$PCV1_INTERNAL_SECRET"
supabase secrets set PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET="$PCV1_INTERNAL_SECRET"
supabase db push
supabase functions deploy get-production-candidate-v1
```

Do not set an OpenAI key. This smoke test performs no model calls.

Run the guarded fixture test using the development service-role key and the same internal secret:

```sh
export SUPABASE_URL='https://wlsewblvpyeanfganbkc.supabase.co'
export SUPABASE_SERVICE_ROLE_KEY='development-service-role-key'
deno run --allow-env --allow-net --allow-read --allow-write \
  scripts/identity-reasoning/production-candidate-v1/run_development_integration_smoke.ts \
  --live-dev
```

The smoke runner rejects any other project reference or URL, snapshots `daily_rituals` before and after, seeds six explicit terminal/runtime fixtures plus one expired-lease fixture, verifies the endpoint and claims, then deletes only its synthetic candidate rows.

## Required live assertions

- Accepted response returns only version, status, title, and read.
- Every non-accepted state exposes status and a fixed safe reason only; no copy or trace fields.
- Unauthorized endpoint call returns `401`; internal-secret call succeeds.
- Accepted, blocked, rejected, and held records return existing records on duplicate claims.
- Transport failure and expired running lease are the only resumable cases.
- `daily_rituals` count and canonical snapshot hash are unchanged before and after.
- Synthetic candidate rows are deleted at completion.

## Rollback

Before any user exposure, rollback is non-disruptive:

1. Do not deploy a consumer or allowlist.
2. Disable the internal endpoint by removing its deployment or rotating/removing `PRODUCTION_CANDIDATE_V1_INTERNAL_SECRET` in development.
3. If required, revert only migration `20260713090000` in the development ledger with a separately reviewed, isolated rollback migration; never alter `daily_rituals`.

Production rollback is unnecessary because this procedure never targets or deploys to production.
