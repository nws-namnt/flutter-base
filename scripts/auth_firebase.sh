#!/bin/bash

# Re-exec with bash if invoked via sh/dash
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# auth_firebase.sh
# Checks Firebase login state and handles auth before setup.
#
# Usage (standalone):  bash scripts/auth_firebase.sh
# Usage (sourced):     source scripts/auth_firebase.sh  →  call check_firebase_auth

# ── Colors (guard: only set if not already defined by parent) ─────────────────

GREEN="${GREEN:-\033[0;32m}"
YELLOW="${YELLOW:-\033[1;33m}"
CYAN="${CYAN:-\033[0;36m}"
BOLD="${BOLD:-\033[1m}"
DIM="${DIM:-\033[2m}"
NC="${NC:-\033[0m}"

# ── _read_key (guard: only define if not already provided by parent) ──────────

if ! declare -f _read_key > /dev/null 2>&1; then
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
fi

# ── check_firebase_auth ───────────────────────────────────────────────────────
#
# 1. Verifies firebase CLI is installed.
# 2. Reads current logged-in account via `firebase login:list`.
# 3. If not logged in → runs `firebase login`.
# 4. If already logged in → shows the current user and asks:
#      ▶  Switch to another user
#         Continue as <email>

check_firebase_auth() {
  # ── Check firebase CLI ──
  if ! command -v firebase &>/dev/null; then
    printf '\n'
    printf '%b⚠  Firebase CLI not found.%b\n' "$YELLOW" "$NC"
    printf '   Install it first:\n\n'
    printf '   npm install -g firebase-tools\n\n'
    exit 1
  fi

  # ── Get current user ──
  local login_list
  login_list=$(firebase login:list 2>/dev/null)

  local current_user
  current_user=$(printf '%s' "$login_list" \
    | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' \
    | head -1)

  if [ -z "$current_user" ]; then
    printf '\n'
    printf '%b▶  Not logged in to Firebase. Running: firebase login%b\n\n' "$YELLOW" "$NC"
    firebase login
    printf '\n'
    return
  fi

  # ── Already logged in ──
  printf '\n'
  printf '%b✓  Logged in as: %b%s%b\n' "$GREEN" "$BOLD" "$current_user" "$NC"
  printf '\n'

  local cursor=1   # default: Continue
  local MENU_LINES=2

  _draw_auth_menu() {
    if [ "$cursor" -eq 0 ]; then
      printf '  %b%b▶  Switch to another user%b\n' "$CYAN" "$BOLD" "$NC"
      printf '     Continue as %s\n' "$current_user"
    else
      printf '     Switch to another user\n'
      printf '  %b%b▶  Continue as %s%b\n' "$CYAN" "$BOLD" "$current_user" "$NC"
    fi
  }

  tput civis 2>/dev/null
  _draw_auth_menu

  while true; do
    _read_key
    case "$KEY" in
      w|$'\x1b[A') cursor=0 ;;
      s|$'\x1b[B') cursor=1 ;;
      "") break ;;
    esac
    tput cuu $MENU_LINES 2>/dev/null
    _draw_auth_menu
  done

  tput cnorm 2>/dev/null
  printf '\n'

  if [ "$cursor" -eq 0 ]; then
    printf '%b▶  Switching account... Running: firebase login%b\n\n' "$YELLOW" "$NC"
    firebase login
    printf '\n'
  fi
}

# ── Run standalone if executed directly (not sourced) ────────────────────────

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  check_firebase_auth
fi
