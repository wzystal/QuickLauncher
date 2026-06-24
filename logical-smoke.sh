#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

ADB="${ADB:-adb}"
APP_PACKAGE="${APP_PACKAGE:-com.wzystal.launcher}"
LAUNCHER_ACTIVITY="${LAUNCHER_ACTIVITY:-com.google.android.apps.nexuslauncher.NexusLauncherActivity}"
LOG_FILE="${LOG_FILE:-.logical-smoke.log}"

log() { printf '[logical-smoke] %s\n' "$*"; }
die() { log "FAIL: $*"; exit 1; }

pick_usb_device() {
  local devices
  devices="$("$ADB" devices | awk 'NR>1 && $2=="device" && $1 !~ /^emulator-/ {print $1}')"
  [[ -n "$devices" ]] || die "未检测到 USB 设备"
  printf '%s\n' "$devices" | head -n1
}

assert_activity_focused() {
  local device="$1"
  local expected="$2"
  local focus
  focus="$("$ADB" -s "$device" shell dumpsys window 2>/dev/null \
    | grep -E 'mCurrentFocus|mFocusedApp' \
    | grep -v '=null' \
    | head -1 \
    | sed 's/\x1b\[[0-9;]*m//g' || true)"
  echo "focus: $focus" >>"$LOG_FILE"
  [[ "$focus" == *"$expected"* ]] || die "当前焦点不是 $expected: $focus"
}

main() {
  : >"$LOG_FILE"
  local device="${ADB_DEVICE:-$(pick_usb_device)}"
  log "设备: $device"

  log "用例 1: 冷启动 Launcher"
  "$ADB" -s "$device" shell am force-stop "$APP_PACKAGE" >/dev/null 2>&1 || true
  "$ADB" -s "$device" shell am start -W -n "${APP_PACKAGE}/${LAUNCHER_ACTIVITY}" >>"$LOG_FILE" 2>&1 \
    || die "am start 失败"
  sleep 3
  assert_activity_focused "$device" "NexusLauncherActivity"

  log "用例 2: 进程存活"
  "$ADB" -s "$device" shell pidof "$APP_PACKAGE" >/dev/null 2>&1 \
    || die "进程不存在"

  log "用例 3: HOME 键（仅默认桌面时校验）"
  local default_home
  default_home="$("$ADB" -s "$device" shell cmd role get-role-holders android.app.role.HOME 2>/dev/null \
    | grep -F "$APP_PACKAGE" || true)"
  "$ADB" -s "$device" shell input keyevent KEYCODE_HOME >/dev/null 2>&1 || true
  sleep 1
  if [[ -n "$default_home" ]]; then
    assert_activity_focused "$device" "NexusLauncherActivity"
  else
    log "跳过：尚未设为默认 HOME"
  fi

  log "用例 4: 包可见性"
  local count
  count="$("$ADB" -s "$device" shell cmd package query-activities -a android.intent.action.MAIN -c android.intent.category.LAUNCHER 2>/dev/null | grep -c 'Activity #' || echo 0)"
  [[ "$count" -gt 5 ]] || die "LAUNCHER Activity 过少($count)"

  log "全部逻辑冒烟通过"
}

main "$@"
