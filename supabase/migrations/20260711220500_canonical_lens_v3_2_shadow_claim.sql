-- Atomically claims a shadow key. Existing accepted work is returned as idempotent;
-- only expired leases or terminal failures may be reclaimed.
create or replace function public.claim_canonical_lens_shadow_generation(
  p_frozen_version text,
  p_generation_date date,
  p_western_sign text,
  p_eastern_sign text,
  p_identity_key text,
  p_scenario_id text,
  p_arena text,
  p_production_daily_ritual_id text,
  p_source_sha256 text,
  p_config_fingerprint text
) returns table (id uuid, status text, claimed boolean)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  with claimed_row as (
    insert into public.canonical_lens_shadow_generations (
      frozen_version, generation_date, western_sign, eastern_sign, identity_key,
      scenario_id, arena, production_daily_ritual_id, source_sha256,
      config_fingerprint, status, lease_expires_at
    ) values (
      p_frozen_version, p_generation_date, p_western_sign, p_eastern_sign,
      p_identity_key, p_scenario_id, p_arena, p_production_daily_ritual_id,
      p_source_sha256, p_config_fingerprint, 'running', now() + interval '10 minutes'
    ) on conflict (frozen_version, generation_date, western_sign, eastern_sign, scenario_id)
    do update set
      status = 'running',
      production_daily_ritual_id = excluded.production_daily_ritual_id,
      lease_expires_at = now() + interval '10 minutes',
      updated_at = now(),
      error_code = null,
      error_message = null
    where canonical_lens_shadow_generations.status in ('failed', 'rejected')
      or (canonical_lens_shadow_generations.status in ('pending', 'running')
        and (canonical_lens_shadow_generations.lease_expires_at is null
          or canonical_lens_shadow_generations.lease_expires_at < now()))
    returning canonical_lens_shadow_generations.id, canonical_lens_shadow_generations.status
  )
  select claimed_row.id, claimed_row.status, true from claimed_row;

  if found then return; end if;

  return query
  select row.id, row.status, false
  from public.canonical_lens_shadow_generations row
  where row.frozen_version = p_frozen_version
    and row.generation_date = p_generation_date
    and row.western_sign = p_western_sign
    and row.eastern_sign = p_eastern_sign
    and row.scenario_id = p_scenario_id;
end;
$$;

revoke all on function public.claim_canonical_lens_shadow_generation(text, date, text, text, text, text, text, text, text, text) from public;
