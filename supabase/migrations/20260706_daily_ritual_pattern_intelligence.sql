alter table public.daily_rituals
  add column if not exists confidence numeric,
  add column if not exists reflection numeric,
  add column if not exists connection numeric,
  add column if not exists growth numeric,
  add column if not exists momentum numeric,
  add column if not exists primary_signal text,
  add column if not exists secondary_signal text,
  add column if not exists emotional_tone text,
  add column if not exists theme_tags text[];

comment on column public.daily_rituals.confidence is 'Optional Pattern Intelligence confidence score for this Daily Lens, normalized 0-1.';
comment on column public.daily_rituals.reflection is 'Optional Pattern Intelligence reflection score for this Daily Lens, normalized 0-1.';
comment on column public.daily_rituals.connection is 'Optional Pattern Intelligence connection score for this Daily Lens, normalized 0-1.';
comment on column public.daily_rituals.growth is 'Optional Pattern Intelligence growth score for this Daily Lens, normalized 0-1.';
comment on column public.daily_rituals.momentum is 'Optional Pattern Intelligence momentum score for this Daily Lens, normalized 0-1.';
comment on column public.daily_rituals.primary_signal is 'Optional primary Pattern Intelligence signal label for this Daily Lens.';
comment on column public.daily_rituals.secondary_signal is 'Optional secondary Pattern Intelligence signal label for this Daily Lens.';
comment on column public.daily_rituals.emotional_tone is 'Optional emotional tone label for Pattern Intelligence.';
comment on column public.daily_rituals.theme_tags is 'Optional Pattern Intelligence theme tags for this Daily Lens.';
