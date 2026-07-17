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
