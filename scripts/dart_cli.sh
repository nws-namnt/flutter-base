#!/usr/bin/env bash
# Run dart_cli from any location within the project.
# Usage: ./scripts/dart_cli.sh [args...]
#   e.g: ./scripts/dart_cli.sh --help
#   e.g: ./scripts/dart_cli.sh build -f dev

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CLI_ENTRY="$PROJECT_ROOT/pkgs/dart_cli/bin/cli_runner.dart"

# Support FVM if available, fallback to system dart
if command -v fvm &>/dev/null; then
  DART="fvm dart"
else
  DART="dart"
fi

$DART run "$CLI_ENTRY" "$@"
