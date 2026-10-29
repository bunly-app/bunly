#!/usr/bin/env bash
set -euo pipefail
mkdir -p build/m2-evidence
recording_pid=''
recording_adb_pid=''
email_pid=''
network_pid=''
finish_recording() {
  local result=$?
  trap - EXIT
  docker start supabase_kong_bunly >/dev/null 2>&1 || true
  if [ -n "$recording_pid" ]; then
    adb shell kill -2 "$recording_pid" || true
  fi
  sleep 2
  if ! adb pull /data/local/tmp/m2-connected.mp4 build/m2-evidence/m2-connected.mp4; then
    result=1
  fi
  if [ ! -s build/m2-evidence/m2-connected.mp4 ]; then
    result=1
  fi
  for helper_pid in "$recording_adb_pid" "$email_pid" "$network_pid"; do
    if [ -n "$helper_pid" ]; then
      kill "$helper_pid" 2>/dev/null || true
    fi
  done
  exit "$result"
}
trap finish_recording EXIT
python3 scripts/confirm_m2_local_email.py > build/m2-evidence/email-confirmation.log 2>&1 &
email_pid=$!
python3 scripts/m2_test_network.py > build/m2-evidence/network-control.log 2>&1 &
network_pid=$!
adb shell screenrecord --bit-rate 2000000 --time-limit 0 /data/local/tmp/m2-connected.mp4 > build/m2-evidence/screenrecord.log 2>&1 &
recording_adb_pid=$!
sleep 1
recording_pid=$(adb shell pidof screenrecord | tr -d '\r' || true)
result=0
flutter test integration_test/m2_connected_test.dart -d emulator-5554 --dart-define-from-file=config/m2-test.local.json > build/m2-evidence/android-connected.log 2>&1 || result=$?
cat build/m2-evidence/android-connected.log
if [ ! -f build/m2-evidence/email-confirmed.txt ]; then
  result=1
fi
exit "$result"
