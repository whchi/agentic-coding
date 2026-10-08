#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/agentic-coding-skill-evals.XXXXXX")"
RESULTS_DIR="$TMP_ROOT/results"

cleanup() {
  rm -rf "$TMP_ROOT"
}

trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

output="$(
  python3 "$ROOT/scripts/run-skill-evals.py" \
    --cases "$ROOT/tests/fixtures/skill-evals/cases.json" \
    --validate-only
)"
assert_contains "$output" "Validated 2 cases from 1 suite."

output="$(
  python3 "$ROOT/scripts/run-skill-evals.py" \
    --cases "$ROOT/tests/fixtures/skill-evals/cases.json" \
    --adapter "$ROOT/tests/fixtures/skill-evals/fake-adapter.py" \
    --runs 2 \
    --output-dir "$RESULTS_DIR"
)"
assert_contains "$output" "4/4 runs passed (2/2 cases)."

result_count="$(find "$RESULTS_DIR" -maxdepth 1 -type f -name '*.json' | wc -l | tr -d ' ')"
[[ "$result_count" -eq 1 ]] || fail "expected exactly one result file"
result_file="$(find "$RESULTS_DIR" -maxdepth 1 -type f -name '*.json' -print)"

python3 - "$result_file" <<'PY'
import json
from pathlib import Path
import sys

result = json.loads(Path(sys.argv[1]).read_text())
assert result["summary"] == {
    "cases": 2,
    "passed_cases": 2,
    "runs": 4,
    "passed_runs": 4,
}
assert len({run["response"] for run in result["runs"]}) == 4
assert all(run["passed"] for run in result["runs"])
PY

TIMEOUT_RESULTS_DIR="$TMP_ROOT/timeout-results"
CHILD_MARKER="$TMP_ROOT/orphaned-child"
set +e
output="$(
  SKILL_EVAL_TEST_CHILD_MARKER="$CHILD_MARKER" \
    python3 "$ROOT/scripts/run-skill-evals.py" \
    --cases "$ROOT/tests/fixtures/skill-evals/timeout-cases.json" \
    --adapter "$ROOT/tests/fixtures/skill-evals/fake-adapter.py" \
    --runs 1 \
    --timeout-seconds 1 \
    --output-dir "$TIMEOUT_RESULTS_DIR" \
    2>&1
)"
status=$?
set -e
[[ "$status" -eq 1 ]] || fail "expected a failed eval when the adapter times out"
assert_contains "$output" "0/1 runs passed (0/1 cases)."

timeout_result_file="$(find "$TIMEOUT_RESULTS_DIR" -maxdepth 1 -type f -name '*.json' -print)"
python3 - "$timeout_result_file" <<'PY'
import json
from pathlib import Path
import sys

result = json.loads(Path(sys.argv[1]).read_text())
run = result["runs"][0]
assert run["adapter_error"] == "adapter timed out after 1 seconds"
assert run["adapter_stdout"] == "partial output"
PY

sleep 2
[[ ! -e "$CHILD_MARKER" ]] || fail "expected timed-out adapter children to be terminated"

output="$(
  python3 "$ROOT/scripts/run-skill-evals.py" \
    --cases "$ROOT/evals/cases" \
    --validate-only
)"
expected_counts="$(python3 - "$ROOT/evals/cases" <<'PY'
import json
from pathlib import Path
import sys

suites = [json.loads(path.read_text()) for path in sorted(Path(sys.argv[1]).glob("*.json"))]
print(f"Validated {sum(len(suite['cases']) for suite in suites)} cases from {len(suites)} suites.")
PY
)"
assert_contains "$output" "$expected_counts"

BEHAVIOR_FIXTURES="$ROOT/tests/fixtures/behavior-evals"
BEHAVIOR_RESULTS_DIR="$TMP_ROOT/behavior-results"
output="$(
  python3 "$ROOT/scripts/run-behavior-evals.py" \
    --cases "$BEHAVIOR_FIXTURES/cases.json" \
    --adapter "$BEHAVIOR_FIXTURES/fake-adapter.py" \
    --judge "$BEHAVIOR_FIXTURES/fake-judge.py" \
    --runs 2 \
    --seed 7 \
    --output-dir "$BEHAVIOR_RESULTS_DIR"
)"
assert_contains "$output" "with: 2/2 runs passed all checks."
assert_contains "$output" "without: 0/2 runs passed all checks."
assert_contains "$output" "judge: with 2, without 0, tie 0, errors 0."

behavior_result_file="$(find "$BEHAVIOR_RESULTS_DIR" -maxdepth 1 -type f -name 'behavior-*.json' -print)"
python3 - "$behavior_result_file" <<'PY'
import json
from pathlib import Path
import sys

result = json.loads(Path(sys.argv[1]).read_text())
for run in result["runs"]:
    assert run["response"] == "Root cause confirmed by repro.", run
    expected = {"ran-repro": True, "no-guess": True, "report-written": True}
    if run["arm"] == "without":
        expected = {"ran-repro": False, "no-guess": True, "report-written": False}
    assert run["checks"] == expected, run
for verdict in result["verdicts"]:
    assert verdict["preferred"] == "with", verdict
    assert verdict["criteria"] == {"with": [True], "without": [False]}, verdict
PY

python3 "$ROOT/scripts/run-behavior-evals.py" --cases "$ROOT/evals/behavior" --validate-only >/dev/null \
  || fail "expected versioned behavior cases to validate"

BAD_CASES="$TMP_ROOT/bad-behavior.json"
python3 - "$BEHAVIOR_FIXTURES/cases.json" "$BAD_CASES" <<'PY'
import json
import sys

document = json.load(open(sys.argv[1]))
document["cases"][0]["skills_under_test"] = ["no-such-skill"]
json.dump(document, open(sys.argv[2], "w"))
PY
set +e
output="$(python3 "$ROOT/scripts/run-behavior-evals.py" --cases "$BAD_CASES" --validate-only 2>&1)"
status=$?
set -e
[[ "$status" -eq 2 ]] || fail "expected unknown skills_under_test to fail validation"
assert_contains "$output" "unknown skills_under_test"

git -C "$ROOT" check-ignore -q evals/results/example.json || fail "expected eval results to be ignored"
if git -C "$ROOT" check-ignore -q evals/results/.gitkeep; then
  fail "expected eval results .gitkeep to remain trackable"
fi
[[ -f "$ROOT/evals/results/.gitkeep" ]] || fail "expected evals/results/.gitkeep"
for source in \
  evals/README.md \
  evals/cases/routing-boundaries.json \
  evals/cases/super-google-search.json \
  scripts/run-skill-evals.py \
  scripts/run-behavior-evals.py \
  evals/behavior/pstack-skills.json; do
  if git -C "$ROOT" check-ignore -q "$source"; then
    fail "expected source file to remain trackable: $source"
  fi
done

echo "skill eval smoke checks passed"
