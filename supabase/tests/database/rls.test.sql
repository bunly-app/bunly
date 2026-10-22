begin;
create extension if not exists pgtap with schema extensions;
select plan(18);
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
select * from finish();
rollback;
