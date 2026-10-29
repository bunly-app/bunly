#!/usr/bin/env bash
set -euo pipefail
mkdir -p build/m2-evidence
email_pid=''
network_pid=''
cleanup() {
  local result=$?
  trap - EXIT
  docker start supabase_kong_bunly >/dev/null 2>&1 || true
  for helper_pid in "$email_pid" "$network_pid"; do
    if [ -n "$helper_pid" ]; then
      kill "$helper_pid" 2>/dev/null || true
    fi
  done
  exit "$result"
}
trap cleanup EXIT
python3 scripts/confirm_m2_local_email.py > build/m2-evidence/email-confirmation.log 2>&1 &
email_pid=$!
python3 scripts/m2_test_network.py > build/m2-evidence/network-control.log 2>&1 &
network_pid=$!
result=0
flutter test integration_test/m2_connected_test.dart -d emulator-5554 --dart-define-from-file=config/m2-test.local.json > build/m2-evidence/android-connected.log 2>&1 || result=$?
cat build/m2-evidence/android-connected.log
if [ ! -f build/m2-evidence/email-confirmed.txt ]; then
  result=1
fi
exit "$result"
