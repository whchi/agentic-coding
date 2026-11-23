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
assert_contains "$output" "dry-run install $ROOT/commands/update-codemaps.md → $GEMINI_HOME/.gemini/commands/update-codemaps.toml"
assert_not_contains "$output" "$GEMINI_HOME/.gemini/antigravity-cli"

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install commands --global update-codemaps
)

assert_file "$GEMINI_HOME/.gemini/commands/update-codemaps.toml"
rg -Fq "prompt = '''" "$GEMINI_HOME/.gemini/commands/update-codemaps.toml" || fail "Gemini command missing TOML prompt"
assert_not_contains "$(cat "$GEMINI_HOME/.gemini/commands/update-codemaps.toml")" "---"
python3 - "$GEMINI_HOME/.gemini/commands/update-codemaps.toml" "$ROOT/commands/update-codemaps.md" <<'PY'
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
    "$ROOT/setup.sh" gemini install commands --global update-codemaps
)"
assert_contains "$output" "already consistent: $GEMINI_HOME/.gemini/commands/update-codemaps.toml"

(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini reinstall commands --global update-codemaps
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini uninstall commands --global update-codemaps
)

assert_not_exists "$GEMINI_HOME/.gemini/commands/update-codemaps.toml"

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
assert_file "$ALL_HOME/.codex/prompts/update-codemaps.md"
assert_file "$ALL_HOME/.claude/commands/update-codemaps.md"
assert_file "$ALL_HOME/.gemini/commands/update-codemaps.toml"
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
assert_file "$ALL_TARGET/.codex/prompts/update-codemaps.md"
assert_file "$ALL_TARGET/.claude/commands/update-codemaps.md"
assert_file "$ALL_TARGET/.gemini/commands/update-codemaps.toml"
assert_not_exists "$ALL_TARGET/.opencode"
assert_not_exists "$ALL_TARGET/.pi"

output="$(
  HOME="$GEMINI_HOME" \
    "$ROOT/setup.sh" gemini install all --project --target "$GEMINI_TARGET" --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $GEMINI_TARGET/.agents/skills"
assert_contains "$output" "dry-run install $ROOT/commands/update-codemaps.md → $GEMINI_TARGET/.gemini/commands/update-codemaps.toml"
assert_not_contains "$output" "$GEMINI_TARGET/.gemini/skills"

output="$(
  cd "$RUN_CWD"
  "$ROOT/setup.sh" codex uninstall skills --project frontend-patterns --target "$TARGET" --dry-run
)"

assert_contains "$output" "dry-run uninstall"
assert_file "$TARGET/.agents/skills/frontend-patterns/SKILL.md"

# Retired pruning during bulk reinstall: removes retired repo items, preserves unrelated ones.
mkdir -p \
  "$ALL_HOME/.agents/skills/bro" \
  "$ALL_HOME/.agents/skills/custom-third-party" \
  "$ALL_HOME/.claude/skills/verification-harness" \
  "$ALL_HOME/.claude/skills/custom-third-party" \
  "$ALL_HOME/.gemini/config/skills/bro" \
  "$ALL_HOME/.gemini/config/skills/custom-third-party" \
  "$ALL_TARGET/.agents/skills/pure-function-pattern" \
  "$ALL_TARGET/.agents/skills/custom-project-skill" \
  "$ALL_TARGET/.claude/skills/frontend-robust-data-handling" \
  "$ALL_TARGET/.claude/skills/custom-project-skill"
touch \
  "$ALL_HOME/.codex/prompts/debug-triage.md" \
  "$ALL_HOME/.codex/prompts/custom-command.md" \
  "$ALL_HOME/.claude/commands/mock-or-not.md" \
  "$ALL_HOME/.claude/commands/custom-command.md" \
  "$ALL_HOME/.gemini/commands/debug-triage.toml" \
  "$ALL_HOME/.gemini/commands/custom-command.toml" \
  "$ALL_TARGET/.codex/prompts/ddd-fit-check.md" \
  "$ALL_TARGET/.codex/prompts/custom-command.md" \
  "$ALL_TARGET/.claude/commands/design-pattern-fit.md" \
  "$ALL_TARGET/.claude/commands/custom-command.md" \
  "$ALL_TARGET/.gemini/commands/mock-or-not.toml" \
  "$ALL_TARGET/.gemini/commands/custom-command.toml"

