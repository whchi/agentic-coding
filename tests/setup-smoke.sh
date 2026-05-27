#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentic-coding-setup.XXXXXX")"
RUN_CWD="$TMP_ROOT/run-cwd"
TARGET="$TMP_ROOT/target-project"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

mkdir -p "$RUN_CWD" "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_not_exists() {
  [[ ! -e "$1" ]] || fail "expected path not to exist: $1"
}

output="$(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex install skills --project frontend-patterns --target "$TARGET" --dry-run
)"

assert_contains "$output" "Project target: $TARGET"
assert_contains "$output" "Dry run: no files will be changed"
assert_contains "$output" "dry-run install"
assert_not_exists "$TARGET/.codex"
assert_not_exists "$RUN_CWD/.codex"

(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex install skills --project frontend-patterns --target "$TARGET"
)

assert_file "$TARGET/.codex/skills/frontend-patterns/SKILL.md"
assert_not_exists "$RUN_CWD/.codex"

output="$(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex uninstall skills --project frontend-patterns --target "$TARGET" --dry-run
)"

assert_contains "$output" "dry-run uninstall"
assert_file "$TARGET/.codex/skills/frontend-patterns/SKILL.md"

echo "setup smoke checks passed"
