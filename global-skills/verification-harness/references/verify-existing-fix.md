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

Declare a sample plan before running, using the [run contract](run-contract.md). For deterministic bugs, two reset runs per side are a useful default. For intermittent bugs, choose repeated trials, trigger conditions, a time limit, and the evidence needed to support the claim. Two clean candidate runs do not establish absence of a rare defect. Keep all attempts; diagnostic retries do not erase failures.

For an open PR, use its base branch as the baseline. For a merged fix, use the revision before the fix, if that revision builds and shows the old behavior.

1. Launch the baseline app with `verify-<app>`.
2. Run Doctor.
3. Run the reported path through real user actions.
4. Observe the symptom that separates the broken state from the correct state.
5. Reset the state between trials and complete the declared baseline sample plan.
6. Capture the baseline evidence and a state check.

If the baseline does not establish the symptom to the declared standard, the comparison is inconclusive. Do not say that the fix works.

## Measure the patched build

Build and run the PR or the fix commit with the same environment and data.

1. Run the same path.
2. Complete the same declared sample plan with reset state between trials.
3. Confirm that the broken state does not occur.
4. Confirm that the expected state occurs.
5. Capture the evidence and the same state check.

A compile, a unit test, or a code review is not evidence. The result must come from the running patched app.

## Outcomes

- **Confirmed:** the baseline establishes the symptom and the patched build meets the expected behavior under the declared sample plan. Report the artifact, trial counts, limitations, and before-and-after evidence; do not claim universal absence from finite trials.
- **Insufficient fix:** the symptom occurs on both builds. Report the artifact, and say that it does not remove the symptom. Do not write a competing change.
- **Inconclusive:** the baseline does not show the symptom, the patched app cannot run, or the evidence does not show the separating state. Do not report success. Say which half you could not measure.

## Cleanup

Stop both builds. Remove temporary profiles and scratch state. Keep the evidence. Return the repository to its prior state, and do not discard user work.
