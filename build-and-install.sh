#!/usr/bin/env bash
# 编译 AOSP 8.1 冻结基线（无 Quickstep）并安装到 USB 真机。
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

APK_PATH="${APK_PATH:-build/outputs/apk/aosp/debug/LiteLauncher-aosp-debug.apk}"
STAMP_FILE=".build-and-install.stamp"
CRASH_LOG=".build-and-install-crash.log"
GRADLE="./gradlew"
ADB="${ADB:-adb}"
APP_PACKAGE="${APP_PACKAGE:-com.wzystal.launcher}"
LAUNCHER_ACTIVITY="${LAUNCHER_ACTIVITY:-com.google.android.apps.nexuslauncher.NexusLauncherActivity}"
SMOKE_WAIT_SEC="${SMOKE_WAIT_SEC:-5}"

log() { printf '[build-and-install] %s\n' "$*"; }
die() { log "ERROR: $*"; exit 1; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "未找到命令: $1"
}

compute_source_hash() {
  find src src_flags res protos proto_overrides proto_pixel \
    AndroidManifest.xml AndroidManifest-common.xml build.gradle \
    -type f \( \
      -name '*.java' -o -name '*.xml' -o -name '*.gradle' -o \
      -name '*.properties' -o -name '*.proto' \
    \) 2>/dev/null \
    | LC_ALL=C sort \
    | while IFS= read -r file; do
        shasum -a 256 "$file"
      done \
    | shasum -a 256 \
    | awk '{print $1}'
}

pick_usb_device() {
  local devices
  devices="$("$ADB" devices | awk 'NR>1 && $2=="device" && $1 !~ /^emulator-/ {print $1}')"
  [[ -n "$devices" ]] || die "未检测到 USB 设备"
  printf '%s\n' "$devices" | head -n1
}

build_debug() {
  log "开始编译 assembleAospDebug ..."
  "$GRADLE" assembleAospDebug --no-daemon
  [[ -f "$APK_PATH" ]] || die "编译完成但未找到 APK: $APK_PATH"
}

install_apk() {
  local device="$1"
  log "安装到设备 $device ..."
  "$ADB" -s "$device" install -r "$APK_PATH"
  log "安装完成: $APK_PATH"
}

smoke_test() {
  local device="$1"
  log "清空 logcat，启动 $APP_PACKAGE 做冒烟检查 ..."
  "$ADB" -s "$device" logcat -c >/dev/null 2>&1 || true
  "$ADB" -s "$device" shell am force-stop "$APP_PACKAGE" >/dev/null 2>&1 || true
  "$ADB" -s "$device" shell am start -n "${APP_PACKAGE}/${LAUNCHER_ACTIVITY}" >/dev/null 2>&1 || true
  sleep "$SMOKE_WAIT_SEC"
  "$ADB" -s "$device" logcat -d -t 500 >"$CRASH_LOG" 2>/dev/null || true
  if grep -q "FATAL EXCEPTION" "$CRASH_LOG" && grep -q "$APP_PACKAGE" "$CRASH_LOG"; then
    log "检测到崩溃，日志: $CRASH_LOG"
    grep -A 30 "FATAL EXCEPTION" "$CRASH_LOG" | tail -35
    return 2
  fi
  log "冒烟检查未发现崩溃"
}

main() {
  require_cmd "$ADB"
  require_cmd shasum
  [[ -x "$GRADLE" ]] || die "未找到 gradlew"

  local current_hash saved_hash=""
  current_hash="$(compute_source_hash)"
  [[ -f "$STAMP_FILE" ]] && saved_hash="$(cat "$STAMP_FILE")"

  if [[ "$current_hash" != "$saved_hash" || ! -f "$APK_PATH" ]]; then
    log "检测到变更或缺少 APK，重新编译"
    build_debug
    printf '%s' "$current_hash" >"$STAMP_FILE"
  else
    log "业务代码无变更，跳过编译"
  fi

  local device
  device="$(pick_usb_device)"
  install_apk "$device"
  smoke_test "$device" || exit 2

  if [[ -x "$ROOT_DIR/logical-smoke.sh" ]]; then
    log "执行 logical-smoke.sh ..."
    ADB_DEVICE="$device" "$ROOT_DIR/logical-smoke.sh" || exit 2
  fi
}

main "$@"
