#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentic-coding-setup.XXXXXX")"
RUN_CWD="$TMP_ROOT/run-cwd"
TARGET="$TMP_ROOT/target-project"
AGY_TARGET="$TMP_ROOT/agy-target-project"
ALL_TARGET="$TMP_ROOT/all-target-project"
ALL_HOME="$TMP_ROOT/all-home"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

mkdir -p "$RUN_CWD" "$TARGET" "$AGY_TARGET" "$ALL_TARGET" "$ALL_HOME"
TARGET="$(cd "$TARGET" && pwd)"
AGY_TARGET="$(cd "$AGY_TARGET" && pwd)"
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

AGY_HOME="$TMP_ROOT/agy-home"
output="$(
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy install all --global --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $AGY_HOME/.gemini/config/skills"
assert_contains "$output" "dry-run install $ROOT/commands/update-codemaps.md → $AGY_HOME/.gemini/config/skills/update-codemaps/SKILL.md"
assert_not_contains "$output" "$AGY_HOME/.gemini/antigravity-cli"

(
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy install commands --global update-codemaps
)

assert_file "$AGY_HOME/.gemini/config/skills/update-codemaps/SKILL.md"
python3 - "$AGY_HOME/.gemini/config/skills/update-codemaps/SKILL.md" "$ROOT/commands/update-codemaps.md" <<'PY'
from pathlib import Path
import sys

skill_text = Path(sys.argv[1]).read_text()
source = Path(sys.argv[2]).read_text()
parts = skill_text.split("---", 2)
assert len(parts) == 3, "expected YAML frontmatter"
frontmatter = parts[1].strip().splitlines()
assert "name: update-codemaps" in frontmatter
assert source.splitlines()[1] in frontmatter
assert "disable-model-invocation: true" in frontmatter
assert parts[2].strip() == source.split("---", 2)[2].strip()
PY

output="$(
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy install commands --global update-codemaps
)"
assert_contains "$output" "already consistent: $AGY_HOME/.gemini/config/skills/update-codemaps"

(
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy reinstall commands --global update-codemaps
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy uninstall commands --global update-codemaps
)

assert_not_exists "$AGY_HOME/.gemini/config/skills/update-codemaps"

for provider in opencode pi gemini; do
  for action in install reinstall uninstall; do
    if output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" "$provider" "$action" all --global 2>&1)"; then
      fail "$provider should be disabled for $action"
    fi
    assert_contains "$output" 'codex|claude|agy|all'
  done
done
assert_not_exists "$ALL_HOME/.config/opencode"
assert_not_exists "$ALL_HOME/.pi"
assert_not_exists "$ALL_HOME/.agents"

output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all install all --global)"
for provider in codex claude agy; do
  assert_contains "$output" "=== $provider ==="
done
assert_not_contains "$output" '=== opencode ==='
assert_not_contains "$output" '=== pi ==='
assert_file "$ALL_HOME/.agents/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.claude/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.gemini/config/skills/api-design/SKILL.md"
assert_file "$ALL_HOME/.codex/prompts/update-codemaps.md"
assert_file "$ALL_HOME/.claude/commands/update-codemaps.md"
assert_file "$ALL_HOME/.gemini/config/skills/update-codemaps/SKILL.md"
assert_not_exists "$ALL_HOME/.config/opencode"
assert_not_exists "$ALL_HOME/.pi"

output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all install all --project --target "$ALL_TARGET")"
for provider in codex claude agy; do
  assert_contains "$output" "=== $provider ==="
done
assert_not_contains "$output" '=== opencode ==='
assert_not_contains "$output" '=== pi ==='
assert_file "$ALL_TARGET/.agents/skills/frontend-patterns/SKILL.md"
assert_file "$ALL_TARGET/.claude/skills/frontend-patterns/SKILL.md"
assert_file "$ALL_TARGET/.codex/prompts/update-codemaps.md"
assert_file "$ALL_TARGET/.claude/commands/update-codemaps.md"
assert_file "$ALL_TARGET/.agents/skills/update-codemaps/SKILL.md"
assert_not_exists "$ALL_TARGET/.opencode"
assert_not_exists "$ALL_TARGET/.pi"

output="$(
  HOME="$AGY_HOME" \
    "$ROOT/setup.sh" agy install all --project --target "$AGY_TARGET" --dry-run
)"

assert_contains "$output" "dry-run mkdir -p $AGY_TARGET/.agents/skills"
assert_contains "$output" "dry-run install $ROOT/commands/update-codemaps.md → $AGY_TARGET/.agents/skills/update-codemaps/SKILL.md"
assert_not_contains "$output" "$AGY_TARGET/.gemini/skills"

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
  "$ALL_HOME/.gemini/config/skills/verification-harness" \
  "$ALL_HOME/.gemini/config/skills/debug-triage" \
  "$ALL_HOME/.gemini/config/skills/custom-third-party" \
  "$ALL_TARGET/.agents/skills/pure-function-pattern" \
  "$ALL_TARGET/.agents/skills/mock-or-not" \
  "$ALL_TARGET/.agents/skills/custom-project-skill" \
  "$ALL_TARGET/.claude/skills/frontend-robust-data-handling" \
  "$ALL_TARGET/.claude/skills/custom-project-skill"
