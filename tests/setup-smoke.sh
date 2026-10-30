#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentic-coding-setup.XXXXXX")"
RUN_CWD="$TMP_ROOT/run-cwd"
TARGET="$TMP_ROOT/target-project"
GEMINI_TARGET="$TMP_ROOT/gemini-target-project"
ALL_TARGET="$TMP_ROOT/all-target-project"
ALL_HOME="$TMP_ROOT/all-home"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

mkdir -p "$RUN_CWD" "$TARGET" "$GEMINI_TARGET" "$ALL_TARGET" "$ALL_HOME"
TARGET="$(cd "$TARGET" && pwd)"
GEMINI_TARGET="$(cd "$GEMINI_TARGET" && pwd)"
ALL_TARGET="$(cd "$ALL_TARGET" && pwd)"

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
assert_not_exists "$TARGET/.agents"
assert_not_exists "$RUN_CWD/.agents"

(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex install skills --project frontend-patterns --target "$TARGET"
)

assert_file "$TARGET/.agents/skills/frontend-patterns/SKILL.md"
assert_not_exists "$RUN_CWD/.agents"

output="$("$ROOT/setup.sh" codex install skills --project frontend-patterns --target "$TARGET")"
assert_contains "$output" "already consistent: $TARGET/.agents/skills/frontend-patterns"

GEMINI_HOME="$TMP_ROOT/gemini-home"
output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install all --global --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $GEMINI_HOME/.gemini/config/skills"
assert_contains "$output" "dry-run install $ROOT/commands/debug-triage.md → $GEMINI_HOME/.gemini/commands/debug-triage.toml"
assert_not_contains "$output" "$GEMINI_HOME/.gemini/antigravity-cli"

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install commands --global debug-triage
)

assert_file "$GEMINI_HOME/.gemini/commands/debug-triage.toml"
rg -Fq "prompt = '''" "$GEMINI_HOME/.gemini/commands/debug-triage.toml" || fail "Gemini command missing TOML prompt"
assert_not_contains "$(cat "$GEMINI_HOME/.gemini/commands/debug-triage.toml")" "---"
python3 - "$GEMINI_HOME/.gemini/commands/debug-triage.toml" "$ROOT/commands/debug-triage.md" <<'PY'
from pathlib import Path
import sys
import tomllib

with open(sys.argv[1], "rb") as command_file:
    command = tomllib.load(command_file)
source = Path(sys.argv[2]).read_text()
description = source.splitlines()[1].removeprefix("description:").strip().strip('"')
assert command["description"] == description
assert command["prompt"].strip() == source.split("---", 2)[2].strip()
PY

output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install commands --global debug-triage
)"
assert_contains "$output" "already consistent: $GEMINI_HOME/.gemini/commands/debug-triage.toml"

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini reinstall commands --global debug-triage
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini uninstall commands --global debug-triage
)

assert_not_exists "$GEMINI_HOME/.gemini/commands/debug-triage.toml"

for provider in opencode pi; do
  for action in install reinstall uninstall; do
    if output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" "$provider" "$action" all --global 2>&1)"; then
      fail "$provider should be disabled for $action"
    fi
    assert_contains "$output" 'codex|claude|gemini|all'
  done
done
assert_not_exists "$ALL_HOME/.config/opencode"
assert_not_exists "$ALL_HOME/.pi"
assert_not_exists "$ALL_HOME/.agents"

output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all install all --global)"
for provider in codex claude gemini; do
  assert_contains "$output" "=== $provider ==="
done
assert_not_contains "$output" '=== opencode ==='
assert_not_contains "$output" '=== pi ==='
assert_file "$ALL_HOME/.agents/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.claude/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.gemini/config/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.codex/prompts/debug-triage.md"
assert_file "$ALL_HOME/.claude/commands/debug-triage.md"
assert_file "$ALL_HOME/.gemini/commands/debug-triage.toml"
assert_not_exists "$ALL_HOME/.config/opencode"
assert_not_exists "$ALL_HOME/.pi"

output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all install all --project --target "$ALL_TARGET")"
for provider in codex claude gemini; do
  assert_contains "$output" "=== $provider ==="
done
assert_not_contains "$output" '=== opencode ==='
assert_not_contains "$output" '=== pi ==='
assert_file "$ALL_TARGET/.agents/skills/frontend-patterns/SKILL.md"
assert_file "$ALL_TARGET/.claude/skills/frontend-patterns/SKILL.md"
assert_file "$ALL_TARGET/.codex/prompts/debug-triage.md"
assert_file "$ALL_TARGET/.claude/commands/debug-triage.md"
assert_file "$ALL_TARGET/.gemini/commands/debug-triage.toml"
assert_not_exists "$ALL_TARGET/.opencode"
assert_not_exists "$ALL_TARGET/.pi"

output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install all --project --target "$GEMINI_TARGET" --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $GEMINI_TARGET/.agents/skills"
assert_contains "$output" "dry-run install $ROOT/commands/debug-triage.md → $GEMINI_TARGET/.gemini/commands/debug-triage.toml"
assert_not_contains "$output" "$GEMINI_TARGET/.gemini/skills"

output="$(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex uninstall skills --project frontend-patterns --target "$TARGET" --dry-run
)"

assert_contains "$output" "dry-run uninstall"
assert_file "$TARGET/.agents/skills/frontend-patterns/SKILL.md"

echo "setup smoke checks passed"
