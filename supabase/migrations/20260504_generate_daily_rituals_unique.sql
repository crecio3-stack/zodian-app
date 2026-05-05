do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'daily_rituals_ritual_date_western_sign_eastern_sign_key'
      and conrelid = 'public.daily_rituals'::regclass
  ) then
    if exists (
      select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where c.relname = 'daily_rituals_ritual_date_western_sign_eastern_sign_key'
        and n.nspname = 'public'
        and c.relkind = 'i'
    ) then
      alter table public.daily_rituals
        add constraint daily_rituals_ritual_date_western_sign_eastern_sign_key
        unique using index daily_rituals_ritual_date_western_sign_eastern_sign_key;
    else
      alter table public.daily_rituals
        add constraint daily_rituals_ritual_date_western_sign_eastern_sign_key
        unique (ritual_date, western_sign, eastern_sign);
    end if;
  end if;
end
$$;
