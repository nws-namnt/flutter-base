#!/bin/bash

# Re-exec with bash if invoked via sh/dash
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# replace_package.sh
# Change the app package name using change_app_package_name.
#
# Usage: bash scripts/replace_package.sh  (or: sh scripts/replace_package.sh)
#
# Navigation:
#   w / ↑   = move up
#   s / ↓   = move down
#   Enter   = confirm

# ── Always run from Flutter project root ─────────────────────────────────────

_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$_PROJECT_ROOT" || { printf 'Cannot cd to project root\n'; exit 1; }

# ── Colors ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

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

# ── Step 1 — FVM? ────────────────────────────────────────────────────────────

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

# ── Step 2 — Check / install change_app_package_name ─────────────────────────

check_package_tool() {
  # Check if change_app_package_name is in pubspec.yaml (dev or regular deps)
  if LC_ALL=C grep -q 'change_app_package_name' pubspec.yaml 2>/dev/null; then
    printf '%b✓  change_app_package_name is available.%b\n\n' "$GREEN" "$NC"
    return 0
  fi

  printf '%b⚠  change_app_package_name not found in pubspec.yaml.%b\n\n' "$YELLOW" "$NC"

  # Ask: install now or skip
  local cursor=0   # default: Install now
  local MENU_LINES=2

  _draw_install_menu() {
    if [ "$cursor" -eq 0 ]; then
      printf '  %b%b▶  Install now%b\n' "$CYAN" "$BOLD" "$NC"
      printf '     Skip (add it manually later)\n'
    else
      printf '     Install now\n'
      printf '  %b%b▶  Skip (add it manually later)%b\n' "$CYAN" "$BOLD" "$NC"
    fi
  }

  tput civis 2>/dev/null
  _draw_install_menu

  while true; do
    _read_key
    case "$KEY" in
      w|$'\x1b[A') cursor=0 ;;
      s|$'\x1b[B') cursor=1 ;;
      "") break ;;
    esac
    tput cuu $MENU_LINES 2>/dev/null
    _draw_install_menu
  done

  tput cnorm 2>/dev/null
  printf '\n'

  if [ "$cursor" -eq 1 ]; then
    printf '%b⚠  Skipped. Add change_app_package_name to pubspec.yaml manually, then re-run this script.%b\n\n' "$DIM" "$NC"
    exit 0
  fi

  # Install the package
  printf '%b▶  Installing change_app_package_name...%b\n\n' "$YELLOW" "$NC"
  if [ "$USE_FVM" = "true" ]; then
    fvm flutter pub add change_app_package_name
  else
    flutter pub add change_app_package_name
  fi

  local exit_code=$?
  printf '\n'
  if [ $exit_code -ne 0 ]; then
    printf '%b✗  Failed to install package (exit %s). Check your Flutter setup.%b\n\n' "$YELLOW" "$exit_code" "$NC"
    exit 1
  fi

  printf '%b✓  Installed successfully.%b\n\n' "$GREEN" "$NC"
}

# ── Step 3 — Ask new package name ────────────────────────────────────────────

ask_new_package() {
  printf '%bNew package name%b  %b(e.g. com.example.app)%b\n' "$BOLD" "$NC" "$DIM" "$NC"
  printf '> '
  read -r _raw_pkg
  # Sanitize: keep only valid package name characters
  NEW_PACKAGE=$(printf '%s' "$_raw_pkg" | LC_ALL=C tr -cd 'a-z0-9A-Z._-')

  while [ -z "$NEW_PACKAGE" ]; do
    printf '%b  Cannot be empty. Try again:%b\n> ' "$YELLOW" "$NC"
    read -r _raw_pkg
    NEW_PACKAGE=$(printf '%s' "$_raw_pkg" | LC_ALL=C tr -cd 'a-z0-9A-Z._-')
  done

  printf '\n'
  printf '%b   -> %s%b\n\n' "$DIM" "$NEW_PACKAGE" "$NC"
}

# ── Step 4 — Run change_app_package_name ─────────────────────────────────────

run_rename() {
  printf '%b▶  Running package rename...%b\n\n' "$YELLOW" "$NC"

  if [ "$USE_FVM" = "true" ]; then
    fvm dart run change_app_package_name:main "$NEW_PACKAGE"
  else
    dart run change_app_package_name:main "$NEW_PACKAGE"
  fi

  local exit_code=$?
  printf '\n'
  if [ $exit_code -ne 0 ]; then
    printf '%b✗  Rename failed (exit %s).%b\n\n' "$YELLOW" "$exit_code" "$NC"
    exit 1
  fi

  printf '%b✓  Package renamed to: %s%b\n\n' "$GREEN" "$NEW_PACKAGE" "$NC"
}

# ── Main ─────────────────────────────────────────────────────────────────────

printf '\n'
printf '%b📦 Replace App Package Name%b\n' "$BOLD" "$NC"
printf '────────────────────────────────────\n'

ask_fvm
check_package_tool
ask_new_package

printf '────────────────────────────────────\n'
run_rename
