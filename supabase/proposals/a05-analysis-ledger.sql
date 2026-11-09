-- REVIEW DRAFT ONLY. Not a migration; do not apply to the application DB/hosted.
-- Tested in a disposable database by scripts/verify-a05-ledger.py.
-- Entitlements are administrator-provided; no Free/Pro quota is chosen here.
create schema bunly_analysis_private;
revoke all on schema bunly_analysis_private from public, anon, authenticated;
grant usage on schema bunly_analysis_private to service_role;

create table bunly_analysis_private.entitlements (
  user_id uuid primary key references auth.users(id) on delete cascade,
  daily_limit integer not null check (daily_limit between 0 and 10000)
);
create table bunly_analysis_private.usage (
  user_id uuid not null references bunly_analysis_private.entitlements(user_id) on delete cascade,
  quota_day date not null,
  successes integer not null default 0 check (successes >= 0),
  reserved integer not null default 0 check (reserved >= 0),
  primary key (user_id, quota_day)
);
create table bunly_analysis_private.requests (
  user_id uuid not null references bunly_analysis_private.entitlements(user_id) on delete cascade,
  request_id uuid not null,
  fingerprint text not null check (fingerprint ~ '^[0-9a-f]{64}$'),
  quota_day date not null,
  status text not null check (status in ('processing', 'succeeded', 'failed')),
  generation bigint not null default 1 check (generation > 0),
  reservation_active boolean not null,
  started_at timestamptz not null default clock_timestamp(),
  finished_at timestamptz,
  result jsonb,
  error_code text check (error_code in ('invalid_output', 'unavailable', 'timeout')),
  primary key (user_id, request_id),
  check ((status = 'processing') = reservation_active),
  check ((status = 'succeeded') = (result is not null)),
  check ((status = 'failed') = (error_code is not null))
);
alter table bunly_analysis_private.entitlements enable row level security;
alter table bunly_analysis_private.usage enable row level security;
alter table bunly_analysis_private.requests enable row level security;
revoke all on all tables in schema bunly_analysis_private from public, anon, authenticated;
grant select, insert, update on all tables in schema bunly_analysis_private to service_role;

create function bunly_analysis_private.remaining(p_user uuid) returns integer
language sql security invoker set search_path = '' as $$
  select greatest(e.daily_limit - coalesce((
    select u.successes + u.reserved from bunly_analysis_private.usage u
    where u.user_id = p_user and u.quota_day = (clock_timestamp() at time zone 'UTC')::date
  ), 0), 0) from bunly_analysis_private.entitlements e where e.user_id = p_user;
$$;
revoke all on function bunly_analysis_private.remaining(uuid) from public, anon, authenticated;
grant execute on function bunly_analysis_private.remaining(uuid) to service_role;

-- Only the authenticated server adapter may pass p_user. This RPC is NOT callable by clients.
create function public.bunly_analysis_begin(p_user uuid, p_request uuid, p_fingerprint text)
returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  v_limit integer;
  v_day date := (clock_timestamp() at time zone 'UTC')::date;
  v_request bunly_analysis_private.requests%rowtype;
  v_remaining integer;
  v_exists boolean;
