-- Grant default Free-tier AI analysis quota (5 successful analyses per UTC day,
-- matching PRD B-FR-11 Free baseline) on signup and backfill existing users.
-- Entitlements stay locked inside bunly_analysis_private (no client read/write).
create function public.grant_default_analysis_entitlement() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into bunly_analysis_private.entitlements (user_id, daily_limit)
  values (new.id, 5)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

revoke execute on function public.grant_default_analysis_entitlement()
  from public, anon, authenticated;

create trigger grant_analysis_entitlement_after_signup
  after insert on auth.users
  for each row execute function public.grant_default_analysis_entitlement();

insert into bunly_analysis_private.entitlements (user_id, daily_limit)
select u.id, 5
from auth.users u
on conflict (user_id) do nothing;
