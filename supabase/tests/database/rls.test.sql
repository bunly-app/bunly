begin;
create extension if not exists pgtap with schema extensions;
select no_plan();
select has_table('public', 'notes', 'notes table exists');
select is((select count(*)::int from public.grammar_points), 3, 'three development grammar points seeded');
insert into auth.users(id, email) values
 ('20000000-0000-0000-0000-000000000001', 'a@example.test'),
 ('20000000-0000-0000-0000-000000000002', 'b@example.test');
select is((select count(*)::int from public.profiles where user_id in
 ('20000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002')), 2, 'signup creates profiles');

set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select lives_ok($$insert into public.notes values ('30000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'A note', now(), null)$$, 'A inserts own note');
select is((select count(*)::int from public.notes), 1, 'A reads own note');
select lives_ok($$update public.notes set content = 'A edited' where id = '30000000-0000-0000-0000-000000000001'$$, 'A edits own note');

select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000002","role":"authenticated"}', true);
select is((select count(*)::int from public.notes), 0, 'B cannot read A');
with changed as (update public.notes set content = 'B hacked' returning id) select is((select count(*)::int from changed), 0, 'B cannot update A');
with removed as (delete from public.notes returning id) select is((select count(*)::int from removed), 0, 'B cannot delete A');
select throws_ok($$insert into public.notes values ('30000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'spoofed', now(), null)$$, '42501', null, 'B cannot insert as A');
select lives_ok($$insert into public.notes values ('30000000-0000-0000-0000-000000000003', '20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'B note', now(), null)$$, 'B inserts own note');
select throws_ok($$update public.notes set user_id = '20000000-0000-0000-0000-000000000001' where id = '30000000-0000-0000-0000-000000000003'$$, '42501', null, 'B cannot reassign own note to A');
select throws_ok($$insert into public.grammar_points(pattern,level,category,meaning_vi,formula,usage_vi) values ('x','N5','test','x','x','x')$$, '42501', null, 'client cannot curate shared content');
select is((select count(*)::int from public.profiles), 1, 'B sees only own profile');
with changed as (update public.profiles set goal='spoofed' where user_id='20000000-0000-0000-0000-000000000001' returning user_id) select is((select count(*)::int from changed), 0, 'B cannot change A profile');

select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select is((select content from public.notes where id='30000000-0000-0000-0000-000000000001'), 'A edited', 'A data remains unchanged after B attempts');
select is((select count(*)::int from public.notes where user_id='20000000-0000-0000-0000-000000000002'), 0, 'A cannot read B');
select lives_ok($$delete from public.notes where id='30000000-0000-0000-0000-000000000001'$$, 'A deletes own note');

-- The same ownership contract must hold for saved grammar and progress.
select lives_ok($$insert into public.saved_grammar(user_id,grammar_id) values ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001')$$, 'A saves grammar');
select lives_ok($$insert into public.progress(user_id,grammar_id,status) values ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','learning')$$, 'A sets progress');
select lives_ok($$update public.profiles set display_name='A',daily_minutes=30 where user_id='20000000-0000-0000-0000-000000000001'$$, 'A edits profile');
select throws_ok($$update public.profiles set daily_minutes=0 where user_id='20000000-0000-0000-0000-000000000001'$$, '23514', null, 'profile rejects invalid daily minutes');
select throws_ok($$update public.progress set status='invalid'$$, '23514', null, 'progress rejects invalid status');
select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000002","role":"authenticated"}', true);
select is((select count(*)::int from public.saved_grammar), 0, 'B cannot read A saves');
select is((select count(*)::int from public.progress), 0, 'B cannot read A progress');
with changed as (update public.saved_grammar set deleted_at=now() returning user_id) select is((select count(*)::int from changed),0,'B cannot change A saves');
with removed as (delete from public.saved_grammar returning user_id) select is((select count(*)::int from removed),0,'B cannot delete A saves');
with changed as (update public.progress set status='mastered' returning user_id) select is((select count(*)::int from changed),0,'B cannot change A progress');
with removed as (delete from public.progress returning user_id) select is((select count(*)::int from removed),0,'B cannot delete A progress');
select throws_ok($$insert into public.saved_grammar(user_id,grammar_id) values ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002')$$,'42501',null,'B cannot save as A');
select throws_ok($$insert into public.progress(user_id,grammar_id) values ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000002')$$,'42501',null,'B cannot create progress as A');
select lives_ok($$insert into public.saved_grammar(user_id,grammar_id) values ('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002')$$,'B creates own save');
select lives_ok($$insert into public.progress(user_id,grammar_id) values ('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002')$$,'B creates own progress');
select throws_ok($$update public.saved_grammar set user_id='20000000-0000-0000-0000-000000000001'$$,'42501',null,'B cannot reassign save');
select throws_ok($$update public.progress set user_id='20000000-0000-0000-0000-000000000001'$$,'42501',null,'B cannot reassign progress');
select set_config('request.jwt.claims', '{"sub":"20000000-0000-0000-0000-000000000001","role":"authenticated"}', true);
select is((select deleted_at from public.saved_grammar where user_id='20000000-0000-0000-0000-000000000001'),null::timestamptz,'A save remains active');
select is((select status from public.progress where user_id='20000000-0000-0000-0000-000000000001'),'learning','A progress unchanged');
select lives_ok($$update public.saved_grammar set deleted_at=now() where user_id='20000000-0000-0000-0000-000000000001'$$,'A can tombstone save');
select is((select count(*)::int from public.saved_grammar where deleted_at is not null),1,'save tombstone retained');
select * from finish();
rollback;