begin
  if p_user is null or p_request is null or p_fingerprint is null or p_fingerprint !~ '^[0-9a-f]{64}$' then
    raise exception 'invalid_input' using errcode = '22023';
  end if;
  -- Every transition locks entitlement -> request -> usage, in that order.
  select daily_limit into v_limit from bunly_analysis_private.entitlements
    where user_id = p_user for update;
  if not found then return jsonb_build_object('status', 'unavailable'); end if;
  select * into v_request from bunly_analysis_private.requests
    where user_id = p_user and request_id = p_request for update;
  v_exists := found;
  v_remaining := bunly_analysis_private.remaining(p_user);
  if v_exists then
    if v_request.fingerprint <> p_fingerprint then
      return jsonb_build_object('status', 'request_conflict');
    elsif v_request.status = 'succeeded' then
      return jsonb_build_object('status', 'succeeded', 'result', v_request.result,
        'remaining_quota', v_remaining, 'generation', v_request.generation);
    elsif v_request.status = 'processing' then
      -- Elapsed time alone never authorizes a second provider call.
      return jsonb_build_object('status', 'processing', 'retry_after_ms', 1000);
    elsif v_request.error_code = 'invalid_output' then
      return jsonb_build_object('status', 'failed', 'error_code', v_request.error_code,
        'remaining_quota', v_remaining);
    end if;
  end if;
  if v_remaining = 0 then
    return jsonb_build_object('status', 'quota_exceeded', 'remaining_quota', 0);
  end if;
  insert into bunly_analysis_private.usage(user_id, quota_day, reserved)
    values (p_user, v_day, 1)
    on conflict (user_id, quota_day) do update
    set reserved = bunly_analysis_private.usage.reserved + 1;
  if v_exists then
    update bunly_analysis_private.requests set status = 'processing',
      generation = generation + 1, quota_day = v_day, reservation_active = true,
      started_at = clock_timestamp(), finished_at = null, error_code = null, result = null
      where user_id = p_user and request_id = p_request returning * into v_request;
  else
    insert into bunly_analysis_private.requests(user_id, request_id, fingerprint, quota_day, status, reservation_active)
      values (p_user, p_request, p_fingerprint, v_day, 'processing', true) returning * into v_request;
  end if;
  return jsonb_build_object('status', 'claimed', 'generation', v_request.generation,
    'remaining_quota', bunly_analysis_private.remaining(p_user));
end;
$$;

create function public.bunly_analysis_finish(
  p_user uuid, p_request uuid, p_generation bigint, p_result jsonb, p_error text
) returns jsonb language plpgsql security invoker set search_path = '' as $$
declare
  v_request bunly_analysis_private.requests%rowtype;
  v_limit integer;
begin
  if p_user is null or p_request is null or p_generation is null or p_generation < 1
    or (p_result is null) = (p_error is null) then
    raise exception 'invalid_input' using errcode = '22023';
  end if;
  if p_error is not null and p_error not in ('invalid_output', 'unavailable', 'timeout') then
    raise exception 'invalid_input' using errcode = '22023';
  end if;
  if p_result is not null and (jsonb_typeof(p_result) is distinct from 'object'
    or jsonb_typeof(p_result->'matches') is distinct from 'array'
    or (p_result - 'matches') <> '{}'::jsonb) then
    raise exception 'invalid_output' using errcode = '22023';
  end if;
  select daily_limit into v_limit from bunly_analysis_private.entitlements
    where user_id = p_user for update;
  if not found then return jsonb_build_object('status', 'unavailable'); end if;
  select * into v_request from bunly_analysis_private.requests
    where user_id = p_user and request_id = p_request for update;
  if not found then return jsonb_build_object('status', 'unknown_request'); end if;
  if v_request.generation <> p_generation then
    return jsonb_build_object('status', 'stale_generation');
  end if;
  if v_request.status = 'processing' then
    update bunly_analysis_private.usage set reserved = reserved - 1,
      successes = successes + case when p_error is null then 1 else 0 end
      where user_id = p_user and quota_day = v_request.quota_day;
    if not found then raise exception 'missing_reservation'; end if;
    update bunly_analysis_private.requests set
      status = case when p_error is null then 'succeeded' else 'failed' end,
      reservation_active = false, finished_at = clock_timestamp(), result = p_result, error_code = p_error
      where user_id = p_user and request_id = p_request returning * into v_request;
  end if;
  -- Repeated finalize returns the first committed outcome without charging/refunding again.
  return jsonb_build_object('status', v_request.status, 'result', v_request.result,
    'error_code', v_request.error_code, 'remaining_quota', bunly_analysis_private.remaining(p_user),
    'generation', v_request.generation);
end;
$$;

revoke all on function public.bunly_analysis_begin(uuid, uuid, text) from public, anon, authenticated;
revoke all on function public.bunly_analysis_finish(uuid, uuid, bigint, jsonb, text) from public, anon, authenticated;
grant execute on function public.bunly_analysis_begin(uuid, uuid, text) to service_role;
grant execute on function public.bunly_analysis_finish(uuid, uuid, bigint, jsonb, text) to service_role;
