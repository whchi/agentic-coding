# Skill routing evals

These evals measure whether an agent activates the intended skills for a prompt. They do not run a skill three times inside one user request.

The runner starts a fresh adapter process in a fresh temporary working directory for every trial. It copies only the skill sources into that workspace; cases, expectations, and prior results are not included.

The adapter is a trusted boundary. It receives the isolated bundle path through `SKILL_EVAL_SKILLS_DIR` and must install or expose those skills to a fresh agent invocation without passing repository eval files to the agent.

## Files

- `cases/*.json`: versioned routing cases, including positive and negative triggers.
- `results/`: generated run artifacts. Git ignores everything here except `.gitkeep`.
- `../scripts/run-skill-evals.py`: provider-neutral runner.

## Validate cases

```bash
python3 scripts/run-skill-evals.py --cases evals/cases --validate-only
```

## Run cases

Create an executable adapter for the agent CLI being evaluated, then run:

```bash
python3 scripts/run-skill-evals.py \
  --cases evals/cases \
  --adapter /path/to/adapter \
  --runs 3
```

`--runs` defaults to `3`. Use `3` to `6` for a measured eval; use fewer only while debugging the harness.

The runner sends one JSON object on stdin:

```json
{"prompt": "幫我找貓咪圖片"}
```

The adapter must start a new, non-resumed agent invocation and return one JSON object on stdout:

```json
{
  "activated_skills": ["super-google-search"],
  "response": "Optional final response or trace summary"
}
```

Write adapter diagnostics to stderr. Instrument the provider's skill/tool events when available; do not infer activation from the expected case data.

# Skill behavior evals

Routing evals show that an agent activates a skill. They do not show that the skill improves the result. Behavior evals measure the result.

The behavior runner runs each case in two arms:

- `with`: the full skill bundle.
- `without`: the same bundle without the skills under test.

Each trial uses a fresh adapter process, a fresh temporary workspace, and a fresh copy of the case fixture. The agent receives only the prompt. The checks and the rubric stay outside the workspace.

## Files

- `behavior/*.json`: versioned behavior cases (schema `skill-behavior-eval/v1`).
- `behavior/fixtures/`: project files that a case copies into the workspace.
- `../scripts/run-behavior-evals.py`: provider-neutral behavior runner.

## Write a case

```json
{
  "id": "vet-speedup-claim",
  "prompt": "The new parser is 40% faster. Write it up for the PR.",
  "skills_under_test": ["benchmark-checklist"],
  "fixture": "fixtures/parser-bench",
  "checks": [
    {"id": "ran-repeats", "type": "transcript_matches", "pattern": "bench\\.sh"},
    {"id": "names-limiter", "type": "response_matches", "pattern": "(?i)limit"}
  ],
  "rubric": ["The report gives a run count and a range, not one number."]
}
```

Follow these rules:

1. Write the prompt as a real user writes it. Do not name the skill in the prompt.
2. Grade with deterministic checks first. Use the rubric only for judgment that a check cannot measure.
3. Check evidence, not claims. Use `transcript_matches` or a file check for an action. Do not trust a sentence in the response that says the action occurred.
4. Make each check fail in the `without` arm for a reason that the skill addresses.

Check types:

| Type | Passes when |
|---|---|
| `response_matches` / `response_not_matches` | The final response matches / does not match `pattern`. |
| `transcript_matches` / `transcript_not_matches` | The joined transcript lines match / do not match `pattern`. |
| `file_exists` | `path` exists in the project directory after the run. |
| `file_matches` | `path` exists and its text matches `pattern`. |

Patterns are Python regular expressions with multiline mode.

## Validate cases

```bash
python3 scripts/run-behavior-evals.py --cases evals/behavior --validate-only
```

## Run cases

```bash
python3 scripts/run-behavior-evals.py \
  --cases evals/behavior \
  --adapter /path/to/adapter \
  --judge /path/to/judge \
  --runs 3
```

`--judge` is optional. `--arms with` runs only the `with` arm and cannot use a judge. The exit status is `0` only when every `with` run passes every check. The `without` arm is a baseline for comparison.

The behavior adapter uses the routing adapter contract, with one more required field. The runner starts it in the project directory and sends `{"prompt": "..."}` on stdin. The adapter returns:

```json
{
  "activated_skills": ["benchmark-checklist"],
  "response": "Final response",
  "transcript": ["tool: bash ./bench.sh --runs 5", "result: p50 41 ms -> 33 ms"]
}
```

Build `transcript` from the provider's tool and message events. Do not ask the agent to summarize its own work.

The judge receives the prompt, the rubric, and two anonymous candidates, `A` and `B`, in random order. It returns:

```json
{"preferred": "A", "criteria": {"A": [true], "B": [false]}}
```

`criteria` holds one boolean per rubric item for each candidate. The runner maps `A` and `B` back to the arms after the judge returns. Use `--seed` to repeat the candidate order.
