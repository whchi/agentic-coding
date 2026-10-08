# Instruction optimization — 2026-10-08

## Scope and source

The user requested changes to Markdown in `global-skills/`, `project-skills/`, `coding-agent-flow/`, `commands/`, and the three root `AGENTS*.md` files. Installed copies, plugins, `general-skills/`, and the untracked `pstack/` checkout are excluded.

The supplied article and two screenshots guide this revision. Their relevant principles are: describe concrete skill triggers concisely; load task-specific references only when needed; prefer outcomes and essential constraints over fixed itineraries; use proportional verification; continue already-authorized work through completion. The article's model capability claims are background, not independently verified facts or a requirement to change models.

Success means useful domain guidance and authorization boundaries remain intact while discovery, context loading, and completion behavior become more precise. Shorter text alone is not sufficient evidence of improvement.

## Decisions

- Review all Markdown in scope, including supporting references. Retain concise technical references when they already serve a distinct task.
- Keep commands self-contained because installation copies or converts each command independently.
- Preserve explicit-only invocation policies, licensing, domain contracts, destructive-action authorization, and serial worktree integration with scoped local checks.
- Replace the old mandatory description formula in `docs/agents/rules.md` with a capability and trigger rule; exclusions are useful only for likely routing ambiguity.
- Remove unconditional Jev routing, arbitrary long-running thresholds, append-only activity logs, and repeated generic guidance from AGENTS files. Link optional guidance by task.

## Completed changes

| Scope | Markdown reviewed | Markdown changed |
| --- | ---: | ---: |
| `global-skills/` | 44 | 38 |
| `project-skills/` | 22 | 17 |
| `coding-agent-flow/` | 7 | 7 |
| `commands/` | 9 | 9 |
| Root `AGENTS*.md` | 3 | 3 |
| Total | 85 | 74 |

All 32 skill entrypoints and all 9 commands were updated. No files were deleted: redundant instructions were removed within files, and useful references were retained. Names, non-description skill metadata, and license files were preserved.

- API, PRD, harness, and reflect guidance routes to existing references by task. Specialized domain examples remain available.
- TDD no longer requires deleting an existing implementation or running full suites in a development worktree. Debugging uses an evidence loop and continues a fix already authorized by the user.
- Review and architecture skills no longer require unrelated documents, arbitrary finding counts, or automatic chains of other skills.
- Frontend guidance preserves reactive lifecycle, reset, data-state, and accessibility semantics instead of prescribing one pattern universally.
- Requirement breakdown can proceed through supported deliverables without six intermediate approvals. Jira still requires concrete write authorization, immediate key checkpoints, and reconciliation after uncertain creates.
- Feature-loop retains its explicit stages and bounded verification policy; those limits are part of its selected workflow.
- Commands retain their single-file installation contract and distinguish diagnosis/review from authorized edits.

Two existing test files needed related maintenance: remove assertions for obsolete process wording, retain actual purity and authorization contracts, enforce command description placement, and compare installed command content with its source instead of a hardcoded old description. No installer or eval-runner implementation changed.

## Verification

Changes were developed with scoped checks in disjoint worktrees and merged serially into `main`. After integration and the final repairs, these checks passed:

- `bash tests/command-skill-policy.sh`
- `bash tests/setup-smoke.sh` (isolated temporary installation targets)
- `bash tests/skill-evals-smoke.sh`
- `python3 scripts/run-skill-evals.py --cases evals/cases --validate-only` (46 cases)
- `python3 scripts/run-behavior-evals.py --cases evals/behavior --validate-only` (2 cases)
- `git diff b00d810 --check`
- Ruby YAML parsing of all 32 skill frontmatters, name/description constraints, and comparison of preserved metadata against `b00d810`.
- Code-fence and literal local-link checks across all 85 scoped Markdown files; 50 actual local references resolved. Paths inside illustrative code blocks were treated as examples.

The first integration pass exposed a stale installation-test description and angle brackets in one skill description. Both were corrected and the affected checks rerun successfully.

The bundled `quick_validate.py` could not run because system Python lacks PyYAML; its allowed-field list also excludes this repository's preserved `origin` metadata. Ruby YAML parsing and repository checks were used instead. No dependencies were installed.

Live model routing or behavior trials were not run. Eval smoke tests use fixture adapters; case validation checks definitions only. These results establish structural and packaging compatibility, not measured improvements in model decisions. No application feature/e2e suite was applicable to these instruction-only changes. Global installations and excluded directories were not changed.
