# Production `public.daily_rituals` Schema Evidence

Status: read-only evidence captured on 2026-07-13 from production project `xyyahrqfmdblvonnaifi`.

The query at [`production_daily_rituals_schema_evidence.sql`](../production_daily_rituals_schema_evidence.sql) used only PostgreSQL catalog views. It selected no `daily_rituals` rows and made no database changes. The returned catalog response had SHA-256 `d9d225ae91b9065ef61ecbcb55114c0a3bedfcfc535253ecad3264f7288c9895`.

## Table-level evidence

- Table: `public.daily_rituals`
- Table comment: none
- RLS: enabled, not forced
- Policies: none
- Foreign keys: none
- Triggers: none
- Column enum dependencies: none

## Current columns from production

| Ordinal | Column | Type | Nullability | Default | Provenance in replay chain |
|---:|---|---|---|---|---|
| 1 | `id` | `uuid` | not null | `gen_random_uuid()` | recovered baseline |
| 2 | `ritual_date` | `date` | not null | none | recovered baseline |
| 3 | `western_sign` | `text` | not null | none | recovered baseline |
| 4 | `eastern_sign` | `text` | not null | none | recovered baseline |
| 5 | `title` | `text` | nullable | none | recovered baseline |
| 6 | `ritual_text` | `text` | not null | none | recovered baseline |
| 7 | `action_text` | `text` | nullable | none | recovered baseline |
| 8 | `model` | `text` | nullable | none | recovered baseline |
| 9 | `created_at` | `timestamp with time zone` | nullable | `now()` | recovered baseline |
| 10–14 | `intro`, `pull_quote`, `deeper_read`, `watch_for`, `move` | `text` | nullable | none | `20260512_daily_ritual_structured_read.sql` |
| 15–23 | `confidence`, `reflection`, `connection`, `growth`, `momentum`, `primary_signal`, `secondary_signal`, `emotional_tone`, `theme_tags` | `numeric`, `text`, `text[]` as applicable | nullable | none | `20260706_daily_ritual_pattern_intelligence.sql` |

Production comments are absent from every recovered baseline column. The comments on all five structured-read and all nine Pattern Intelligence columns exactly match the two later migrations, so they are intentionally excluded from the baseline.

## Constraints and indexes

- `daily_rituals_pkey`: `PRIMARY KEY (id)`; its automatic unique btree index has the same name.
- `daily_rituals_ritual_date_western_sign_eastern_sign_key`: `UNIQUE (ritual_date, western_sign, eastern_sign)`; owned by `20260504_generate_daily_rituals_unique.sql`, not the baseline.
- No other indexes or constraints were reported.

## Grants and dependencies

- `anon`, `authenticated`, and `service_role` have `SELECT`, `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, `REFERENCES`, and `TRIGGER` privileges on the table.
- `postgres` is the owner with grantable privileges.
- The only non-built-in dependency required by the recovered definition is `pgcrypto` for `gen_random_uuid()`. Production reports it installed in schema `extensions`; the proposed baseline creates it idempotently in that schema.
- Other installed production extensions (`pg_cron`, `pg_net`, `pg_stat_statements`, `supabase_vault`, and `uuid-ossp`) are not required by this table definition and are intentionally not added to the baseline.

## Evidence boundary

This report describes the current production schema only. Provenance is assigned only where an existing migration demonstrably adds the object; anything else is the minimum recovered prerequisite. No app model, row data, or provider output was used as schema evidence.
