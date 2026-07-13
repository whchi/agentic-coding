#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_not_exists() {
  [[ ! -e "$1" ]] || fail "expected path not to exist: $1"
}

assert_contains() {
  local file="$1" needle="$2"
  rg -Fq -- "$needle" "$file" || fail "expected $file to contain: $needle"
}

assert_not_contains() {
  local file="$1" needle="$2"
  ! rg -Fq -- "$needle" "$file" || fail "expected $file not to contain: $needle"
}

assert_not_exists "$ROOT/global-skills/frontend-slides"
assert_not_exists "$ROOT/global-skills/write-a-skill"
assert_not_exists "$ROOT/commands/learn.md"
assert_not_exists "$ROOT/commands/build-fix.md"

for needle in frontend-slides write-a-skill; do
  assert_not_contains "$ROOT/README.md" "\`$needle\`"
  assert_not_contains "$ROOT/setup.sh" "  $needle"
done
assert_not_contains "$ROOT/README.md" "\`learn\`"
assert_not_contains "$ROOT/setup.sh" "  learn"
assert_not_contains "$ROOT/README.md" "\`build-fix\`"
assert_not_contains "$ROOT/setup.sh" "  build-fix"

assert_contains "$ROOT/commands/debug-triage.md" "diagnosis only"
assert_not_contains "$ROOT/commands/debug-triage.md" "Fix the smallest confirmed cause"
assert_contains "$ROOT/global-skills/debugging-playbook/SKILL.md" "If the user has explicitly asked for a fix"
assert_not_contains "$ROOT/global-skills/debugging-playbook/SKILL.md" "Fix the confirmed cause"

assert_contains "$ROOT/commands/anthropic-skill-review.md" "existing SKILL.md or command draft"
assert_not_contains "$ROOT/commands/anthropic-skill-review.md" "source notes or an article"
assert_not_contains "$ROOT/commands/anthropic-skill-review.md" "content-to-skill"
assert_contains "$ROOT/commands/content-to-skill.md" "Do not trigger for method analysis alone"
assert_contains "$ROOT/commands/content-to-skill.md" "Draft mode"
assert_contains "$ROOT/commands/content-to-skill.md" "Save-ready mode"

assert_contains "$ROOT/project-skills/pure-function-pattern/SKILL.md" "test-first sequencing"
assert_contains "$ROOT/project-skills/pure-function-pattern/SKILL.md" "test level, mocking, and fixture choices"
assert_not_contains "$ROOT/project-skills/pure-function-pattern/SKILL.md" "No \`vi.mock()\`"
assert_not_contains "$ROOT/project-skills/pure-function-pattern/SKILL.md" "export every helper"

assert_contains "$ROOT/global-skills/planning-with-files/SKILL.md" "long-running, multi-session work"
assert_not_contains "$ROOT/global-skills/planning-with-files/SKILL.md" "5+ tool calls"
assert_contains "$ROOT/global-skills/planning-with-files/SKILL.md" "optional OpenCode plugin"

for file in "$ROOT"/commands/*.md; do
  head -n 1 "$file" | rg -Fq -- '---' || fail "command missing frontmatter: $file"
  rg -q '^description:' "$file" || fail "command missing description: $file"
done

python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys

root = Path(sys.argv[1])
setup_lines = (root / "setup.sh").read_text().splitlines()

def setup_array(name):
    start = setup_lines.index(f"{name}=(") + 1
    values = []
    for line in setup_lines[start:]:
        value = line.strip()
        if value == ")":
            return values
        if value:
            values.append(value)
    raise AssertionError(f"unclosed {name}")

expected = {
    "GLOBAL_SKILLS": sorted(p.parent.name for p in (root / "global-skills").glob("*/SKILL.md")),
    "PROJECT_SKILLS": sorted(p.parent.name for p in (root / "project-skills").glob("*/SKILL.md")),
    "COMMANDS": sorted(p.stem for p in (root / "commands").glob("*.md")),
}
for name, actual in expected.items():
    listed = sorted(set(setup_array(name)))
    assert listed == actual, f"{name}: setup={listed}, source={actual}"

readme_lines = (root / "README.md").read_text().splitlines()
sections = {"### Global Skills": "GLOBAL_SKILLS", "### Project Skills": "PROJECT_SKILLS", "### Commands": "COMMANDS"}
readme = {value: [] for value in sections.values()}
section = None
for line in readme_lines:
    if line in sections:
        section = sections[line]
    elif section and line.startswith("### "):
        section = None
    elif section:
        parts = [part.strip() for part in line.split("|")]
        if len(parts) > 2 and parts[1].startswith("`") and parts[1].endswith("`"):
            readme[section].append(parts[1].strip("`"))
for name, actual in expected.items():
    assert sorted(set(readme[name])) == actual, f"{name}: README={readme[name]}, source={actual}"
print("manifest and README consistency passed")
PY

echo "command and skill policy checks passed"
