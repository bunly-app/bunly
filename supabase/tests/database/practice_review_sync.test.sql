begin;
create extension if not exists pgtap with schema extensions;
select no_plan();

-- 1. Schema & RLS presence checks
select has_table('public', 'practice_questions', 'practice_questions table exists');
select has_table('public', 'practice_attempts', 'practice_attempts table exists');
select has_table('public', 'review_states', 'review_states table exists');
select has_table('public', 'record_revisions', 'record_revisions table exists');
select has_table('public', 'sync_operation_receipts', 'sync_operation_receipts table exists');

select is(
  (select count(*)::int from pg_class c join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public'
     and c.relname in ('practice_questions', 'practice_attempts', 'review_states', 'record_revisions', 'sync_operation_receipts')
     and c.relrowsecurity),
  5,
  'all new baseline tables enforce RLS'
);

-- Seed test users & curated MCQ/cloze questions for two-owner verification
insert into auth.users(id, email) values
 ('22000000-0000-0000-0000-000000000001', 'db-a@example.test'),
 ('22000000-0000-0000-0000-000000000002', 'db-b@example.test');

insert into public.practice_questions (
  id, grammar_id, content_version, question_type, prompt, options, correct_option_index, accepted_answers, normalization, explanation_vi
) values
(
  '25000000-0000-0000-0000-000000000001',
  '10000000-0000-0000-0000-000000000001',
  1,
  'mcq',
  'Chọn nghĩa đúng: 日本へ行ったことがあります。',
  '["Tôi đã từng đến Nhật Bản.", "Chưa từng", "Đang đi", "Muốn đi"]'::jsonb,
  0,
  null,
  'trim_only',
  'Diễn tả trải nghiệm trong quá khứ.'
),
(
  '25000000-0000-0000-0000-000000000002',
  '10000000-0000-0000-0000-000000000001',
  1,
  'cloze',
  '日本へ（　）ことがあります。',
  null,
  null,
  '["行った"]'::jsonb,
  'trim_only',
  'Trước ことがある dùng thể た.'
);

-- Explicit Pro-test entitlement override for A (20/day); B keeps default Free signup limit (5/day)
insert into bunly_analysis_private.entitlements(user_id, daily_limit)
values ('22000000-0000-0000-0000-000000000001', 20) on conflict (user_id) do update set daily_limit = excluded.daily_limit;

-- Anon privilege checks
select ok(
  not has_function_privilege('anon', 'public.bunly_my_analysis_quota()', 'EXECUTE'),
  'anon cannot execute bunly_my_analysis_quota'
);
select ok(
  not has_function_privilege('anon', 'public.bunly_sync_personal_record(uuid,text,text,bigint,boolean,jsonb)', 'EXECUTE'),
  'anon cannot execute bunly_sync_personal_record'
);

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"22000000-0000-0000-0000-000000000001","role":"authenticated"}', true);

-- Client privileges & RLS on shared question bank & derived tables
select is((select count(*)::int from public.practice_questions where id in ('25000000-0000-0000-0000-000000000001','25000000-0000-0000-0000-000000000002')), 2, 'authenticated reads curated questions');
select throws_ok($$insert into public.practice_questions(grammar_id,question_type,prompt,options,correct_option_index,explanation_vi) values ('10000000-0000-0000-0000-000000000001','mcq','spoof','["a","b","c","d"]'::jsonb,0,'x')$$, '42501', null, 'client cannot curate questions');
select throws_ok($$insert into public.review_states(user_id,grammar_id,stage,due_at) values ('22000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001',4,now())$$, '42501', null, 'client cannot forge review_states');
select throws_ok($$insert into public.record_revisions(user_id,entity_table,record_id,revision) values ('22000000-0000-0000-0000-000000000001','notes','n',99)$$, '42501', null, 'client cannot forge revisions');

-- Quota inspection returns A's exact remaining limit without write access
select is((public.bunly_my_analysis_quota()->>'has_entitlement')::boolean, true, 'A sees own entitlement');
select is((public.bunly_my_analysis_quota()->>'remaining_quota')::int, 20, 'A sees 20 remaining daily slots');

-- Attempt anti-forgery & canonical SRS schedule
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    answer_text, selected_option_index, is_correct, is_skipped, is_first_independent, attempted_at, server_received_at
  ) values (
    '51000000-0000-0000-0000-000000000001',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000001',
    'Tôi đã từng đến Nhật Bản.',
    0,
    true,
    false,
    true,
    '1999-01-01T00:00:00Z'::timestamptz,
    '1999-01-01T00:00:00Z'::timestamptz
  )
$$, 'A submits first independent correct attempt');

select ok(
  (select server_received_at >= '2026-01-01T00:00:00Z'::timestamptz
   from public.practice_attempts where id = '51000000-0000-0000-0000-000000000001'),
  'client spoofed server_received_at is overwritten by server clock_timestamp'
);
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  0,
  'first correct moves stage from -1 to 0'
);

-- Duplicate first-independent eligible attempt in same session+question is rejected
select throws_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    selected_option_index, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000002',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000001',
    0, true, false, true, now()
  )
$$, '23505', null, 'second eligible attempt in same session+question blocked');

-- Retry attempt (is_first_independent=false) is allowed and does not raise SRS stage
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id, retry_of,
    selected_option_index, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000003',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000001',
    '51000000-0000-0000-0000-000000000001',
    0, true, false, false, now()
  )
$$, 'retry attempt permitted without distorting review state');
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  0,
  'retry does not advance stage beyond 0'
);

-- Second independent correct in new session promotes stage 0 -> 1 (3 days)
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    answer_text, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000004',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000002',
    '行った', true, false, true, now()
  )
