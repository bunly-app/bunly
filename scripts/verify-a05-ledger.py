"""Test the A05 proposal in a new disposable DB, never reset or alter the app DB."""
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import subprocess
import sys
import uuid


ROOT = Path(__file__).resolve().parents[1]
OWNER = '01a1bf45-c4e6-75e2-bf1a-ad9c410e2612'
CONTAINER = 'supabase_db_bunly'
STATE = ROOT / 'documents/development/autonomous-run'
A, B, C = (f'20000000-0000-0000-0000-{index:012d}' for index in (101, 102, 103))
FP = 'a' * 64


def gate():
    if json.loads((STATE / 'waiting-user.json').read_text(encoding='utf-8-sig'))['status'] == 'waiting':
        raise RuntimeError('Waiting for user; no database work permitted')
    lease = json.loads((STATE / 'workspace-lease.json').read_text(encoding='utf-8-sig'))
    if lease['owner_thread_id'] != OWNER or datetime.fromisoformat(lease['expires_at']) <= datetime.now(timezone.utc):
        raise RuntimeError('Current exclusive environment lease required')


def execute(database, sql, role=None, expect_error=False, cleanup=False):
    if not cleanup:
        gate()
    if role not in (None, 'service_role', 'authenticated', 'anon'):
        raise ValueError('Unsupported test role')
    prefix = f'set role {role};\n' if role else ''
    result = subprocess.run(
        ['docker', 'exec', '-i', CONTAINER, 'psql', '-U', 'postgres', '-d', database,
         '-X', '-A', '-t', '-v', 'ON_ERROR_STOP=1'],
        input=prefix + sql, capture_output=True, text=True, encoding='utf-8', timeout=45,
    )
    if expect_error:
        if result.returncode == 0 or 'permission denied' not in result.stderr:
            raise AssertionError('Expected permission denial for client role')
        return None
    if result.returncode:
        # Only synthetic scratch data are involved; no status/config/secrets queried.
        raise RuntimeError(result.stderr.strip())
    return result.stdout.strip().splitlines()[-1] if result.stdout.strip() else ''


def literal(value):
    if value is None:
        return 'null'
    return "'" + str(value).replace("'", "''") + "'"


def request_id():
    return str(uuid.uuid4())


