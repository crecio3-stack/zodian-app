-- Recovered fresh-environment baseline for public.daily_rituals.
--
-- Evidence source: read-only pg_catalog inspection of production project
-- xyyahrqfmdblvonnaifi on 2026-07-13. This migration intentionally represents
-- the table immediately before the migrations dated 20260504, 20260512, and
-- 20260706. Do not add their later columns, comments, or composite uniqueness
-- constraint here.

create extension if not exists pgcrypto with schema extensions;

create table public.daily_rituals (
  id uuid primary key default gen_random_uuid(),
  ritual_date date not null,
  western_sign text not null,
  eastern_sign text not null,
  title text,
  ritual_text text not null,
  action_text text,
  model text,
  created_at timestamp with time zone default now()
);

alter table public.daily_rituals enable row level security;

grant select, insert, update, delete, truncate, references, trigger
  on table public.daily_rituals
  to anon, authenticated, service_role;
