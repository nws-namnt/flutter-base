#!/bin/bash

# Re-exec with bash if invoked via sh/dash (shebang is ignored when calling `sh script.sh`)
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# setup_firebase.sh
# Configure FlutterFire for one or more flavors.
#
# Usage: bash scripts/setup_firebase.sh  (or just: sh scripts/setup_firebase.sh)
#
# Navigation:
#   w / ↑   = move up
#   s / ↓   = move down
#   Enter   = toggle selection  (on flavor list)
#             confirm            (on "Start setup" / yes-no)

# ── Colors ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

FLAVORS=("dev" "uat" "prod")
CHECKED=()

# ── Helpers ──────────────────────────────────────────────────────────────────

_read_key() {
  IFS= read -rsn1 KEY
  if [[ "$KEY" == $'\x1b' ]]; then
    IFS= read -rsn1 -t 1 _k2 2>/dev/null || _k2=""
    if [[ "$_k2" == "[" ]]; then
      IFS= read -rsn1 -t 1 _k3 2>/dev/null || _k3=""
      KEY="${KEY}${_k2}${_k3}"
    else
      KEY="${KEY}${_k2}"
    fi
  fi
}

_is_checked() {
  local f="$1"
  for c in "${CHECKED[@]}"; do [[ "$c" == "$f" ]] && return 0; done
  return 1
}

_toggle() {
  local f="$1"
  if _is_checked "$f"; then
    local new=()
    for c in "${CHECKED[@]}"; do [[ "$c" != "$f" ]] && new+=("$c"); done
    CHECKED=("${new[@]}")
  else
    CHECKED+=("$f")
  fi
}

# ── Step 1 — Firebase auth ───────────────────────────────────────────────────

# shellcheck source=auth_firebase.sh
source "$(dirname "${BASH_SOURCE[0]}")/auth_firebase.sh"

# ── Step 2 — FVM? ────────────────────────────────────────────────────────────

ask_fvm() {
  local cursor=0
  local MENU_LINES=2

  _draw_fvm() {
    if [ "$cursor" -eq 0 ]; then
      printf '  %b%b▶  Yes%b\n' "$CYAN" "$BOLD" "$NC"
      printf '     No\n'
    else
      printf '     Yes\n'
      printf '  %b%b▶  No%b\n' "$CYAN" "$BOLD" "$NC"
    fi
  }

  tput civis 2>/dev/null
  printf '\n'
  printf '%bAre you using FVM?%b  %b(w/↑ · s/↓ · Enter)%b\n' "$BOLD" "$NC" "$DIM" "$NC"
  printf '\n'
  _draw_fvm

  while true; do
    _read_key
    case "$KEY" in
      w|$'\x1b[A') cursor=0 ;;
      s|$'\x1b[B') cursor=1 ;;
      "") break ;;
    esac
    tput cuu $MENU_LINES 2>/dev/null
    _draw_fvm
  done

  tput cnorm 2>/dev/null
  printf '\n'
  USE_FVM=$([ "$cursor" -eq 0 ] && printf 'true' || printf 'false')
}

# ── Step 3 — Detect base package name from project ───────────────────────────

detect_base_package() {
  # cwd is already project root (set in main)
  BASE_PACKAGE=$(grep -E 'applicationId\s*[=]?\s*"' \
    android/app/build.gradle.kts \
    android/app/build.gradle 2>/dev/null \
    | grep -oE '"[^"]+"' | tr -d '"' | head -1)

  if [ -n "$BASE_PACKAGE" ]; then
    printf '%bPackage name detected:%b %s\n\n' "$DIM" "$NC" "$BASE_PACKAGE"
  else
    printf '%b⚠  Could not detect package name from build.gradle.%b\n' "$YELLOW" "$NC"
    printf 'Enter base package name manually: '
    read -r BASE_PACKAGE
    while [ -z "$BASE_PACKAGE" ]; do
      printf '%b  Cannot be empty. Try again:%b\n> ' "$YELLOW" "$NC"
      read -r BASE_PACKAGE
    done
    printf '\n'
  fi
}

# ── Step 4 — Flavor multi-select ─────────────────────────────────────────────

