---
name: verification-harness
description: Use when the user asks to create or refresh a maintained, scripted way to launch and drive the real app the way a user does. Mode `create` generates a project-local `verify-<app>` skill with a feature map. Mode `refresh` corrects an existing `verify-<app>` skill after the app changes. Do NOT use to run acceptance tests for a change (`qa` command), to diagnose a bug (`debugging-playbook`), or to select test levels and mocks (`testing-strategy`).
origin: backnotprop/pstack@3a60467 (MIT)
---

# Verification Harness

This skill has two modes. Mode `create` generates a project-local `verify-<app>` skill and proves it one time. Mode `refresh` keeps an existing `verify-<app>` skill and its feature map correct. Say which mode you use before you start.

The `qa` command uses `verify-<app>` when it exists. Then `qa` uses its Launch, Doctor, Drive, Evidence, and Cleanup sections for the real-app part of the acceptance test.

## Terms

- **Target app:** the application that a user touches, such as a web UI, a CLI, a TUI, a desktop app, or an API.
- **`verify-<app>` skill:** the generated project-local skill that launches, checks, drives, and stops the target app.
- **Feature map:** the `features/` folder in the `verify-<app>` skill. It has one file for each user-facing feature.
- **Generated assets:** the `verify-<app>` SKILL.md and its helper scripts. A refresh can rewrite them.
- **User configuration:** the values that the user owns, such as URLs, ports, accounts, and secret names.
- **Evidence:** the screenshots, transcripts, response bodies, logs, and state checks that prove a behavior.

## Skill location

Put `verify-<app>/` in the project skills folder of the provider: `.claude/skills/`, `.agents/skills/`, or `.opencode/skills/`. Use the folder that the repo already uses. If the repo uses more than one folder, ask the user which folder to use. If the repo uses no folder, ask the user before you create one.

## Rules for both modes

1. **Ask before you change the base.** The checkout can fail to build or start. Then report the exact failure. Fix it only after the user approves.
2. **Do not install tools without approval.** This rule includes browsers, drivers, PTY tools, and packages.
3. **Fail closed.** A prerequisite can be missing, such as a launch command, a credential, a tool, or a feature-map entry. Then stop and report the missing prerequisite. Do not invent a path, a selector, or a command.
4. **Keep user configuration separate.** Put user configuration in its own file, apart from the generated assets. Do not let a refresh overwrite that file. If a change is necessary, show the diff and ask the user.
5. **Keep secrets out of the repo.** Refer to a secret by its environment variable name. Do not write secret values to files, logs, or evidence.
6. **Isolate credentials for each worker.** Give each worker its own account, browser profile, data directory, and port. Do not let two workers share a session or a token. Give read-only workers no write credentials.
7. **Put durable conclusions in the repo.** Write prerequisites, gotchas, and corrected recipes in the feature map. Do not keep them only in uncommitted notes.
8. **Do not commit, push, or open a PR unless the user asks.** Report the changed files instead.
9. **Stop only what you started.** Do not stop a process by its name. Do not drive an instance that this run did not start or check.

## Mode `create`

Read `references/create.md` for the full procedure and the section contract.

1. Get facts from the repo first. Ask the user only for facts that you cannot observe.
2. Find the surface, the run command, the drive method, the evidence types, and the isolation limits.
3. Prefer the harness that the repo already has, such as Playwright specs, expect scripts, or HTTP scripts.
4. Write `verify-<app>/SKILL.md` with frontmatter (`name`, `description`) and these sections: Launch, Doctor, Drive, Evidence, Cleanup, and Helpers.
5. Write the user configuration file and its secret-free example.
6. Write `verify-<app>/features/README.md` and one file for each of the top 3 to 5 user-facing features. Use the shape in `references/feature-map-example/`.
7. Prove the generated skill one time: launch, doctor, drive one mapped feature, capture evidence, and clean up.
8. After the cleanup, confirm that the evidence is still at its named location.
9. If a step fails, run the generated cleanup, correct the skill, and run the proof again.

A generated skill that you did not run is a draft. Do not report it as complete.

## Mode `refresh`

Read `references/refresh.md` for the full pass, the live-pass invariants, and the triage rules.

Select one scope before you start:

| Scope | Features to drive | Where it is allowed |
|---|---|---|
| `scoped` | Only the features that the current change touches | A development worktree, or the integration target |
| `full` | All features in the feature map | The integration target, after all planned serial merges are complete |

- For `scoped`, find the touched features from the diff of the current change. Write the list of feature files before you drive the app.
- If no feature file covers a touched user-facing surface, add a feature file for it.
- Do not run `full` in a development worktree. Report `full` as pending integration instead.
- Do not make temporary branch combinations or trial merges to run a refresh.

Edit only the files in the `verify-<app>/` folder. Do not edit product code during a refresh. When the app does not do what the map says, decide which case applies:

- **Doc drift:** the map is incorrect. Correct the map.
- **Harness gap:** the behavior works, but the harness cannot drive it. Correct the harness.
- **Product gap:** the app is broken. Report it to the user. Do not change the map to hide it.

Give one outcome: `clean`, `changed`, or `blocked`. For `blocked`, name the exact cause.

## Re-verify before you report "fixed"

A fix can exist already, such as a merged commit or an open PR. Do not report the problem as fixed from the commit message or a test result. Drive the real path on the current build two times and observe the expected state. To compare a baseline with a fix, use `references/verify-existing-fix.md`.

## Report

- The mode and, for `refresh`, the scope.
- The features that you drove, and the evidence location for each feature.
- The features that you could not reach, with the missing prerequisite and the attempted route.
- The doc drift and harness gaps that you corrected, with the changed files.
- The product gaps, with the steps, the expected state, and the observed state.
- The outcome, and the checks that you did not run. Mark `full` as pending integration until it runs after the merges.
