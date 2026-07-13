-- Development-only, isolated storage for Production Candidate v1.
-- This migration intentionally does not alter public.daily_rituals.
create table if not exists public.production_candidate_v1_generations (
  id uuid primary key default gen_random_uuid(),
  candidate_version text not null,
  candidate_date date not null,
  western_sign text not null,
  eastern_sign text not null,
  source_context text not null,
  control_daily_ritual_id text,
  status text not null check (status in (
    'RUNNING',
    'ACCEPTED',
    'BLOCKED',
    'WRITER_REJECTED',
    'VALIDATOR_REJECTED',
    'TRANSPORT_FAILED',
    'REPETITION_HOLD'
  )),
  candidate_title text,
  candidate_read text,
  selector_eligibility text check (
    selector_eligibility is null
    or selector_eligibility in ('ELIGIBLE', 'INELIGIBLE')
  ),
  selector_fingerprint text,
  writer_prompt_fingerprint text,
  validator_fingerprint text,
  repetition_fingerprint text,
  provider text,
  model text,
  configuration_fingerprint text,
  provider_call_count integer not null default 0 check (provider_call_count >= 0),
  input_tokens bigint not null default 0 check (input_tokens >= 0),
  output_tokens bigint not null default 0 check (output_tokens >= 0),
  total_tokens bigint not null default 0 check (total_tokens >= 0),
  latency_ms integer check (latency_ms is null or latency_ms >= 0),
  estimated_cost_usd numeric(12, 6) check (estimated_cost_usd is null or estimated_cost_usd >= 0),
  selector_trace jsonb,
  writer_trace jsonb,
  validator_trace jsonb,
  validator_rejection_reasons jsonb not null default '[]'::jsonb,
  repetition_disposition text check (
    repetition_disposition is null
    or repetition_disposition in ('ALLOW', 'HOLD', 'BLOCK')
  ),
  repetition_trace jsonb,
  error_code text,
  lease_expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (candidate_version, candidate_date, western_sign, eastern_sign, source_context),
  check (
    (status = 'ACCEPTED'
      and length(trim(candidate_title)) > 0
      and length(trim(candidate_read)) > 0)
    or
    (status <> 'ACCEPTED'
      and candidate_title is null
      and candidate_read is null)
  )
);

create index if not exists production_candidate_v1_generations_lookup_idx
  on public.production_candidate_v1_generations (
    candidate_version,
    candidate_date desc,
    western_sign,
    eastern_sign,
    source_context
  );
create index if not exists production_candidate_v1_generations_status_idx
  on public.production_candidate_v1_generations (status, created_at desc);
create index if not exists production_candidate_v1_generations_control_idx
  on public.production_candidate_v1_generations (control_daily_ritual_id)
  where control_daily_ritual_id is not null;

alter table public.production_candidate_v1_generations enable row level security;
-- Intentionally no policies. Client roles cannot read or write PCv1 candidate data.

-- Atomically claims a candidate key. Accepted, blocked, rejected, and held rows
-- are immutable for this version. Only a transport failure or an expired lease can
-- resume generation under the same deterministic key.
create or replace function public.claim_production_candidate_v1_generation(
  p_candidate_version text,
  p_candidate_date date,
  p_western_sign text,
  p_eastern_sign text,
  p_source_context text,
  p_control_daily_ritual_id text,
  p_selector_fingerprint text,
  p_writer_prompt_fingerprint text,
  p_validator_fingerprint text,
  p_repetition_fingerprint text,
  p_configuration_fingerprint text
) returns table (id uuid, status text, claimed boolean)
language plpgsql
security definer
set search_path = public
as $$
begin
  return query
  with claimed_row as (
    insert into public.production_candidate_v1_generations (
      candidate_version,
      candidate_date,
      western_sign,
      eastern_sign,
      source_context,
      control_daily_ritual_id,
      status,
      selector_fingerprint,
      writer_prompt_fingerprint,
      validator_fingerprint,
      repetition_fingerprint,
      configuration_fingerprint,
      lease_expires_at
    ) values (
      p_candidate_version,
      p_candidate_date,
      p_western_sign,
      p_eastern_sign,
      p_source_context,
      p_control_daily_ritual_id,
      'RUNNING',
      p_selector_fingerprint,
      p_writer_prompt_fingerprint,
      p_validator_fingerprint,
      p_repetition_fingerprint,
      p_configuration_fingerprint,
      now() + interval '10 minutes'
    ) on conflict (candidate_version, candidate_date, western_sign, eastern_sign, source_context)
    do update set
      status = 'RUNNING',
      control_daily_ritual_id = excluded.control_daily_ritual_id,
      selector_fingerprint = excluded.selector_fingerprint,
      writer_prompt_fingerprint = excluded.writer_prompt_fingerprint,
      validator_fingerprint = excluded.validator_fingerprint,
      repetition_fingerprint = excluded.repetition_fingerprint,
      configuration_fingerprint = excluded.configuration_fingerprint,
      lease_expires_at = now() + interval '10 minutes',
      updated_at = now(),
      error_code = null
    where public.production_candidate_v1_generations.status = 'TRANSPORT_FAILED'
      or (
        public.production_candidate_v1_generations.status = 'RUNNING'
        and (
          public.production_candidate_v1_generations.lease_expires_at is null
          or public.production_candidate_v1_generations.lease_expires_at < now()
        )
      )
    returning public.production_candidate_v1_generations.id,
      public.production_candidate_v1_generations.status
  )
  select claimed_row.id, claimed_row.status, true from claimed_row;

  if found then return; end if;

  return query
  select row.id, row.status, false
  from public.production_candidate_v1_generations row
  where row.candidate_version = p_candidate_version
    and row.candidate_date = p_candidate_date
    and row.western_sign = p_western_sign
    and row.eastern_sign = p_eastern_sign
    and row.source_context = p_source_context;
end;
$$;

revoke all on function public.claim_production_candidate_v1_generation(
  text, date, text, text, text, text, text, text, text, text, text
) from public;
