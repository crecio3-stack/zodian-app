-- Read-only production schema evidence for public.daily_rituals.
-- This file intentionally selects catalog metadata only; it never selects table rows.
with target as (
  select c.oid as table_oid
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname = 'daily_rituals' and c.relkind = 'r'
)
select jsonb_build_object(
  'table', (
    select jsonb_build_object(
      'schema', n.nspname,
      'name', c.relname,
      'comment', obj_description(c.oid, 'pg_class'),
      'rls_enabled', c.relrowsecurity,
      'rls_forced', c.relforcerowsecurity
    )
    from target t
    join pg_class c on c.oid = t.table_oid
    join pg_namespace n on n.oid = c.relnamespace
  ),
  'columns', coalesce((
    select jsonb_agg(jsonb_build_object(
      'ordinal', a.attnum,
      'name', a.attname,
      'type', pg_catalog.format_type(a.atttypid, a.atttypmod),
      'not_null', a.attnotnull,
      'default', pg_get_expr(ad.adbin, ad.adrelid),
      'identity', a.attidentity,
      'generated', a.attgenerated,
      'comment', col_description(a.attrelid, a.attnum)
    ) order by a.attnum)
    from target t
    join pg_attribute a on a.attrelid = t.table_oid
    left join pg_attrdef ad on ad.adrelid = a.attrelid and ad.adnum = a.attnum
    where a.attnum > 0 and not a.attisdropped
  ), '[]'::jsonb),
  'constraints', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', con.conname,
      'type', con.contype,
      'definition', pg_get_constraintdef(con.oid, true),
      'comment', obj_description(con.oid, 'pg_constraint')
    ) order by con.conname)
    from target t
    join pg_constraint con on con.conrelid = t.table_oid
  ), '[]'::jsonb),
  'indexes', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', idx.relname,
      'definition', pg_get_indexdef(idx.oid),
      'comment', obj_description(idx.oid, 'pg_class')
    ) order by idx.relname)
    from target t
    join pg_index i on i.indrelid = t.table_oid
    join pg_class idx on idx.oid = i.indexrelid
  ), '[]'::jsonb),
  'policies', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', pol.polname,
      'command', pol.polcmd,
      'permissive', pol.polpermissive,
      'roles', array_to_string(pol.polroles::regrole[], ', '),
      'using', pg_get_expr(pol.polqual, pol.polrelid),
      'with_check', pg_get_expr(pol.polwithcheck, pol.polrelid)
    ) order by pol.polname)
    from target t
    join pg_policy pol on pol.polrelid = t.table_oid
  ), '[]'::jsonb),
  'grants', coalesce((
    select jsonb_agg(jsonb_build_object(
      'grantee', privilege.grantee,
      'privilege_type', privilege.privilege_type,
      'is_grantable', privilege.is_grantable
    ) order by privilege.grantee, privilege.privilege_type)
    from target t
    join information_schema.role_table_grants privilege
      on privilege.table_schema = 'public' and privilege.table_name = 'daily_rituals'
  ), '[]'::jsonb),
  'triggers', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', trg.tgname,
      'definition', pg_get_triggerdef(trg.oid, true),
      'function_schema', fn_ns.nspname,
      'function_name', fn.proname,
      'function_definition', pg_get_functiondef(fn.oid)
    ) order by trg.tgname)
    from target t
    join pg_trigger trg on trg.tgrelid = t.table_oid and not trg.tgisinternal
    join pg_proc fn on fn.oid = trg.tgfoid
    join pg_namespace fn_ns on fn_ns.oid = fn.pronamespace
  ), '[]'::jsonb),
  'type_dependencies', coalesce((
    select jsonb_agg(jsonb_build_object(
      'column', a.attname,
      'type_schema', type_ns.nspname,
      'type_name', typ.typname,
      'type_kind', typ.typtype,
      'type_category', typ.typcategory,
      'enum_labels', enum_values.labels
    ) order by a.attnum)
    from target t
    join pg_attribute a on a.attrelid = t.table_oid and a.attnum > 0 and not a.attisdropped
    join pg_type typ on typ.oid = a.atttypid
    join pg_namespace type_ns on type_ns.oid = typ.typnamespace
    left join lateral (
      select jsonb_agg(e.enumlabel order by e.enumsortorder) as labels
      from pg_enum e
      where e.enumtypid = typ.oid
    ) enum_values on true
  ), '[]'::jsonb),
  'extensions', coalesce((
    select jsonb_agg(jsonb_build_object('name', ext.extname, 'schema', ext_ns.nspname) order by ext.extname)
    from pg_extension ext
    join pg_namespace ext_ns on ext_ns.oid = ext.extnamespace
  ), '[]'::jsonb)
) as daily_rituals_schema_evidence;
