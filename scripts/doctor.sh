#!/usr/bin/env bash
set -uo pipefail
cd "$(dirname "$0")/.."

missing=0
for tool in flutter node npm; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" --version
  else
    echo "MISSING: $tool — see documents/development/GETTING_STARTED.md"
    missing=1
  fi
done
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  echo 'Docker: available for local Supabase'
else
  echo 'Docker: unavailable; demo mode still works; use a hosted development project for connected mode'
fi
if [[ -x node_modules/.bin/supabase ]]; then
  node_modules/.bin/supabase --version
else
  echo 'Supabase CLI: run npm ci when database tools are needed'
fi
exit "$missing"
