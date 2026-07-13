# PCv1 development bootstrap readiness audit

**Decision: BLOCKED**

The empty Zodian Development ledger cannot be bootstrapped from the six local migrations. The repository has no migration that creates `public.daily_rituals`, while the first three migrations alter or constrain that table.

## Dependency graph

`missing daily_rituals creation baseline → 20260504 → 20260512 → 20260706`

`20260711220000 → 20260711220500`

`20260713090000` is structurally independent of `daily_rituals`.

## Side effects

No reviewed migration schedules work, invokes a provider, accesses secrets, seeds data, or mutates an external system. The shadow and PCv1 tables are inert without separately deployed functions or schedulers.

## Missing history

The base `daily_rituals` creation migration is absent. Do not use migration repair, mark history applied, or selectively push PCv1 to compensate.

## Local validation

A disposable local Supabase run was not possible because Docker is unavailable in this workspace. Static review is sufficient to identify the missing prerequisite but cannot certify a fresh bootstrap.

## Required resolution

1. Recover or author and review the missing base migration.
2. Validate the complete chain on a disposable database.
3. Re-run the development dry run before any deployment.
