# Working on Bunly

- Read `documents/planning/PRD-M2-Architecture-Base.md` and the development guide before changing architecture.
- Cloud tasks are already isolated. Use the existing checkout; create a worktree only when the user requests one.
- Domain code is pure Dart. Presentation calls use cases; data implements repository interfaces. Wire dependencies in `lib/app/providers.dart`.
- Keep demo and connected modes explicit. Never present demo data as a verified Supabase operation.
- Never commit local configuration, tokens, service-role keys, or account credentials. Client Supabase publishable/anon keys do not authorize bypassing RLS.
- Use the repository-pinned Flutter and npm tooling; commit dependency lockfiles when dependencies change. Regenerate Drift code after schema changes.
- For CLI, database, CI and environment tasks, follow the role in `documents/roles/CLI-Environment-Maintainer.md`. This is a shared team responsibility, not a named person's assignment.
- New cloud setup or local CLI work does not authorize deploying migrations to a hosted project. Keep reset commands local; require an explicit target for hosted changes.
- Run format, analyze and relevant Flutter tests. For SQL changes, also run local migrations, database lint and RLS tests when Docker is available; record checks that could not run.
- Update the M2 report with evidence from the actual commit. Preserve unfinished and unverified statuses.
- This branch's commits must use the user's existing Git identity: `Vcoch27 <hoangtungmy123@gmail.com>`. Do not rewrite existing commits or add a Codex co-author.