select_flavors() {
  local total=$(( ${#FLAVORS[@]} + 1 ))
  local cursor=0
  local START_IDX=${#FLAVORS[@]}

  _draw_flavors() {
    for i in "${!FLAVORS[@]}"; do
      local f="${FLAVORS[$i]}"
      local box="☐"
      _is_checked "$f" && box="☑"
      if [ "$i" -eq "$cursor" ]; then
        printf '  %b%b▶  %s  %s%b\n' "$CYAN" "$BOLD" "$box" "$f" "$NC"
      else
        printf '     %s  %s\n' "$box" "$f"
      fi
    done
    if [ "$cursor" -eq "$START_IDX" ]; then
      printf '  %b%b▶  → Start setup%b\n' "$GREEN" "$BOLD" "$NC"
    else
      printf '  %b   → Start setup%b\n' "$DIM" "$NC"
    fi
  }

  tput civis 2>/dev/null
  printf '%bSelect flavors to configure:%b  %b(w/↑ · s/↓ navigate · Enter toggle/start)%b\n' \
    "$BOLD" "$NC" "$DIM" "$NC"
  printf '\n'
  _draw_flavors

  while true; do
    _read_key
    case "$KEY" in
      w|$'\x1b[A')
        ((cursor--))
        [ "$cursor" -lt 0 ] && cursor=$(( total - 1 ))
        ;;
      s|$'\x1b[B')
        ((cursor++))
        [ "$cursor" -ge "$total" ] && cursor=0
        ;;
      "")
        if [ "$cursor" -eq "$START_IDX" ]; then
          break
        else
          _toggle "${FLAVORS[$cursor]}"
        fi
        ;;
    esac
    tput cuu $total 2>/dev/null
    _draw_flavors
  done

  tput cnorm 2>/dev/null
  printf '\n'

  local count=0
  for c in "${CHECKED[@]}"; do [[ -n "$c" ]] && ((count++)); done
  if [ "$count" -eq 0 ]; then
    printf '%bNo flavor selected. Please select at least one.%b\n\n' "$YELLOW" "$NC"
    select_flavors
  fi
}

# ── Step 5 — Ensure Firebase project exists (create if needed) ───────────────

# Returns 0 if project is ready, 1 if user chose to skip.
_ensure_project() {
  local pid="$1"

  printf '%b   Checking project "%s"...%b ' "$DIM" "$pid" "$NC"

  # Check if project already exists in the account's project list
  # LC_ALL=C: macOS BSD grep fails on UTF-8 input without this
  # Exact match: project ID surrounded by non-[a-z0-9-] chars (avoids partial hits like "f-base" matching "f-base-dev")
  if firebase projects:list 2>/dev/null | LC_ALL=C grep -qE "(^|[^a-z0-9-])${pid}([^a-z0-9-]|$)"; then
    printf '%b found.%b\n' "$GREEN" "$NC"
    return 0
  fi

  printf '%bnot found.%b\n\n' "$YELLOW" "$NC"

  # Ask: create or skip
  local cursor=0   # default: Create
  local MENU_LINES=2

  _draw_create_menu() {
    if [ "$cursor" -eq 0 ]; then
      printf '  %b%b▶  Create "%s" on Firebase%b\n' "$CYAN" "$BOLD" "$pid" "$NC"
      printf '     Skip this flavor\n'
    else
      printf '     Create "%s" on Firebase\n' "$pid"
      printf '  %b%b▶  Skip this flavor%b\n' "$CYAN" "$BOLD" "$NC"
    fi
  }

  tput civis 2>/dev/null
  _draw_create_menu

  while true; do
    _read_key
    case "$KEY" in
      w|$'\x1b[A') cursor=0 ;;
      s|$'\x1b[B') cursor=1 ;;
      "") break ;;
    esac
    tput cuu $MENU_LINES 2>/dev/null
    _draw_create_menu
  done

  tput cnorm 2>/dev/null
  printf '\n'

  if [ "$cursor" -eq 1 ]; then
    printf '%b   Skipped.%b\n' "$DIM" "$NC"
    return 1
  fi

  printf '%b▶  Running: firebase projects:create %s%b\n\n' "$YELLOW" "$pid" "$NC"
  firebase projects:create "$pid" --display-name "$pid"

  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    printf '\n%b✗  Failed to create project "%s" (exit %s).%b\n' "$YELLOW" "$pid" "$exit_code" "$NC"
    printf '%b   Check quota/permissions at https://console.firebase.google.com%b\n' "$DIM" "$NC"
    return 1
  fi

  printf '\n%b✓  Project "%s" created.%b\n' "$GREEN" "$pid" "$NC"
  return 0
}

# ── Step 6 — Configure one flavor ────────────────────────────────────────────

