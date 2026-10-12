# Specialized Checks

Load only the mode requested or justified by the affected behavior. These modes supplement functional acceptance; they do not authorize product edits, new services, multi-agent work, or shipping.

## Visual parity

Freeze an approved baseline before comparison. Match browser/build, viewport, fonts, device scale, fixture data, and animation state. Declare tolerances and any dynamic-region masks before running, with reasons; never mask the behavior under test. Inspect differences and retain baseline, actual, and diff artifacts. Do not update the baseline to silence a failure. Legitimate visual changes require an explicit baseline decision. Pixel equality is required only when the contract calls for it; a pixel pass does not prove keyboard, focus, or interaction behavior. Bound retries using the run contract.

## Performance

State the claim, realistic workload, metric, acceptable regression threshold, and sampling budget first. Choose whether the question compares current shipped configurations or tuned alternatives, and hold that comparison consistent. Keep versions, environment, data, and cache policy comparable. Alternate baseline and candidate samples; report sample count, median, variation, errors, and completed work. A small sample is a screening result, not proof of a tiny improvement. If uncertainty overlaps the claimed effect, report inconclusive. Profile separately from timed runs and connect microbenchmarks to the user-visible path. Never accept speedups caused by skipped work or incorrect results. Optimization loops are separate from acceptance checks.

## Behavior-preserving changes and existing fixes

For a refactor, establish the intended preserved contract before editing, then compare old/new outputs and side effects using the same inputs. Record known baseline defects instead of treating them as intended requirements. For a bug fix, reproduce the distinguishing symptom on the baseline and verify the expected outcome on the candidate; use the existing-fix procedure when applicable. A failure to reproduce is inconclusive, not evidence of a fix.

## Agent or skill evaluation

Use realistic tasks with a predefined rubric, held outside the candidate's instructions. When comparing harness variants, hold model, tools, task inputs, and execution limits fixed; use multiple representative tasks and repetitions where variability matters. Blind the judge to candidate identity and verify observable outputs or actual tool records rather than self-reported compliance. Record failures and costs as well as wins. A separate model comparison must be labeled as such. Do not replace deterministic assertions with model judgment where code can check the result.

## Diagnosis and review

Use traces, profiles, impact analysis, or independent review when failed checks or a concrete risk justify them. Treat findings as hypotheses until supported; reviewer consensus alone is not acceptance evidence. Record instrumentation changes and rerun final proof against the intended build. Keep PR status, review replies, and merge operations outside the harness; callers may consume its revision-bound results.
