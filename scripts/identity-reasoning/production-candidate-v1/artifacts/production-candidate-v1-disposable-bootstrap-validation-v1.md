# Disposable Bootstrap Validation Instructions

This procedure is development-only. It must be run from a disposable local Supabase database after Docker is available. It does not push to Zodian Development or production.

1. Confirm Docker is running:

   ```sh
   docker info
   ```

2. From a disposable checkout of `/Users/ianrecio/Documents/Zodian`, start the local Supabase stack and replay the migration ledger from empty state:

   ```sh
   supabase start
   supabase db reset --local
   ```

3. Capture only catalog metadata for the replayed table using the same no-row query used for production:

   ```sh
   supabase db query --local \
     --file scripts/identity-reasoning/production-candidate-v1/production_daily_rituals_schema_evidence.sql \
     --output json
   ```

4. Compare the replayed `public.daily_rituals` metadata with the production evidence report:

   - 23 columns with the exact names, types, nullability, and defaults recorded there;
   - only `daily_rituals_pkey` and `daily_rituals_ritual_date_western_sign_eastern_sign_key` constraints/indexes;
   - RLS enabled, no policies, no triggers, no foreign keys;
   - expected grants for `anon`, `authenticated`, and `service_role`.

5. Verify the isolated objects also exist and remain inert:

   - `canonical_lens_shadow_generations`, its two indexes, RLS, and claim function;
   - `production_candidate_v1_generations`, its three indexes, RLS, and claim function;
   - no schedules, provider invocations, seed rows, or generated candidate/ritual content.

6. Run the provider-free static composition check again:

   ```sh
   deno run --allow-read --allow-write \
     scripts/identity-reasoning/production-candidate-v1/validate_daily_rituals_baseline.ts
   ```

7. Only after every comparison is understood may the development project be reconsidered for `supabase db push --dry-run`. Do not use migration repair or selectively apply PCv1.

## Rollback/reset

The local validation environment is disposable. If any migration fails or the schema diverges, stop, preserve the error and catalog output, then run `supabase stop` and discard/reset the local environment. Do not use a failed replay as a basis for a remote migration repair.
