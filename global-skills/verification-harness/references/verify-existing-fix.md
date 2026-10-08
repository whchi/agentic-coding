# Verify an existing fix

Use this procedure when an open PR or a merged commit can fix a reported problem. The existing artifact owns the fix. Verify it. Do not edit it, write a competing change, or open a different PR.

## Qualify the artifact

Require one concrete artifact:

- An open PR with code changes for the symptom.
- A merged PR.
- A merged commit with matching code and intent.

A claim in a thread, a tracker status, a branch name, or a cause hypothesis is not sufficient. When more than one artifact exists, use the artifact that the report or tracker links. Otherwise, use the closest match to the affected code, and say why.

## Protect the working tree

Use an isolated worktree or a different clean checkout. Do not overwrite user changes. Ask the user before you create a worktree if the project rules require approval.

Record these items:

- The baseline revision.
- The patched revision.
- The PR or commit URL.
- The build and environment inputs that both runs share.

## Measure the baseline

For an open PR, use its base branch as the baseline. For a merged fix, use the revision before the fix, if that revision builds and shows the old behavior.

1. Launch the baseline app with `verify-<app>`.
2. Run Doctor.
3. Run the reported path through real user actions.
4. Observe the symptom that separates the broken state from the correct state.
5. Reset the state, and do the path again.
6. Capture the baseline evidence and a state check.

If the symptom does not occur two times on the baseline, you have no baseline. Do not say that the fix works.

## Measure the patched build

Build and run the PR or the fix commit with the same environment and data.

1. Run the same path.
2. Do the path two times.
3. Confirm that the broken state does not occur.
4. Confirm that the expected state occurs.
5. Capture the evidence and the same state check.

A compile, a unit test, or a code review is not evidence. The result must come from the running patched app.

## Outcomes

- **Confirmed:** the baseline shows the symptom two times, and the patched build shows the expected state two times. Report the artifact and the before-and-after evidence.
- **Insufficient fix:** the symptom occurs on both builds. Report the artifact, and say that it does not remove the symptom. Do not write a competing change.
- **Inconclusive:** the baseline does not show the symptom, the patched app cannot run, or the evidence does not show the separating state. Do not report success. Say which half you could not measure.

## Cleanup

Stop both builds. Remove temporary profiles and scratch state. Keep the evidence. Return the repository to its prior state, and do not discard user work.
