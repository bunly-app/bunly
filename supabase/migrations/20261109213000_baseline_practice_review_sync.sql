-- Baseline v1 database extensions for shared practice questions, immutable attempts,
-- deterministic spaced-repetition review state, multi-device personal record revisions,
-- idempotent sync receipts, and safe authenticated quota inspection.
-- Target: LOCAL PostgreSQL development/testing only (do not push without explicit target).

-- 1. Curated question bank (read-only for authenticated clients).
create table public.practice_questions (
  id uuid primary key default gen_random_uuid(),
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  content_version integer not null default 1 check (content_version >= 1),
  question_type text not null check (question_type in ('mcq', 'cloze')),
  prompt text not null check (char_length(btrim(prompt)) between 1 and 1000),
  options jsonb,
  correct_option_index integer check (
    correct_option_index is null or correct_option_index between 0 and 3
  ),
  accepted_answers jsonb,
  normalization text not null default 'trim_only' check (normalization in ('trim_only')),
  explanation_vi text not null check (char_length(btrim(explanation_vi)) between 1 and 2000),
  updated_at timestamptz not null default now(),
  check (
    (
      question_type = 'mcq'
      and options is not null
      and jsonb_typeof(options) = 'array'
      and jsonb_array_length(options) = 4
      and correct_option_index is not null
      and accepted_answers is null
    )
    or
    (
      question_type = 'cloze'
      and accepted_answers is not null
      and jsonb_typeof(accepted_answers) = 'array'
      and jsonb_array_length(accepted_answers) >= 1
      and options is null
      and correct_option_index is null
    )
  )
);

create index practice_questions_grammar_version_idx
  on public.practice_questions (grammar_id, content_version);

revoke all on table public.practice_questions from anon, authenticated;
grant select on table public.practice_questions to authenticated;
alter table public.practice_questions enable row level security;
create policy read_questions on public.practice_questions
  for select to authenticated using (true);
create trigger set_updated_at before update on public.practice_questions
  for each row execute function public.set_updated_at();

-- 2. Immutable per-user practice attempts with canonical server receipt time.
create table public.practice_attempts (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  question_id uuid not null references public.practice_questions(id) on delete cascade,
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  content_version integer not null check (content_version >= 1),
  session_id uuid not null,
  retry_of uuid check (retry_of is null or retry_of <> id),
  answer_text text not null default '' check (char_length(answer_text) <= 500),
  selected_option_index integer check (
    selected_option_index is null or selected_option_index between 0 and 3
  ),
  is_correct boolean not null,
  is_skipped boolean not null default false,
  is_first_independent boolean not null,
  attempted_at timestamptz not null,
  server_received_at timestamptz not null default clock_timestamp(),
  check (not (is_skipped and is_correct)),
  check (not (is_skipped and is_first_independent))
);

create unique index practice_attempts_first_eligible_idx
  on public.practice_attempts (user_id, session_id, question_id)
  where (is_first_independent);
create index practice_attempts_canonical_idx
  on public.practice_attempts (user_id, grammar_id, server_received_at, id);
create index practice_attempts_question_idx
  on public.practice_attempts (question_id);
create index practice_attempts_grammar_idx
  on public.practice_attempts (grammar_id);

create function public.stamp_practice_attempt() returns trigger
language plpgsql set search_path = '' as $$
declare
  v_grammar_id uuid;
  v_content_version integer;
begin
  select q.grammar_id, q.content_version
  into v_grammar_id, v_content_version
  from public.practice_questions q
  where q.id = new.question_id;

  if not found then
    raise exception 'unknown_question' using errcode = '22023';
  end if;
  if v_grammar_id <> new.grammar_id or v_content_version <> new.content_version then
    raise exception 'question_metadata_mismatch' using errcode = '22023';
  end if;

  -- Client timestamp is metadata only; canonical receipt time is server-assigned.
  new.server_received_at := pg_catalog.clock_timestamp();
  return new;
end;
$$;
revoke execute on function public.stamp_practice_attempt() from public, anon, authenticated;
create trigger stamp_practice_attempt_before_insert
  before insert on public.practice_attempts
  for each row execute function public.stamp_practice_attempt();

