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

assert_not_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" != *"$needle"* ]] || fail "expected output not to contain: $needle"
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

GEMINI_HOME="$TMP_ROOT/gemini-home"
output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install all --global --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $GEMINI_HOME/.gemini/skills"
assert_contains "$output" "dry-run install $ROOT/commands/debug-triage.md → $GEMINI_HOME/.gemini/commands/debug-triage.toml"
assert_not_contains "$output" "$GEMINI_HOME/.gemini/antigravity-cli"

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install commands --global debug-triage
)

assert_file "$GEMINI_HOME/.gemini/commands/debug-triage.toml"
rg -Fq "prompt = '''" "$GEMINI_HOME/.gemini/commands/debug-triage.toml" || fail "Gemini command missing TOML prompt"
assert_not_contains "$(cat "$GEMINI_HOME/.gemini/commands/debug-triage.toml")" "---"
python3 - "$GEMINI_HOME/.gemini/commands/debug-triage.toml" <<'PY'
import sys
import tomllib

with open(sys.argv[1], "rb") as command_file:
    command = tomllib.load(command_file)
assert command["prompt"].lstrip().startswith("# /debug-triage")
assert command["description"].startswith("Triage a bug")
PY

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini reinstall commands --global debug-triage
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini uninstall commands --global debug-triage
)

assert_not_exists "$GEMINI_HOME/.gemini/commands/debug-triage.toml"

output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install all --project --target "$TARGET" --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $TARGET/.gemini/skills"
assert_contains "$output" "dry-run install $ROOT/commands/debug-triage.md → $TARGET/.gemini/commands/debug-triage.toml"
assert_not_contains "$output" "$TARGET/.agents/skills"

output="$(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex uninstall skills --project frontend-patterns --target "$TARGET" --dry-run
)"

assert_contains "$output" "dry-run uninstall"
assert_file "$TARGET/.codex/skills/frontend-patterns/SKILL.md"

echo "setup smoke checks passed"
