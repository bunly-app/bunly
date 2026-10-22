-- Shared content and user-owned learning records for M2.
create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  jlpt_level text not null default 'N5' check (jlpt_level in ('N5', 'N4')),
  goal text not null default '',
  daily_minutes integer not null default 15 check (daily_minutes between 1 and 1440),
  updated_at timestamptz not null default now()
);

create table public.grammar_points (
  id uuid primary key default gen_random_uuid(),
  pattern text not null,
  level text not null check (level in ('N5', 'N4')),
  category text not null,
  meaning_vi text not null,
  formula text not null,
  usage_vi text not null,
  updated_at timestamptz not null default now()
);

create table public.grammar_examples (
  id uuid primary key default gen_random_uuid(),
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  sentence_ja text not null,
  translation_vi text not null,
  sort_order integer not null default 0,
  unique (grammar_id, sort_order)
);

create table public.saved_grammar (
  user_id uuid not null references auth.users(id) on delete cascade,
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  primary key (user_id, grammar_id)
);

create table public.notes (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  content text not null check (char_length(btrim(content)) between 1 and 2000),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  grammar_id uuid not null references public.grammar_points(id) on delete cascade,
  status text not null default 'new' check (status in ('new', 'learning', 'review', 'mastered')),
  updated_at timestamptz not null default now(),
  primary key (user_id, grammar_id)
);

create index grammar_examples_grammar_idx on public.grammar_examples(grammar_id);
create index notes_owner_grammar_idx on public.notes(user_id, grammar_id);
create index notes_grammar_idx on public.notes(grammar_id);
create index saved_grammar_grammar_idx on public.saved_grammar(grammar_id);
create index progress_grammar_idx on public.progress(grammar_id);

create function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create function public.create_user_profile() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(user_id) values (new.id);
  return new;
end;
$$;
revoke execute on function public.create_user_profile() from public, anon, authenticated;
create trigger create_profile_after_signup after insert on auth.users
for each row execute function public.create_user_profile();

-- No implicit public/anon privileges; application clients cannot curate content.
revoke all on table public.profiles, public.grammar_points, public.grammar_examples,
  public.saved_grammar, public.notes, public.progress from anon, authenticated;
grant select on public.grammar_points, public.grammar_examples to authenticated;
grant select, insert, update, delete on public.profiles, public.saved_grammar,
  public.notes, public.progress to authenticated;

alter table public.grammar_points enable row level security;
alter table public.grammar_examples enable row level security;
create policy read_content on public.grammar_points for select to authenticated using (true);
create policy read_examples on public.grammar_examples for select to authenticated using (true);

-- Both USING and WITH CHECK are needed: owning the old row must not allow reassigning it.
do $$
declare table_name text;
begin
  foreach table_name in array array['profiles', 'saved_grammar', 'notes', 'progress'] loop
    execute format('alter table public.%I enable row level security', table_name);
    execute format('create policy own_select on public.%I for select to authenticated using ((select auth.uid()) = user_id)', table_name);
    execute format('create policy own_insert on public.%I for insert to authenticated with check ((select auth.uid()) = user_id)', table_name);
    execute format('create policy own_update on public.%I for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)', table_name);
    execute format('create policy own_delete on public.%I for delete to authenticated using ((select auth.uid()) = user_id)', table_name);
    execute format('create trigger set_updated_at before update on public.%I for each row execute function public.set_updated_at()', table_name);
  end loop;
end;
$$;
create trigger set_updated_at before update on public.grammar_points
for each row execute function public.set_updated_at();