revoke all on table public.practice_attempts from anon, authenticated;
grant select, insert on table public.practice_attempts to authenticated;
alter table public.practice_attempts enable row level security;
create policy own_select on public.practice_attempts
  for select to authenticated using ((select auth.uid()) = user_id);
create policy own_insert on public.practice_attempts
  for insert to authenticated with check ((select auth.uid()) = user_id);

-- 3. Server-derived spaced-repetition state ordered by (server_received_at, id).
create table public.review_states (
  user_id uuid not null references auth.users(id) on delete cascade,
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  stage integer not null default -1 check (stage between -1 and 4),
  due_at timestamptz,
  algorithm_version integer not null default 1 check (algorithm_version >= 1),
  last_attempt_id uuid references public.practice_attempts(id) on delete set null,
  last_server_received_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, grammar_id),
  check ((stage = -1) = (due_at is null))
);

create index review_states_user_due_idx on public.review_states (user_id, due_at);
create index review_states_grammar_idx on public.review_states (grammar_id);
create index review_states_last_attempt_idx on public.review_states (last_attempt_id);

create function public.apply_practice_attempt_to_review() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_stage integer := -1;
  v_days integer := 1;
  v_due_at timestamptz := null;
  v_last_attempt_id uuid := null;
  v_last_received_at timestamptz := null;
  v_attempt record;
begin
  if not new.is_first_independent or new.is_skipped then
    return null;
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('review:' || new.user_id::text || ':' || new.grammar_id::text, 0)
  );

  for v_attempt in
    select a.id, a.is_correct, a.server_received_at
    from public.practice_attempts a
    where a.user_id = new.user_id
      and a.grammar_id = new.grammar_id
      and a.is_first_independent
      and not a.is_skipped
    order by a.server_received_at asc, a.id asc
  loop
    if v_attempt.is_correct then
      if v_stage = -1 then
        v_stage := 0;
      else
        v_stage := least(v_stage + 1, 4);
      end if;
    else
      v_stage := 0;
    end if;
    v_days := case v_stage
      when 0 then 1
      when 1 then 3
      when 2 then 7
      when 3 then 14
      else 30
    end;
    v_due_at := (((v_attempt.server_received_at at time zone 'UTC')::date + v_days)::timestamp at time zone 'UTC');
    v_last_attempt_id := v_attempt.id;
    v_last_received_at := v_attempt.server_received_at;
  end loop;

  if v_last_attempt_id is not null then
    insert into public.review_states (
      user_id, grammar_id, stage, due_at, algorithm_version,
      last_attempt_id, last_server_received_at, updated_at
    )
    values (
      new.user_id, new.grammar_id, v_stage, v_due_at, 1,
      v_last_attempt_id, v_last_received_at, pg_catalog.clock_timestamp()
    )
    on conflict (user_id, grammar_id) do update
    set stage = excluded.stage,
        due_at = excluded.due_at,
        algorithm_version = excluded.algorithm_version,
        last_attempt_id = excluded.last_attempt_id,
        last_server_received_at = excluded.last_server_received_at,
        updated_at = excluded.updated_at;
  end if;
  return null;
end;
$$;
revoke execute on function public.apply_practice_attempt_to_review() from public, anon, authenticated;
create trigger practice_attempt_updates_review_state
  after insert on public.practice_attempts
  for each row execute function public.apply_practice_attempt_to_review();

revoke all on table public.review_states from anon, authenticated;
grant select on table public.review_states to authenticated;
alter table public.review_states enable row level security;
create policy own_select on public.review_states
  for select to authenticated using ((select auth.uid()) = user_id);

-- 4. Multi-device monotonic revisions & idempotent operation receipts without
-- breaking M2 positional table contracts on profiles, saved_grammar, notes, progress.
create table public.record_revisions (
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_table text not null check (entity_table in ('profiles', 'saved_grammar', 'notes', 'progress')),
  record_id text not null check (char_length(btrim(record_id)) > 0),
  revision bigint not null default 1 check (revision >= 1),
  deleted_at timestamptz,
  updated_at timestamptz not null default now(),
  primary key (user_id, entity_table, record_id)
);

