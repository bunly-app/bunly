#!/usr/bin/env bash
set -euo pipefail
mkdir -p build/m2-evidence
recording_pid=''
recording_adb_pid=''
finish_recording() {
  if [ -n "$recording_pid" ]; then
    adb shell kill -2 "$recording_pid" || true
  fi
  sleep 2
  adb pull /sdcard/m2-connected.mp4 build/m2-evidence/m2-connected.mp4 || true
  if [ -n "$recording_adb_pid" ]; then
    kill "$recording_adb_pid" 2>/dev/null || true
  fi
}
trap finish_recording EXIT
adb shell screenrecord --bit-rate 2000000 --time-limit 180 /sdcard/m2-connected.mp4 > build/m2-evidence/screenrecord.log 2>&1 &
recording_adb_pid=$!
sleep 1
recording_pid=$(adb shell pidof screenrecord | tr -d '\r' || true)
result=0
flutter test integration_test/m2_connected_test.dart -d emulator-5554 --dart-define-from-file=config/m2-test.local.json > build/m2-evidence/android-connected.log 2>&1 || result=$?
cat build/m2-evidence/android-connected.log
exit "$result"