touch \
  "$ALL_HOME/.codex/prompts/debug-triage.md" \
  "$ALL_HOME/.codex/prompts/custom-command.md" \
  "$ALL_HOME/.claude/commands/mock-or-not.md" \
  "$ALL_HOME/.claude/commands/custom-command.md" \
  "$ALL_TARGET/.codex/prompts/ddd-fit-check.md" \
  "$ALL_TARGET/.codex/prompts/custom-command.md" \
  "$ALL_TARGET/.claude/commands/design-pattern-fit.md" \
  "$ALL_TARGET/.claude/commands/custom-command.md"

# Single-item reinstall must NOT prune unrelated retired items.
HOME="$ALL_HOME" "$ROOT/setup.sh" codex reinstall skills --project frontend-patterns --target "$ALL_TARGET" >/dev/null
[[ -d "$ALL_TARGET/.agents/skills/pure-function-pattern" ]] || fail "single-item reinstall should not prune other retired skills"

# Dry-run bulk reinstall previews removal without deleting.
output="$(HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --global --dry-run)"
assert_contains "$output" "dry-run remove retired $ALL_HOME/.agents/skills/bro"
assert_contains "$output" "dry-run remove retired $ALL_HOME/.gemini/config/skills/debug-triage"
[[ -d "$ALL_HOME/.agents/skills/bro" ]] || fail "dry-run should not remove retired skill"
[[ -d "$ALL_HOME/.gemini/config/skills/debug-triage" ]] || fail "dry-run should not remove retired agy command"

# Actual bulk reinstall removes retired items and keeps custom third-party ones.
HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --global >/dev/null
HOME="$ALL_HOME" "$ROOT/setup.sh" all reinstall all --project --target "$ALL_TARGET" >/dev/null

assert_not_exists "$ALL_HOME/.agents/skills/bro"
assert_not_exists "$ALL_HOME/.claude/skills/verification-harness"
assert_not_exists "$ALL_HOME/.gemini/config/skills/verification-harness"
assert_file "$ALL_HOME/.codex/prompts/bro.md"
assert_file "$ALL_HOME/.claude/commands/bro.md"
assert_file "$ALL_HOME/.gemini/config/skills/bro/SKILL.md"
assert_file "$ALL_HOME/.codex/prompts/in-your-own-words.md"
assert_file "$ALL_HOME/.claude/commands/in-your-own-words.md"
assert_file "$ALL_HOME/.gemini/config/skills/in-your-own-words/SKILL.md"
assert_not_exists "$ALL_HOME/.codex/prompts/debug-triage.md"
assert_not_exists "$ALL_HOME/.claude/commands/mock-or-not.md"
assert_not_exists "$ALL_HOME/.gemini/config/skills/debug-triage"
assert_not_exists "$ALL_TARGET/.agents/skills/pure-function-pattern"
assert_not_exists "$ALL_TARGET/.claude/skills/frontend-robust-data-handling"
assert_not_exists "$ALL_TARGET/.codex/prompts/ddd-fit-check.md"
assert_not_exists "$ALL_TARGET/.claude/commands/design-pattern-fit.md"
assert_not_exists "$ALL_TARGET/.agents/skills/mock-or-not"

# Reinstalling agy skills alone must not delete installed agy commands (e.g. bro).
HOME="$ALL_HOME" "$ROOT/setup.sh" agy reinstall skills --global >/dev/null
assert_file "$ALL_HOME/.gemini/config/skills/bro/SKILL.md"
assert_file "$ALL_HOME/.gemini/config/skills/in-your-own-words/SKILL.md"

[[ -d "$ALL_HOME/.agents/skills/custom-third-party" ]] || fail "reinstall should preserve custom global codex skill"
[[ -d "$ALL_HOME/.claude/skills/custom-third-party" ]] || fail "reinstall should preserve custom global claude skill"
[[ -d "$ALL_HOME/.gemini/config/skills/custom-third-party" ]] || fail "reinstall should preserve custom global agy skill"
[[ -d "$ALL_TARGET/.agents/skills/custom-project-skill" ]] || fail "reinstall should preserve custom project codex skill"
[[ -d "$ALL_TARGET/.claude/skills/custom-project-skill" ]] || fail "reinstall should preserve custom project claude skill"
assert_file "$ALL_HOME/.codex/prompts/custom-command.md"
assert_file "$ALL_HOME/.claude/commands/custom-command.md"
assert_file "$ALL_TARGET/.codex/prompts/custom-command.md"
assert_file "$ALL_TARGET/.claude/commands/custom-command.md"

echo "setup smoke checks passed"