revoke all on table public.record_revisions from anon, authenticated;
grant select on table public.record_revisions to authenticated;
alter table public.record_revisions enable row level security;
create policy own_select on public.record_revisions
  for select to authenticated using ((select auth.uid()) = user_id);

create table public.sync_operation_receipts (
  user_id uuid not null references auth.users(id) on delete cascade,
  operation_id uuid not null,
  entity_table text not null check (entity_table in ('profiles', 'saved_grammar', 'notes', 'progress')),
  record_id text not null check (char_length(btrim(record_id)) > 0),
  resulting_revision bigint not null check (resulting_revision >= 1),
  response_payload jsonb not null,
  created_at timestamptz not null default clock_timestamp(),
  primary key (user_id, operation_id)
);

revoke all on table public.sync_operation_receipts from anon, authenticated;
grant select, insert on table public.sync_operation_receipts to authenticated;
alter table public.sync_operation_receipts enable row level security;
create policy own_select on public.sync_operation_receipts
  for select to authenticated using ((select auth.uid()) = user_id);
create policy own_insert on public.sync_operation_receipts
  for insert to authenticated with check ((select auth.uid()) = user_id);

-- Backfill initial revision for pre-existing personal rows.
insert into public.record_revisions (user_id, entity_table, record_id, revision, deleted_at, updated_at)
select p.user_id, 'profiles', p.user_id::text, 1, null, p.updated_at
from public.profiles p
on conflict (user_id, entity_table, record_id) do nothing;

insert into public.record_revisions (user_id, entity_table, record_id, revision, deleted_at, updated_at)
select s.user_id, 'saved_grammar', s.grammar_id::text, 1, s.deleted_at, s.updated_at
from public.saved_grammar s
on conflict (user_id, entity_table, record_id) do nothing;

insert into public.record_revisions (user_id, entity_table, record_id, revision, deleted_at, updated_at)
select n.user_id, 'notes', n.id::text, 1, n.deleted_at, n.updated_at
from public.notes n
on conflict (user_id, entity_table, record_id) do nothing;

insert into public.record_revisions (user_id, entity_table, record_id, revision, deleted_at, updated_at)
select g.user_id, 'progress', g.grammar_id::text, 1, null, g.updated_at
from public.progress g
on conflict (user_id, entity_table, record_id) do nothing;

create function public.track_record_revision() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_row jsonb;
  v_user_id uuid;
  v_record_id text;
  v_deleted_at timestamptz;
begin
  v_row := case when tg_op = 'DELETE' then pg_catalog.to_jsonb(old) else pg_catalog.to_jsonb(new) end;
  v_user_id := (v_row->>'user_id')::uuid;
  v_record_id := case tg_table_name
    when 'profiles' then v_row->>'user_id'
    when 'notes' then v_row->>'id'
    else v_row->>'grammar_id'
  end;
  v_deleted_at := case
    when tg_op = 'DELETE' then pg_catalog.clock_timestamp()
    when v_row ? 'deleted_at' and v_row->>'deleted_at' is not null then (v_row->>'deleted_at')::timestamptz
    else null
  end;

  if tg_op = 'DELETE' then
    update public.record_revisions
    set revision = revision + 1,
        deleted_at = v_deleted_at,
        updated_at = pg_catalog.clock_timestamp()
    where user_id = v_user_id
      and entity_table = tg_table_name
      and record_id = v_record_id;
  else
    insert into public.record_revisions (user_id, entity_table, record_id, revision, deleted_at, updated_at)
    values (v_user_id, tg_table_name, v_record_id, 1, v_deleted_at, pg_catalog.clock_timestamp())
    on conflict (user_id, entity_table, record_id) do update
    set revision = public.record_revisions.revision + 1,
        deleted_at = excluded.deleted_at,
        updated_at = excluded.updated_at;
  end if;
  return null;
end;
$$;
revoke execute on function public.track_record_revision() from public, anon, authenticated;

create trigger track_profiles_revision
  after insert or update or delete on public.profiles
  for each row execute function public.track_record_revision();