configure_flavor() {
  local flavor="$1"
  local out="lib/firebase/${flavor}/firebase_options.dart"

  # Default suffix: .dev / .uat / empty for prod
  local default_suffix=""
  [[ "$flavor" != "prod" ]] && default_suffix=".$flavor"

  printf '\n'
  printf '%b[%s]%b Firebase project-id: ' "$BOLD" "$flavor" "$NC"
  read -r _raw_project_id
  # Sanitize: Firebase project IDs allow only lowercase letters, digits, hyphens
  project_id=$(printf '%s' "$_raw_project_id" | LC_ALL=C tr -cd 'a-z0-9A-Z-')

  if [ -z "$project_id" ]; then
    printf '%b  Skipped [%s] — no project-id entered.%b\n' "$YELLOW" "$flavor" "$NC"
    return 1
  fi

  printf '%b[%s]%b Package suffix %b[%s]%b (Enter = default, space = none): ' \
    "$BOLD" "$flavor" "$NC" "$DIM" "$default_suffix" "$NC"
  read -r _raw_suffix
  local pkg_suffix_input
  pkg_suffix_input=$(printf '%s' "$_raw_suffix" | LC_ALL=C tr -cd 'a-z0-9A-Z._-')
  if [ "$pkg_suffix_input" = " " ] || [ "$pkg_suffix_input" = "none" ]; then
    pkg_suffix=""
  elif [ -z "$pkg_suffix_input" ]; then
    pkg_suffix="$default_suffix"
  else
    # Auto-prepend dot if user typed e.g. "dev" instead of ".dev"
    if [[ "$pkg_suffix_input" != .* ]]; then
      pkg_suffix=".${pkg_suffix_input}"
    else
      pkg_suffix="$pkg_suffix_input"
    fi
  fi

  local android_pkg="${BASE_PACKAGE}${pkg_suffix}"
  local ios_bundle="${BASE_PACKAGE}${pkg_suffix}"

  printf '%b   -> %s%b\n\n' "$DIM" "$android_pkg" "$NC"

  _ensure_project "$project_id" || return 1

  printf '\n'
  printf '%b▶  Configuring flutterfire for [%s]...%b\n\n' "$YELLOW" "$flavor" "$NC"

  if [ "$USE_FVM" = "true" ]; then
    fvm dart pub global run flutterfire_cli:flutterfire configure \
      --project="$project_id" \
      --out="$out" \
      --platforms=android,ios \
      --android-package-name="$android_pkg" \
      --ios-bundle-id="$ios_bundle" \
      --yes
  else
    flutterfire configure \
      --project="$project_id" \
      --out="$out" \
      --platforms=android,ios \
      --android-package-name="$android_pkg" \
      --ios-bundle-id="$ios_bundle" \
      --yes
  fi

  local exit_code=$?
  printf '\n'
  if [ $exit_code -ne 0 ]; then
    printf '%b✗  [%s] failed (exit %s).%b\n' "$YELLOW" "$flavor" "$exit_code" "$NC"
    return 1
  fi

  printf '%b✓  [%s] firebase_options.dart -> %s%b\n' "$GREEN" "$flavor" "$out" "$NC"

  # ── Copy google-services.json to flavor src dir ──
  local android_src="android/app/src/${flavor}"
  local android_json="android/app/google-services.json"
  if [ -f "$android_json" ]; then
    mkdir -p "$android_src"
    cp "$android_json" "${android_src}/google-services.json"
    printf '%b✓  [%s] google-services.json -> %s/%b\n' "$GREEN" "$flavor" "$android_src" "$NC"
  else
    printf '%b⚠  [%s] android/app/google-services.json not found — skipped copy.%b\n' "$YELLOW" "$flavor" "$NC"
  fi

  # ── Copy GoogleService-Info.plist to flavor ios dir ──
  local ios_src="ios/config/${flavor}"
  local ios_plist="ios/Runner/GoogleService-Info.plist"
  if [ -f "$ios_plist" ]; then
    mkdir -p "$ios_src"
    cp "$ios_plist" "${ios_src}/GoogleService-Info.plist"
    printf '%b✓  [%s] GoogleService-Info.plist -> %s/%b\n' "$GREEN" "$flavor" "$ios_src" "$NC"
  else
    printf '%b⚠  [%s] ios/Runner/GoogleService-Info.plist not found — skipped copy.%b\n' "$YELLOW" "$flavor" "$NC"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

# Always run from Flutter project root (script may be invoked from scripts/)
_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$_PROJECT_ROOT" || { printf 'Cannot cd to project root\n'; exit 1; }

printf '\n'
printf '%b🔥 FlutterFire setup%b\n' "$BOLD" "$NC"
printf '────────────────────────────────────\n'

check_firebase_auth
ask_fvm
detect_base_package
select_flavors

printf '────────────────────────────────────\n'
printf '%bSetting up selected flavors...%b\n\n' "$BOLD" "$NC"

failed=()
for flavor in "${FLAVORS[@]}"; do
  if _is_checked "$flavor"; then
    configure_flavor "$flavor" || failed+=("$flavor")
  fi
done

printf '\n────────────────────────────────────\n'
if [ ${#failed[@]} -gt 0 ]; then
  printf '%b⚠  Completed with errors. Failed flavors:%b\n' "$YELLOW" "$NC"
  for f in "${failed[@]}"; do
    printf '   • %s\n' "$f"
  done
  printf '%b   Re-run the script after creating the missing Firebase projects.%b\n\n' "$DIM" "$NC"
else
  printf '%b%b🎉 All done!%b\n\n' "$GREEN" "$BOLD" "$NC"
  printf '%bRemember to copy the native config files:%b\n' "$DIM" "$NC"
  printf '  google-services.json     → android/app/src/{flavor}/\n'
  printf '  GoogleService-Info.plist → ios/config/{flavor}/\n\n'
fi
