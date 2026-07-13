#!/bin/bash

# Re-exec with bash if invoked via sh/dash
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# config_firebase.sh
# Run flutterfire configure for one or all flavors using predefined project configs.
#
# Usage:
#   bash scripts/config_firebase.sh          — configure all flavors (dev → uat → prod)
#   bash scripts/config_firebase.sh dev      — configure dev only
#   bash scripts/config_firebase.sh uat      — configure uat only
#   bash scripts/config_firebase.sh prod     — configure prod only

# ── Colors ───────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ── Flavor config table ───────────────────────────────────────────────────────
# Format: PROJECT_ID ANDROID_PACKAGE IOS_BUNDLE

_project_id() {
  case "$1" in
    dev)  echo "f-base-dev"  ;;
    uat)  echo "f-base-uat"  ;;
    prod) echo "f-base-prod" ;;
  esac
}

_android_pkg() {
  case "$1" in
    dev)  echo "com.fox.base.flutter.dev" ;;
    uat)  echo "com.fox.base.flutter.uat" ;;
    prod) echo "com.fox.base.flutter"     ;;
  esac
}

_ios_bundle() {
  case "$1" in
    dev)  echo "com.fox.base.flutter.dev" ;;
    uat)  echo "com.fox.base.flutter.uat" ;;
    prod) echo "com.fox.base.flutter"     ;;
  esac
}

# ── Configure one flavor ──────────────────────────────────────────────────────

configure_flavor() {
  local flavor="$1"
  local project_id android_pkg ios_bundle out

  project_id="$(_project_id "$flavor")"
  android_pkg="$(_android_pkg "$flavor")"
  ios_bundle="$(_ios_bundle "$flavor")"
  out="lib/firebase/${flavor}/firebase_options.dart"

  printf '\n%b[%s]%b project=%s  android=%s  ios=%s\n' \
    "$CYAN$BOLD" "$flavor" "$NC" "$project_id" "$android_pkg" "$ios_bundle"
  printf '%b▶  Running flutterfire configure...%b\n\n' "$YELLOW" "$NC"

  fvm dart pub global run flutterfire_cli:flutterfire configure \
    --project="$project_id" \
    --out="$out" \
    --platforms=android,ios \
    --android-package-name="$android_pkg" \
    --ios-bundle-id="$ios_bundle" \
    --yes

  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    printf '\n%b✗  [%s] flutterfire configure failed (exit %s).%b\n' "$YELLOW" "$flavor" "$exit_code" "$NC"
    return 1
  fi

  printf '\n%b✓  [%s] firebase_options.dart written to %s%b\n' "$GREEN" "$flavor" "$out" "$NC"

  # Copy google-services.json → android/app/src/{flavor}/
  local android_src="android/app/src/${flavor}"
  local android_json="android/app/google-services.json"
  if [ -f "$android_json" ]; then
    mkdir -p "$android_src"
    cp "$android_json" "${android_src}/google-services.json"
    printf '%b✓  [%s] google-services.json  → %s/%b\n' "$GREEN" "$flavor" "$android_src" "$NC"
  else
    printf '%b⚠  [%s] android/app/google-services.json not found — skipped.%b\n' "$YELLOW" "$flavor" "$NC"
  fi

  # Copy GoogleService-Info.plist → ios/config/{flavor}/
  local ios_src="ios/config/${flavor}"
  local ios_plist="ios/Runner/GoogleService-Info.plist"
  if [ -f "$ios_plist" ]; then
    mkdir -p "$ios_src"
    cp "$ios_plist" "${ios_src}/GoogleService-Info.plist"
    printf '%b✓  [%s] GoogleService-Info.plist → %s/%b\n' "$GREEN" "$flavor" "$ios_src" "$NC"
  else
    printf '%b⚠  [%s] ios/Runner/GoogleService-Info.plist not found — skipped.%b\n' "$YELLOW" "$flavor" "$NC"
  fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

_PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$_PROJECT_ROOT" || { printf 'Cannot cd to project root\n'; exit 1; }

# Authenticate Firebase (reuse shared helper)
# shellcheck source=auth_firebase.sh
source "$(dirname "${BASH_SOURCE[0]}")/auth_firebase.sh"
check_firebase_auth

printf '\n%b🔥 config_firebase%b\n' "$BOLD" "$NC"
printf '────────────────────────────────────\n'

FLAVORS=("dev" "uat" "prod")
TARGET="$1"

if [ -n "$TARGET" ]; then
  # Validate
  valid=false
  for f in "${FLAVORS[@]}"; do [[ "$f" == "$TARGET" ]] && valid=true; done
  if [ "$valid" = false ]; then
    printf '%b✗  Unknown flavor "%s". Valid: dev | uat | prod%b\n\n' "$YELLOW" "$TARGET" "$NC"
    exit 1
  fi
  FLAVORS=("$TARGET")
fi

printf '%bFlavors:%b %s\n' "$DIM" "$NC" "${FLAVORS[*]}"

failed=()
for flavor in "${FLAVORS[@]}"; do
  configure_flavor "$flavor" || failed+=("$flavor")
done

printf '\n────────────────────────────────────\n'
if [ ${#failed[@]} -gt 0 ]; then
  printf '%b⚠  Completed with errors. Failed:%b\n' "$YELLOW" "$NC"
  for f in "${failed[@]}"; do printf '   • %s\n' "$f"; done
  printf '\n'
  exit 1
else
  printf '%b%b✓  Done!%b\n\n' "$GREEN" "$BOLD" "$NC"
fi
