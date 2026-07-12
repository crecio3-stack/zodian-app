alter table public.daily_rituals
  add column if not exists intro text,
  add column if not exists pull_quote text,
  add column if not exists deeper_read text,
  add column if not exists watch_for text,
  add column if not exists move text;

comment on column public.daily_rituals.intro is 'Daily Read opening emotional-weather line.';
comment on column public.daily_rituals.pull_quote is 'Daily Read sharp insight or twist.';
comment on column public.daily_rituals.deeper_read is 'Daily Read deeper editorial explanation.';
comment on column public.daily_rituals.watch_for is 'Daily Read observable signal.';
comment on column public.daily_rituals.move is 'Daily Read grounded behavior.';
