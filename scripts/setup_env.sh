#!/bin/bash

# Re-exec with bash if invoked via sh/dash
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# setup_env.sh
# Copy .env.*.example → .env.* for one or more flavors.
#
# Usage: bash scripts/setup_env.sh  (or: sh scripts/setup_env.sh)
#
# Navigation:
#   w / ↑   = move up
#   s / ↓   = move down
#   Enter   = toggle selection (flavor list) / confirm (Start)

# ── Always run from Flutter project root ─────────────────────────────────────

_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$_PROJECT_ROOT" || { printf 'Cannot cd to project root\n'; exit 1; }

ENV_DIR="assets/env"

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

# ── Flavor multi-select ───────────────────────────────────────────────────────

select_flavors() {
  local total=$(( ${#FLAVORS[@]} + 1 ))
  local cursor=0
  local START_IDX=${#FLAVORS[@]}

  _draw() {
    for i in "${!FLAVORS[@]}"; do
      local f="${FLAVORS[$i]}"
      local src="${ENV_DIR}/.env.${f}.example"
      local dst="${ENV_DIR}/.env.${f}"
      local status_label=""
      [ -f "$dst" ] && status_label="${DIM} (already exists)${NC}"
      local box="☐"
      _is_checked "$f" && box="☑"
      if [ "$i" -eq "$cursor" ]; then
        printf "  %b%b▶  %s  %s%b%b\n" "$CYAN" "$BOLD" "$box" "$f" "$NC" "$status_label"
      else
        printf "     %s  %s%b%b\n" "$box" "$f" "$NC" "$status_label"
      fi
    done
    if [ "$cursor" -eq "$START_IDX" ]; then
      printf '  %b%b▶  -> Copy selected%b\n' "$GREEN" "$BOLD" "$NC"
    else
      printf '  %b   -> Copy selected%b\n' "$DIM" "$NC"
    fi
  }

  tput civis 2>/dev/null
  printf '%bSelect flavors to set up:%b  %b(w/↑ · s/↓ · Enter toggle/confirm)%b\n' \
    "$BOLD" "$NC" "$DIM" "$NC"
  printf '\n'
  _draw

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
    _draw
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

# ── Copy env files ────────────────────────────────────────────────────────────

copy_envs() {
  printf '────────────────────────────────────\n'
  local any_fail=0

  for flavor in "${FLAVORS[@]}"; do
    _is_checked "$flavor" || continue

    local src="${ENV_DIR}/.env.${flavor}.example"
    local dst="${ENV_DIR}/.env.${flavor}"

    if [ ! -f "$src" ]; then
      printf '%b✗  [%s] %s not found — skipped.%b\n' "$YELLOW" "$flavor" "$src" "$NC"
      any_fail=1
      continue
    fi

    # Ask before overwriting if destination already exists
    if [ -f "$dst" ]; then
      printf '%b⚠  [%s] .env.%s already exists. Overwrite? (y/N): %b' \
        "$YELLOW" "$flavor" "$flavor" "$NC"
      read -r _answer
      if [[ "$_answer" != "y" && "$_answer" != "Y" ]]; then
        printf '%b   Skipped.%b\n' "$DIM" "$NC"
        continue
      fi
    fi

    cp "$src" "$dst"
    printf '%b✓  [%s] %s created.%b\n' "$GREEN" "$flavor" "$dst" "$NC"
    printf '%b   Open %s and fill in the real values.%b\n' "$DIM" "$dst" "$NC"
  done

  printf '\n'
  if [ "$any_fail" -eq 0 ]; then
    printf '%b%bDone!%b Fill in API keys / URLs in each .env file before running the app.\n\n' \
      "$GREEN" "$BOLD" "$NC"
  else
    printf '%b⚠  Completed with some errors. Check messages above.%b\n\n' "$YELLOW" "$NC"
  fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

printf '\n'
printf '%b⚙  Setup env files%b\n' "$BOLD" "$NC"
printf '────────────────────────────────────\n'

select_flavors
copy_envs
