# Agent Rules and Enforcement

This table pairs each repeated agent mistake with the mechanism that stops it. The `correct` skill maintains this file. Add a rule when the same mistake occurs two times. Fix the rule at the highest level that works. Write a Docs rule only when a mechanism cannot enforce it.

Levels, from strongest to weakest: Architecture, Types, Lint, CI, Test, Docs.

| Rule | Origin | Level | Enforced by | Status |
|---|---|---|---|---|
| Each skill and command source is listed in the `setup.sh` arrays and in the README tables. | `afc53b4` catalog cleanup | Test | `tests/command-skill-policy.sh` (manifest and README check) | Active |
| Each command starts with frontmatter that has `description:` on line 2, because the Gemini install reads line 2. | `setup.sh:185` | Test | `tests/command-skill-policy.sh` (command frontmatter loop) | Active |
| Removed skills and commands (`frontend-slides`, `write-a-skill`, `learn`, `build-fix`) do not return. | `docs/audits/commands-skills-audit-2026-07-13.md` | Test | `tests/command-skill-policy.sh` (removed-item checks) | Active |
| `debug-triage` and `debugging-playbook` diagnose only. They change code only after an explicit request for a fix. | `afc53b4` | Test | `tests/command-skill-policy.sh` (debug checks) | Active |
| `code-review` keeps its scope, authority, and verification rules. | `f58394c` | Test | `tests/command-skill-policy.sh` (code-review checks) | Active |
| Install paths in `setup.sh`, the README table, and the smoke test agree. | `e022f37` changed paths without the test; fixed 2026-10-08 | Test | `tests/setup-smoke.sh`, `tests/command-skill-policy.sh` (path checks) | Active |
| Eval case counts come from the case files, not from a hardcoded number. | Hardcoded `30` failed after cases grew to `35`; fixed 2026-10-08 | Test | `tests/skill-evals-smoke.sh` | Active |
| A behavior eval grades evidence from the transcript and files, not a claim in the response. | `docs/audits/pstack-fit-2026-10-08.md` | Test | `tests/skill-evals-smoke.sh` (behavior runner checks) | Active |
| A skill description states its capability and concrete trigger concisely; add an exclusion only to distinguish a likely neighboring task. | User-supplied skills and prompting article, 2026-10-08 | Docs | Manual routing review; case definitions in `evals/cases/` | Active |
| A vendored MIT skill (`origin:` ends with `(MIT)`) has a `LICENSE` file. | `docs/audits/emilkowalski-skills-fit-2026-10-06.md`, `docs/audits/pstack-fit-2026-10-08.md` | Test | `tests/command-skill-policy.sh` (LICENSE loop) | Active |
| Destructive operations need a target list and explicit approval in the current conversation. | `AGENTS.md` section 8 | Docs | none | Active |
