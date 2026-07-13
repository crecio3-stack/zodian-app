# Expected Schema After Seven-Migration Disposable Replay

This inventory is the expected result of replaying the recovered baseline plus the six existing migrations on an empty Supabase database. It is a review target, not evidence that replay has already occurred.

## `public.daily_rituals`

- 23 columns listed in the [production schema evidence report](production-candidate-v1-production-daily-rituals-schema-evidence-v1.md);
- primary key `daily_rituals_pkey` on `id`;
- composite unique constraint/index `daily_rituals_ritual_date_western_sign_eastern_sign_key`;
- RLS enabled; no policies, triggers, or foreign keys;
- grants to `anon`, `authenticated`, and `service_role` matching the evidence report.

## Canonical Lens v3.2 shadow isolation

- table `public.canonical_lens_shadow_generations`;
- indexes `canonical_lens_shadow_generations_identity_date_idx` and `canonical_lens_shadow_generations_status_idx`;
- RLS enabled with no policies;
- function `public.claim_canonical_lens_shadow_generation(...)`, revoked from `public`;
- no scheduled invocation, provider call, seed data, or production-table mutation.

## PCv1 candidate isolation

- table `public.production_candidate_v1_generations`;
- indexes `production_candidate_v1_generations_lookup_idx`, `production_candidate_v1_generations_status_idx`, and `production_candidate_v1_generations_control_idx`;
- RLS enabled with no policies;
- function `public.claim_production_candidate_v1_generation(...)`, revoked from `public`;
- no candidate title/read for any non-`ACCEPTED` row by the table check constraint;
- no reference or mutation of `public.daily_rituals` in the migration.

## No expected side effects

The seven reviewed migrations do not create schedules, jobs, provider calls, HTTP calls, secret access, deployment configuration, seed data, or external-system mutations. The only extension created by the recovered baseline is `pgcrypto`, required for `gen_random_uuid()`.
