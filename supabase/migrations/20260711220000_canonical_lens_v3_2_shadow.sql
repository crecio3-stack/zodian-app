-- Isolated, service-role-only storage for the manually invoked Canonical Lens v3.2 shadow cohort.
create table if not exists public.canonical_lens_shadow_generations (
  id uuid primary key default gen_random_uuid(),
  frozen_version text not null,
  generation_date date not null,
  western_sign text not null,
  eastern_sign text not null,
  identity_key text not null,
  scenario_id text not null,
  arena text not null,
  production_daily_ritual_id text,
  source_sha256 text not null,
  config_fingerprint text not null,
  provider text,
  model text,
  status text not null check (status in ('pending', 'running', 'accepted', 'rejected', 'failed')),
  provider_call_count integer not null default 0,
  schema_retry_count integer not null default 0,
  editorial_title_retry_count integer not null default 0,
  input_tokens bigint not null default 0,
  cached_input_tokens bigint not null default 0,
  output_tokens bigint not null default 0,
  reasoning_tokens bigint not null default 0,
  total_tokens bigint not null default 0,
  latency_ms integer,
  lens jsonb,
  attempt_log jsonb not null default '[]'::jsonb,
  validation_errors jsonb not null default '[]'::jsonb,
  error_code text,
  error_message text,
  lease_expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (frozen_version, generation_date, western_sign, eastern_sign, scenario_id)
);

create index if not exists canonical_lens_shadow_generations_identity_date_idx
  on public.canonical_lens_shadow_generations (identity_key, generation_date desc);
create index if not exists canonical_lens_shadow_generations_status_idx
  on public.canonical_lens_shadow_generations (status, created_at desc);

alter table public.canonical_lens_shadow_generations enable row level security;
-- Intentionally no policies: browser/anon/authenticated clients cannot read or write shadow rows.
