# Canonical Lens v3.2 manual shadow cohort

This is an admin-only, manually invoked comparison path. It has no scheduler and
no production read path.

The caller must supply a frozen scenario ID explicitly. No date rotation, modulo
selection, production-theme reuse, or production-copy inference exists here.

Automatic scheduling is intentionally deferred. A future deterministic
date-to-scenario policy requires separate editorial design and approval.

## Required server configuration

- `CANONICAL_LENS_V3_2_SHADOW_ENABLED=true`
- `CANONICAL_LENS_V3_2_SHADOW_MODE=allowlist`
- `CANONICAL_LENS_V3_2_SHADOW_ALLOWLIST=Libra|Snake,Taurus|Horse,Sagittarius|Monkey`
- `CANONICAL_LENS_V3_2_SHADOW_ADMIN_SECRET=<new-long-random-secret>`
- `CANONICAL_LENS_V3_2_SOURCE_SHA256=d43433b9bf72d56d85b9d6ab4b9614fe5a004c07b57e9139e4bb836dea093ffe`
- `CANONICAL_LENS_V3_2_RUNTIME_SHA256=bf88e66dd8ebfb5977e6223edd73bf12574317c7248c5e553380f11a14d32d4d`
- `OPENAI_IDENTITY_LENS_MODEL=gpt-5.6-terra`

`SUPABASE_URL`, a service-role key, and `OPENAI_API_KEY` are also required by the
deployed function. Keep the default disabled until a deliberate manual cohort run.
