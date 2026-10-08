# Mode `refresh`: full pass

A feature map becomes incorrect when the app changes. A refresh makes the `verify-<app>` skill and its feature map correct again. The unit of the refresh is the feature, not each sentence. Read each feature in scope from source, and drive each feature in scope live.

## Scope

| Scope | Features in scope | Where it is allowed |
|---|---|---|
| `scoped` | Only the features that the current change touches | A development worktree, or the integration target |
| `full` | All features in the feature map | The integration target, after all planned serial merges are complete |

- For `scoped`, read the diff of the current change against its base branch.
- Map each changed user-facing surface to a feature file. Write this list before you drive the app.
- A changed surface can have no feature file. Then add a feature file for it, and include it in scope.
- Do not drive features outside the list in a `scoped` refresh.
- Do not run `full` in a development worktree. Report it as pending integration.
- Do not make temporary branch combinations, trial merges, or cross-worktree test matrices.

## Edit scope

Edit only the files in the `verify-<app>/` folder: its `SKILL.md`, `features/`, and its helper scripts. Do not edit product code. Do not overwrite the user configuration file. If the requested work already authorizes a configuration change, make only that change; otherwise show the proposed diff and obtain authorization.

## Pass

0. **Find the target.** Find the `verify-<app>/` folder in the project skills folder. If more than one exists, select the one matching the requested app; ask only if the target remains ambiguous. If you find none, stop and suggest mode `create`.
1. **Check the index.** Read `features/README.md` and list the files next to it. Correct missing, extra, duplicate, or dead entries. In `scoped`, check only the entries in scope.
2. **Read the source.** For each feature in scope, explain from source how the feature works for a user. Note probable drift, with file citations. Write one live recipe for the feature. For substantial independent source reviews, authorized read-only subagents may help. Keep app driving and edits with one owner to avoid shared-state races.
3. **Reconcile.** Confirm that each feature in scope has a summary. Combine recipes that use the same app state. Check the cited drift. Do not prove clean claims again. In `full`, search recent changes for user-facing surfaces that the map does not have. Give a source path before you call a surface missing.
4. **Drive live.** Do this step even when the source looks correct. One agent does all the driving. Use the launch model in the Launch section of `verify-<app>`. Drive each feature in scope at least one time. Keep the three invariants in the section that follows.
5. **Triage.** Put each problem in one category. See the triage section.
6. **Finish.** For `changed`, check the final diff and relevant links. Report the changed files. Do not commit or open a PR unless the user asks. For `clean` or `blocked`, report the outcome and the coverage.

## Live-pass invariants

Keep these three invariants for the full pass, also when a drive fails:

1. **Check before you drive.** Run Doctor before the first drive. Run Doctor on each new session when sessions are the unit. Run Doctor again after a failed drive. Doctor cannot see some failures, such as a UI that is stuck on a healthy process. Then reset to a known state, or launch again.
2. **Keep the evidence.** The evidence must stay after each Cleanup. Check it at its named location.
3. **Clean up owned state.** Stop processes this run started and clean disposable state under repository rules. Do not drive or stop a shared instance merely to complete cleanup; preserve evidence.

A Doctor failure can come from skill drift. Then correct the skill in the edit scope, and try one more time. Restart only the parts that the correction made invalid. If it fails again, report `blocked`.

A feature is `verified-unreachable` only when you give the exact prerequisite and the route that you tried. Examples of prerequisites are authentication, an entitlement, an operating system, and external state. If the map does not name that prerequisite, the map has drift. Add the prerequisite to the map.

Drive each harness correction live again before you report it. Run the final Cleanup after the last drive, including those repeated drives.

## Triage

- **Doc drift:** the user-facing description is incorrect or missing. Correct the feature map.
- **Harness gap:** the behavior works, but the harness cannot drive it. Correct the harness. Make each new helper executable, and show its command in the skill body.
- **Product gap:** the app behavior is broken. Report it to the user with the steps, the expected state, and the observed state. Do not change the map to hide it. Do not fix product code in a refresh.

## Durable conclusions

Write durable conclusions in the feature map, not in uncommitted notes. Durable conclusions include prerequisites, gotchas, corrected selectors, and corrected recipes. Keep evidence files out of source control. Report the run facts to the user: features covered, unreachable prerequisites, confirmed drift, and the outcome.

## Outcomes

Give one outcome:

- **`clean`:** each feature in scope got source and live coverage. Nothing needs a change.
- **`changed`:** you corrected the map, the skill, or the harness, with live proof.
- **`blocked`:** coverage could not finish, or a correction could not be proved. Name the exact cause.
