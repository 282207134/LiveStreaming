#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
sdk_path="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Library/Android/sdk}}"
adb_bin="$sdk_path/platform-tools/adb"
device_id="${1:-emulator-5554}"
flutter drive --keep-app-running --driver=test_driver/screens.dart --target=integration_test/screens_test.dart --dart-define=SCREENSHOT_PAGES="${2:-}" -d "$device_id"
mkdir -p docs/screenshots
cache_path=$("$adb_bin" -s "$device_id" shell run-as com.example.live_streaming find . -maxdepth 2 -type d -name utubee_screenshots | tr -d '\r' | head -n 1)
test -n "$cache_path"
"$adb_bin" -s "$device_id" exec-out run-as com.example.live_streaming tar -C "$cache_path" -cf - . | tar -xf - -C docs/screenshots
printf 'Screenshots saved to docs/screenshots\n'