$$, 'second independent correct attempt allowed in new session');
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  1,
  'second consecutive independent correct promotes stage to 1'
);

-- Skipped attempt does not alter stage or due date
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000005',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000003',
    false, true, false, now()
  )
$$, 'skipped attempt succeeds cleanly');
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  1,
  'skip leaves stage unchanged at 1'
);

-- Retry transport insert with identical attempt UUID and ON CONFLICT DO NOTHING is idempotent
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    answer_text, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000004',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000002',
    '行った', true, false, true, now()
  ) on conflict (id) do nothing
$$, 'idempotent retry of same attempt id does not error');
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  1,
  'idempotent retry leaves stage at 1'
);

-- Wrong independent attempt in new session resets stage 1 -> 0
select lives_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    answer_text, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000006',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000004',
    '行く', false, false, true, now()
  )
$$, 'wrong independent attempt resets stage');
select is(
  (select stage from public.review_states
   where user_id = '22000000-0000-0000-0000-000000000001'
     and grammar_id = '10000000-0000-0000-0000-000000000001'),
  0,
  'wrong independent attempt resets stage to 0 (next day)'
);

-- Immutable practice_attempts prevents update/delete
select throws_ok($$update public.practice_attempts set is_correct = false where id = '51000000-0000-0000-0000-000000000001'$$, '42501', null, 'client cannot mutate attempts');
select throws_ok($$delete from public.practice_attempts where id = '51000000-0000-0000-0000-000000000001'$$, '42501', null, 'client cannot delete attempts');

-- Optimistic concurrency sync + idempotent operation receipt + tombstone protection
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000001',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    0,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"ban goc"}'::jsonb
  )->>'status',
  'applied',
  'initial note insert via CAS sync applies at revision 1'
);

-- Retry same operation_id returns duplicate_ack without conflict or double bump
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000001',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    0,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"ban goc"}'::jsonb
  )->>'status',
  'duplicate_ack',
  'retrying same operation_id returns duplicate_ack'
);

-- Update base 1 -> 2 applies
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000002',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    1,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"ban A"}'::jsonb
  )->>'revision',
  '2',
  'valid update bumps revision to 2'
);

-- Stale edit from base 1 conflicts and preserves ban A
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000003',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    1,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"stale B"}'::jsonb
  )->>'status',
  'conflict',
  'stale edit returns conflict without overwriting'
);
select is(
  (select content from public.notes where id = '31000000-0000-0000-0000-000000000001'),
  'ban A',
  'stale conflict leaves server note unchanged'
);

-- Explicit conflict resolution from base_revision 2 -> 3 succeeds
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000010',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    2,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"ban B da giai quyet"}'::jsonb
  )->>'revision',
  '3',
  'explicit conflict resolution applies at revision 3'
);

-- Delete base 3 -> 4 tombstone, followed by stale edit base 2 -> conflict
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000004',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    3,
    true,
    '{}'::jsonb
  )->>'status',
  'applied',
  'tombstone delete succeeds at revision 4'
);
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000005',
    'notes',
    '31000000-0000-0000-0000-000000000001',
    2,
    false,
    '{"grammar_id":"10000000-0000-0000-0000-000000000001","content":"zombie"}'::jsonb
  )->>'status',
  'conflict',
  'stale edit cannot resurrect tombstone'
);
select ok(
  (select deleted_at is not null from public.notes where id = '31000000-0000-0000-0000-000000000001'),
  'tombstone deleted_at stays intact'
);

-- saved_grammar & progress CAS sync works too
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000006',
    'saved_grammar',
    '10000000-0000-0000-0000-000000000001',
    0,
    false,
    '{}'::jsonb
  )->>'status',
  'applied',
  'saved_grammar CAS insert applies'
);
select is(
  public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000007',
    'progress',
    '10000000-0000-0000-0000-000000000001',
    0,
    false,
    '{"status":"review"}'::jsonb
  )->>'status',
  'applied',
  'progress CAS insert applies'
);

-- Owner B isolation checks across attempts, reviews, revisions, quota, sync
select set_config('request.jwt.claims', '{"sub":"22000000-0000-0000-0000-000000000002","role":"authenticated"}', true);
select is((select count(*)::int from public.practice_attempts), 0, 'B cannot read A attempts');
select is((select count(*)::int from public.review_states), 0, 'B cannot read A review_states');
select is((select count(*)::int from public.record_revisions), 1, 'B sees only B profile revision');
select is((public.bunly_my_analysis_quota()->>'has_entitlement')::boolean, true, 'B gets auto-provisioned default free entitlement on signup');
select is((public.bunly_my_analysis_quota()->>'daily_limit')::int, 5, 'B sees default Free 5 quota, never A Pro 20 quota');
select throws_ok($$
  insert into public.practice_attempts (
    id, user_id, question_id, grammar_id, content_version, session_id,
    selected_option_index, is_correct, is_skipped, is_first_independent, attempted_at
  ) values (
    '51000000-0000-0000-0000-000000000099',
    '22000000-0000-0000-0000-000000000001',
    '25000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    1,
    '61000000-0000-0000-0000-000000000099',
    0, true, false, true, now()
  )
$$, '42501', null, 'B cannot insert practice attempt as A');
select throws_ok($$
  select public.bunly_sync_personal_record(
    '41000000-0000-0000-0000-000000000099',
    'profiles',
    '22000000-0000-0000-0000-000000000001',
    1,
    false,
    '{"display_name":"hacked"}'::jsonb
  )
$$, '42501', null, 'B cannot mutate A profile via sync RPC');

select * from finish();
rollback;