def main():
    gate()
    database = 'bunly_a05_review_' + uuid.uuid4().hex[:12]
    if not re.fullmatch(r'bunly_a05_review_[a-f0-9]{12}', database):
        raise RuntimeError('Invalid scratch database name')
    created = False
    passed = 0

    def check(condition, description):
        nonlocal passed
        if not condition:
            raise AssertionError(description)
        passed += 1
        print(f'ok {passed} - {description}', flush=True)

    def begin(owner, rid, fingerprint=FP):
        return json.loads(execute(database,
            f'select public.bunly_analysis_begin({literal(owner)}, {literal(rid)}, {literal(fingerprint)});', 'service_role'))

    def finish(owner, rid, generation, output=None, error=None):
        result = literal(json.dumps(output)) + '::jsonb' if output is not None else 'null'
        return json.loads(execute(database,
            f'select public.bunly_analysis_finish({literal(owner)}, {literal(rid)}, {int(generation)}, {result}, {literal(error)});', 'service_role'))

    def usage(owner):
        return json.loads(execute(database, 'select jsonb_build_object(\'successes\', coalesce(sum(successes),0), '
            f"'reserved', coalesce(sum(reserved),0)) from bunly_analysis_private.usage where user_id={literal(owner)};"))

    try:
        execute('postgres', f'create database {database};')
        created = True
        # Minimal FK fixture only: this is NOT a substitute for Supabase Auth tests.
        execute(database, 'create schema auth; create table auth.users(id uuid primary key); '
            f'insert into auth.users values ({literal(A)}), ({literal(B)}), ({literal(C)});')
        if '--current-migrations' in sys.argv:
            sources = sorted((ROOT / 'supabase/migrations').glob('*_a05_analysis_*.sql'))
            if not sources:
                raise RuntimeError('No current A05 migrations found')
        else:
            sources = [ROOT / 'supabase/proposals/a05-analysis-ledger.sql']
        for source in sources:
            execute(database, source.read_text(encoding='utf-8'))
        execute(database, 'insert into bunly_analysis_private.entitlements values '
            f'({literal(A)},1), ({literal(B)},2), ({literal(C)},1);')
        check(execute(database, "select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace "
            "where n.nspname='bunly_analysis_private' and c.relkind='r' and c.relrowsecurity;") == '3', 'all three private tables enable RLS')
        check(execute(database, "select bool_and(not prosecdef) from pg_proc where proname in "
            "('bunly_analysis_begin','bunly_analysis_finish');") == 't', 'RPCs use SECURITY INVOKER')
        for role in ('anon', 'authenticated'):
            execute(database, f'select public.bunly_analysis_begin({literal(A)}, {literal(request_id())}, {literal(FP)});', role, True)
            execute(database, f'select public.bunly_analysis_finish({literal(A)}, {literal(request_id())}, 1, null, \'timeout\');', role, True)
            execute(database, 'select * from bunly_analysis_private.requests;', role, True)
            execute(database, f'update bunly_analysis_private.entitlements set daily_limit=999 where user_id={literal(A)};', role, True)
            check(True, f'{role} cannot invoke privileged RPCs, read ledger or self-upgrade quota')

        ids = [request_id(), request_id()]
        with ThreadPoolExecutor(max_workers=2) as pool:
            race = list(pool.map(lambda rid: begin(A, rid), ids))
        check(sorted(value['status'] for value in race) == ['claimed', 'quota_exceeded'], 'two concurrent final-quota requests yield one reservation')
        check(usage(A) == {'successes': 0, 'reserved': 1}, 'parallel requests cannot over-reserve')
        winner = ids[next(i for i, result in enumerate(race) if result['status'] == 'claimed')]
        check(begin(A, winner)['status'] == 'processing', 'duplicate processing cannot claim another model call')
        check(begin(A, winner, 'b' * 64)['status'] == 'request_conflict', 'same UUID with different fingerprint is conflict')
        done = finish(A, winner, 1, {'matches': []})
        check(done['status'] == 'succeeded' and done['remaining_quota'] == 0, 'valid no-match consumes exactly one success')
        finish(A, winner, 1, {'matches': []})
        finish(A, winner, 1, error='timeout')
        check(usage(A) == {'successes': 1, 'reserved': 0}, 'repeated finalize and late error do not double charge or refund success')
        execute(database, f'update bunly_analysis_private.entitlements set daily_limit=3 where user_id={literal(A)};')
        check(begin(A, winner)['remaining_quota'] == 2, 'replay gets current entitlement/quota instead of stale response quota')
        other = request_id()
        begin(A, other)
        check(begin(A, winner)['remaining_quota'] == 1, 'replay includes other currently reserved requests')

        failed = request_id()
        check(begin(B, failed)['generation'] == 1, 'first attempt has generation one')
        check(finish(B, failed, 1, error='timeout')['remaining_quota'] == 2, 'timeout refunds its reservation')
        finish(B, failed, 1, error='timeout')
        check(usage(B) == {'successes': 0, 'reserved': 0}, 'duplicate refund is idempotent')
        check(begin(B, failed)['generation'] == 2, 'retryable failed request claims a new generation')
        check(finish(B, failed, 1, {'matches': []})['status'] == 'stale_generation', 'stale worker cannot finalize a newer generation')
        check(usage(B) == {'successes': 0, 'reserved': 1}, 'stale callback cannot consume or refund new reservation')
        finish(B, failed, 2, {'matches': []})
        check(usage(B) == {'successes': 1, 'reserved': 0}, 'current generation succeeds exactly once')
        invalid = request_id()
        begin(B, invalid)
        finish(B, invalid, 1, error='invalid_output')
        check(begin(B, invalid)['status'] == 'failed' and usage(B)['reserved'] == 0, 'invalid output refunds once and does not silently retry')

        # A and B may use the same request UUID; their ledger keys remain independent.
        check(begin(B, winner)['status'] == 'claimed', 'request UUID is scoped to verified owner')
        execute(database, f"update bunly_analysis_private.requests set started_at=clock_timestamp()-interval '2 days' "
            f'where user_id={literal(B)} and request_id={literal(winner)};')
        check(begin(B, winner)['status'] == 'processing', 'elapsed lease time alone never starts another provider call')

        midnight = request_id()
        begin(C, midnight)
        execute(database, f"update bunly_analysis_private.usage set quota_day=quota_day-1 where user_id={literal(C)}; "
            f"update bunly_analysis_private.requests set quota_day=quota_day-1 where user_id={literal(C)};")
        check(finish(C, midnight, 1, {'matches': []})['remaining_quota'] == 1, 'cross-midnight finalization charges original reservation day')
        check(begin(C, midnight)['remaining_quota'] == 1, 'old-day replay returns current UTC-day availability')
        missing_owner = str(uuid.uuid4())
        check(begin(missing_owner, request_id())['status'] == 'unavailable', 'missing entitlement fails closed without inventing a Free/Pro limit')
        check(finish(C, request_id(), 1, {'matches': []})['status'] == 'unknown_request', 'unknown request cannot finalize')

        interrupted = request_id()
        begin(C, interrupted)
        rolled_back = False
        try:
            execute(database, 'begin; select public.bunly_analysis_finish('
                f"{literal(C)}, {literal(interrupted)}, 1, '{{\"matches\":[]}}'::jsonb, null); select 1/0; commit;", 'service_role')
        except RuntimeError as error:
            rolled_back = 'division by zero' in str(error)
        check(rolled_back and begin(C, interrupted)['status'] == 'processing', 'finalize DB failure rolls back and duplicate request does not rerun provider')
        finish(C, interrupted, 1, {'matches': []})
        check(usage(C) == {'successes': 2, 'reserved': 0}, 'retry same-generation finalize after DB failure charges exactly once across days')

        execute(database, f'update bunly_analysis_private.entitlements set daily_limit=3 where user_id={literal(B)};')
        same_id = request_id()
        with ThreadPoolExecutor(max_workers=2) as pool:
            duplicate_race = list(pool.map(lambda _: begin(B, same_id), range(2)))
        check(sorted(value['status'] for value in duplicate_race) == ['claimed', 'processing'], 'concurrent same-UUID submissions claim one worker')
        with ThreadPoolExecutor(max_workers=2) as pool:
            list(pool.map(lambda _: finish(B, same_id, 1, {'matches': []}), range(2)))
        check(usage(B) == {'successes': 2, 'reserved': 1}, 'concurrent duplicate finalize consumes only one success')

        execute(database, 'create extension plpgsql_check;')
        levels = "level = 'error' or level like 'warning%'" if '--current-migrations' in sys.argv else "level in ('error','warning')"
        lint_count = execute(database, "select count(*) from plpgsql_check_function_tb('public.bunly_analysis_begin(uuid,uuid,text)'::regprocedure) "
            f"where {levels};")
        check(lint_count == '0', 'proposal begin RPC has no plpgsql_check errors/warnings')
        lint_count = execute(database, "select count(*) from plpgsql_check_function_tb('public.bunly_analysis_finish(uuid,uuid,bigint,jsonb,text)'::regprocedure) "
            f"where {levels};")
        check(lint_count == '0', 'proposal finish RPC has no plpgsql_check errors/warnings')
        print(json.dumps({'passed': passed, 'failed': 0, 'database_scope': 'disposable scratch only'}), flush=True)
    finally:
        if created:
            # Only drop the unique DB created by this invocation, never an existing app DB.
            execute('postgres', f'drop database {database};', cleanup=True)
            print('Removed the invocation-owned scratch database; app DB preserved.', flush=True)


if __name__ == '__main__':
    main()
