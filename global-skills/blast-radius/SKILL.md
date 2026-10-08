---
name: blast-radius
description: Assess what a proposed change can break outside its diff when downstream compatibility or hidden effects need investigation.
origin: backnotprop/pstack@3a60467 (MIT)
---

# Blast Radius

Find what a change breaks outside its diff, before it ships. A list of callers is not the result. An agent can find callers with one search. The result is the breakage that a symbol search does not show.

## Terms

- **Safety fact**: an invariant or assumption on which the change's safety depends. A change can depend on more than one.
- **Risk**: one way that the change can break other code or behavior.
- **Certainty level**: how far a fact is verified on the ladder below.
- **Proof script**: a throwaway script or test that calls the real code and fails if the fact is false.

## Boundaries

- `zoom-out` explains what code does and where it sits in the system.
- `why` explains why code has its current shape, from the historical record.
- `code-review` (a command) decides merge readiness.
- This skill finds what a change breaks elsewhere.

The certainty ladder in this skill measures verification strength. The tiers in `why` measure the reliability of a historical claim. Do not merge the two scales.

## Read-only

This skill is read-only by default.

- Do not change product code, tests, or configuration in the repository.
- You can write and run a proof script in a scratch location, such as the session scratchpad or a temporary directory.
- Report the path of each proof script.
- Follow repository approval rules for deleting scratch files as well as existing files.

## Do not trust your own writeup

A writeup that sounds correct is not evidence. It sounds convincing when it is true and when it is false. Find the one or two facts that the safety depends on. Prove those facts with code that runs.

## Certainty ladder

For each fact that the safety depends on, move it as far down this ladder as the cost permits. State the level where it stopped.

1. **Said so.** You stated it. This level has no value alone.
2. **file:line.** You cited a real `file:line`, or the source of the library.
3. **Walked the failure.** You traced the failure case step by step, and it does not occur.
4. **Ran a script against real code.** A proof script calls the real code and fails if you are wrong.
5. **Reproduced in the app.** You reproduced the behavior in the running app.

Level 4 is often one small script. The script imports the library version that the app uses and calls the function that is at risk.

## Steps

1. Read the diff and identify changed behavior and affected contracts. Use git or PR context as needed; a separate history investigation is optional.
2. Find the safety fact. Most changes that look risky are safe because of one fact. An example is "this call removes only expired cache entries and has no other effect". Spend most of your time on this step, not on a long list of possible risks.
3. Examine the areas that a symbol search does not reach:
   - Inspect the pinned library version or local patch when safety depends on behavior the public contract does not establish.
   - Identify when code runs: microtasks, unmount, teardown, and framework lifecycle.
   - Trace data that crosses a boundary: API responses, database columns, wire formats, and other languages that read the same bytes.
   - Follow feature flags and downstream consumers until the relevant contract or side effect is accounted for.
4. Describe each concrete failure and its impact. Use qualitative likelihood unless evidence supports a numeric estimate; keep confirmed risks separate from cleared ones.
5. Cite only real code. A search that finds nothing is a valid result. Do not invent a caller or an API.
6. Verify the safety facts with the cheapest useful evidence. Run a focused proof when inspection leaves an important uncertainty and the environment permits it; otherwise mark the fact unproven. Respect worktree test scope and side-effect permissions.

## Output

- **What it does**: what changed, including the part that is not obvious.
- **Safety fact**: the fact, its certainty level, and the proof. If you did not prove it, write "unproven".
- **Risks**: for each risk, how it breaks, the `file:line`, the supported likelihood, the impact, and how to verify it. Link or summarize evidence for important risks.
- **Cleared**: what you examined, and why it is safe.
- **Before merge**: the cheapest test or reproduction that catches the real failure. Include the path of each proof script.

Cite real code. Remove private data before you put the writeup in a public location.