create trigger track_saved_grammar_revision
  after insert or update or delete on public.saved_grammar
  for each row execute function public.track_record_revision();
create trigger track_notes_revision
  after insert or update or delete on public.notes
  for each row execute function public.track_record_revision();
create trigger track_progress_revision
  after insert or update or delete on public.progress
  for each row execute function public.track_record_revision();

create function public.bunly_sync_personal_record(
  p_operation_id uuid,
  p_entity_table text,
  p_record_id text,
  p_base_revision bigint,
  p_delete boolean default false,
  p_payload jsonb default '{}'::jsonb
) returns jsonb
language plpgsql security invoker set search_path = '' as $$
declare
  v_uid uuid := (select auth.uid());
  v_record_uuid uuid;
  v_receipt public.sync_operation_receipts%rowtype;
  v_current_rev bigint := 0;
  v_next_rev bigint;
  v_server_row jsonb := null;
  v_updated_row jsonb := null;
  v_grammar_uuid uuid;
begin
  if v_uid is null then
    raise exception 'unauthenticated' using errcode = '42501';
  end if;
  if p_operation_id is null
    or p_entity_table is null
    or p_entity_table not in ('profiles', 'saved_grammar', 'notes', 'progress')
    or p_record_id is null
    or p_base_revision is null
    or p_base_revision < 0 then
    raise exception 'invalid_input' using errcode = '22023';
  end if;
  v_record_uuid := p_record_id::uuid;
  if p_entity_table = 'profiles' and v_record_uuid <> v_uid then
    raise exception 'forbidden_profile_owner' using errcode = '42501';
  end if;
  if p_delete and p_entity_table in ('profiles', 'progress') then
    raise exception 'delete_not_supported' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('sync:' || v_uid::text || ':' || p_entity_table || ':' || p_record_id, 0)
  );

  select * into v_receipt
  from public.sync_operation_receipts r
  where r.user_id = v_uid and r.operation_id = p_operation_id;
  if found then
    return jsonb_build_object(
      'status', 'duplicate_ack',
      'revision', v_receipt.resulting_revision,
      'record', v_receipt.response_payload
    );
  end if;

  select r.revision into v_current_rev
  from public.record_revisions r
  where r.user_id = v_uid
    and r.entity_table = p_entity_table
    and r.record_id = p_record_id;
  if not found then
    v_current_rev := 0;
  end if;

  v_server_row := case p_entity_table
    when 'profiles' then (
      select pg_catalog.to_jsonb(p.*) from public.profiles p where p.user_id = v_uid
    )
    when 'saved_grammar' then (
      select pg_catalog.to_jsonb(s.*) from public.saved_grammar s where s.user_id = v_uid and s.grammar_id = v_record_uuid
    )
    when 'notes' then (
      select pg_catalog.to_jsonb(n.*) from public.notes n where n.id = v_record_uuid and n.user_id = v_uid
    )
    else (
      select pg_catalog.to_jsonb(g.*) from public.progress g where g.user_id = v_uid and g.grammar_id = v_record_uuid
    )
  end;

  if v_server_row is not null and v_current_rev = 0 then
    v_current_rev := 1;
  end if;

  if p_base_revision <> v_current_rev then
    return jsonb_build_object(
      'status', 'conflict',
      'current_revision', v_current_rev,
      'server_record', v_server_row
    );
  end if;

  if p_entity_table = 'profiles' then
    insert into public.profiles (user_id, display_name, jlpt_level, goal, daily_minutes)
    values (
      v_uid,
      coalesce(p_payload->>'display_name', ''),
      coalesce(p_payload->>'jlpt_level', 'N5'),
      coalesce(p_payload->>'goal', ''),
      coalesce((p_payload->>'daily_minutes')::integer, 15)
    )
    on conflict (user_id) do update
    set display_name = excluded.display_name,
        jlpt_level = excluded.jlpt_level,
        goal = excluded.goal,
        daily_minutes = excluded.daily_minutes
    returning pg_catalog.to_jsonb(profiles.*) into v_updated_row;
  elsif p_entity_table = 'saved_grammar' then
    insert into public.saved_grammar (user_id, grammar_id, deleted_at)
    values (
      v_uid,
      v_record_uuid,
      case when p_delete then pg_catalog.clock_timestamp() else null end
    )
    on conflict (user_id, grammar_id) do update
    set deleted_at = case when p_delete then pg_catalog.clock_timestamp() else null end
    returning pg_catalog.to_jsonb(saved_grammar.*) into v_updated_row;
  elsif p_entity_table = 'notes' then
    if p_delete then
      update public.notes
      set deleted_at = pg_catalog.clock_timestamp()
      where id = v_record_uuid and user_id = v_uid
      returning pg_catalog.to_jsonb(notes.*) into v_updated_row;
      if not found then
        raise exception 'note_not_found' using errcode = '22023';
      end if;
    else
      v_grammar_uuid := (p_payload->>'grammar_id')::uuid;
      insert into public.notes (id, user_id, grammar_id, content, deleted_at)
      values (v_record_uuid, v_uid, v_grammar_uuid, coalesce(p_payload->>'content', ''), null)
      on conflict (id) do update
      set grammar_id = excluded.grammar_id,
          content = excluded.content,
          deleted_at = null
      returning pg_catalog.to_jsonb(notes.*) into v_updated_row;
    end if;
  else
    insert into public.progress (user_id, grammar_id, status)
    values (v_uid, v_record_uuid, coalesce(p_payload->>'status', 'new'))
    on conflict (user_id, grammar_id) do update
    set status = excluded.status
    returning pg_catalog.to_jsonb(progress.*) into v_updated_row;
  end if;

  select r.revision into v_next_rev
  from public.record_revisions r
  where r.user_id = v_uid
    and r.entity_table = p_entity_table
    and r.record_id = p_record_id;

  insert into public.sync_operation_receipts (
    user_id, operation_id, entity_table, record_id, resulting_revision, response_payload
  )
  values (v_uid, p_operation_id, p_entity_table, p_record_id, v_next_rev, v_updated_row);

  return jsonb_build_object(
    'status', 'applied',
    'revision', v_next_rev,
    'record', v_updated_row
  );
