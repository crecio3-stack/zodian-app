# `daily_rituals` Baseline-versus-Later-Migrations Decomposition

## Recovered baseline — `20260503090000_daily_rituals_baseline.sql`

Creates only the prerequisites present before the known migration chain:

- `pgcrypto` extension in `extensions` for `gen_random_uuid()`;
- `public.daily_rituals` with `id`, `ritual_date`, `western_sign`, `eastern_sign`, `title`, `ritual_text`, `action_text`, `model`, and `created_at`;
- primary key on `id`;
- RLS enabled with no policies;
- production-equivalent table grants for `anon`, `authenticated`, and `service_role`.

It intentionally does **not** create a composite identity/date uniqueness constraint, structured-read columns, Pattern Intelligence columns, later column comments, triggers, policies, foreign keys, rows, schedules, or provider integrations.

## Existing migration ownership

| Migration | Objects it owns after the recovered baseline |
|---|---|
| `20260504_generate_daily_rituals_unique.sql` | `UNIQUE (ritual_date, western_sign, eastern_sign)` only |
| `20260512_daily_ritual_structured_read.sql` | `intro`, `pull_quote`, `deeper_read`, `watch_for`, `move`, plus their comments |
| `20260706_daily_ritual_pattern_intelligence.sql` | nine Pattern Intelligence columns and their comments |
| `20260711220000_canonical_lens_v3_2_shadow.sql` | independent shadow table and two indexes; RLS with no policies |
| `20260711220500_canonical_lens_v3_2_shadow_claim.sql` | shadow claim function; depends only on the preceding shadow table |
| `20260713090000_production_candidate_v1_isolated_storage.sql` | independent PCv1 candidate table, three indexes, and claim function; RLS with no policies |

## Missing-history finding

The repository contained no migration that creates `public.daily_rituals`; this is the only unmet prerequisite found in the seven-migration bootstrap chain. The recovered baseline closes that gap. A disposable replay is still required to prove that no unrecorded dependency exists outside the checked migration set.