# Single-item reinstall must NOT prune unrelated retired items.
HOME="$ALL_HOME" "$ROOT/setup.sh" codex reinstall skills --project frontend-patterns --target "$ALL_TARGET" >/dev/null
[[ -d "$ALL_TARGET/.agents/skills/pure-function-pattern" ]] || fail "single-item reinstall should not prune other retired skills"

# Dry-run bulk reinstall previews removal without deleting.
output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --global --dry-run)"
assert_contains "$output" "dry-run remove retired $ALL_HOME/.agents/skills/bro"
assert_contains "$output" "dry-run remove retired $ALL_HOME/.gemini/commands/debug-triage.toml"
[[ -d "$ALL_HOME/.agents/skills/bro" ]] || fail "dry-run should not remove retired skill"
assert_file "$ALL_HOME/.gemini/commands/debug-triage.toml"

# Actual bulk reinstall removes retired items and keeps custom third-party ones.
HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --global >/dev/null
HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --project --target "$ALL_TARGET" >/dev/null

assert_not_exists "$ALL_HOME/.agents/skills/bro"
assert_not_exists "$ALL_HOME/.claude/skills/verification-harness"
assert_not_exists "$ALL_HOME/.gemini/config/skills/bro"
assert_file "$ALL_HOME/.codex/prompts/bro.md"
assert_file "$ALL_HOME/.claude/commands/bro.md"
assert_file "$ALL_HOME/.gemini/commands/bro.toml"
assert_file "$ALL_HOME/.codex/prompts/in-your-own-words.md"
assert_file "$ALL_HOME/.claude/commands/in-your-own-words.md"
assert_file "$ALL_HOME/.gemini/commands/in-your-own-words.toml"
assert_not_exists "$ALL_HOME/.codex/prompts/debug-triage.md"
assert_not_exists "$ALL_HOME/.claude/commands/mock-or-not.md"
assert_not_exists "$ALL_HOME/.gemini/commands/debug-triage.toml"
assert_not_exists "$ALL_TARGET/.agents/skills/pure-function-pattern"
assert_not_exists "$ALL_TARGET/.claude/skills/frontend-robust-data-handling"
assert_not_exists "$ALL_TARGET/.codex/prompts/ddd-fit-check.md"
assert_not_exists "$ALL_TARGET/.claude/commands/design-pattern-fit.md"
assert_not_exists "$ALL_TARGET/.gemini/commands/mock-or-not.toml"

[[ -d "$ALL_HOME/.agents/skills/custom-third-party" ]] || fail "reinstall should preserve custom global codex skill"
[[ -d "$ALL_HOME/.claude/skills/custom-third-party" ]] || fail "reinstall should preserve custom global claude skill"
[[ -d "$ALL_HOME/.gemini/config/skills/custom-third-party" ]] || fail "reinstall should preserve custom global gemini skill"
[[ -d "$ALL_TARGET/.agents/skills/custom-project-skill" ]] || fail "reinstall should preserve custom project codex skill"
[[ -d "$ALL_TARGET/.claude/skills/custom-project-skill" ]] || fail "reinstall should preserve custom project claude skill"
assert_file "$ALL_HOME/.codex/prompts/custom-command.md"
assert_file "$ALL_HOME/.claude/commands/custom-command.md"
assert_file "$ALL_HOME/.gemini/commands/custom-command.toml"
assert_file "$ALL_TARGET/.codex/prompts/custom-command.md"
assert_file "$ALL_TARGET/.claude/commands/custom-command.md"
assert_file "$ALL_TARGET/.gemini/commands/custom-command.toml"

echo "setup smoke checks passed"