end;
$$;
revoke all on function public.bunly_sync_personal_record(uuid, text, text, bigint, boolean, jsonb) from public, anon, authenticated;
grant execute on function public.bunly_sync_personal_record(uuid, text, text, bigint, boolean, jsonb) to authenticated;

-- 5. Safe read-only inspection of caller's own daily analysis quota (B-FR-11).
create function public.bunly_my_analysis_quota() returns jsonb
language plpgsql security definer set search_path = '' as $$
declare
  v_uid uuid := (select auth.uid());
  v_day date := (pg_catalog.clock_timestamp() at time zone 'UTC')::date;
  v_limit integer;
  v_used integer := 0;
  v_reserved integer := 0;
  v_reset_at timestamptz := ((v_day + 1)::timestamp at time zone 'UTC');
begin
  if v_uid is null then
    raise exception 'unauthenticated' using errcode = '42501';
  end if;

  select e.daily_limit into v_limit
  from bunly_analysis_private.entitlements e
  where e.user_id = v_uid;

  if not found then
    return jsonb_build_object(
      'has_entitlement', false,
      'daily_limit', 0,
      'used_today', 0,
      'reserved_today', 0,
      'remaining_quota', 0,
      'reset_at_utc', v_reset_at
    );
  end if;

  select coalesce(u.successes, 0), coalesce(u.reserved, 0)
  into v_used, v_reserved
  from bunly_analysis_private.usage u
  where u.user_id = v_uid and u.quota_day = v_day;

  if not found then
    v_used := 0;
    v_reserved := 0;
  end if;

  return jsonb_build_object(
    'has_entitlement', true,
    'daily_limit', v_limit,
    'used_today', v_used,
    'reserved_today', v_reserved,
    'remaining_quota', greatest(v_limit - (v_used + v_reserved), 0),
    'reset_at_utc', v_reset_at
  );
end;
$$;
revoke all on function public.bunly_my_analysis_quota() from public, anon, authenticated;
grant execute on function public.bunly_my_analysis_quota() to authenticated;
