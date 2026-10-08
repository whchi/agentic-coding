---
name: blast-radius
description: Use when the question is what a change can break outside its diff before it ships, such as "what could this break" or a small diff that is not trusted; proves the one fact that the change is safe because of. Do NOT use to explain what code does (`zoom-out`), to explain why code has its shape (`why`), or to decide merge readiness (`code-review` command).
origin: backnotprop/pstack@3a60467 (MIT)
---

# Blast Radius

Find what a change breaks outside its diff, before it ships. A list of callers is not the result. An agent can find callers with one search. The result is the breakage that a symbol search does not show.

## Terms

- **Safety fact**: the one fact that makes the change safe. If it is true, most risks are cleared.
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
- Do not delete files that you did not create.

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

1. Read the change. Identify the diff and the symbols that it adds, changes, and deletes. Identify the change in behavior, including the part that the diff does not show. To find the PR and the commits, use Step 2 of `why`.
2. Find the safety fact. Most changes that look risky are safe because of one fact. An example is "this call removes only expired cache entries and has no other effect". Spend most of your time on this step, not on a long list of possible risks.
3. Examine the areas that a symbol search does not reach:
   - Read the source of each library that the change calls. Examine the pinned version and each local patch.
   - Identify when code runs: microtasks, unmount, teardown, and framework lifecycle.
   - Trace data that crosses a boundary: API responses, database columns, wire formats, and other languages that read the same bytes.
   - Examine feature flags and code three or more calls downstream.
4. Assess each risk honestly. Give each risk a realistic probability and a realistic cost. Keep confirmed risks separate from cleared risks.
5. Cite only real code. A search that finds nothing is a valid result. Do not invent a caller or an API.
6. Prove the safety fact. Write a proof script that runs the real code. Run it. Paste the output.

## Output

- **What it does**: what changed, including the part that is not obvious.
- **Safety fact**: the fact, its certainty level, and the proof. If you did not prove it, write "unproven".
- **Risks**: for each risk, how it breaks, the `file:line`, the probability, the cost, and how to verify it. Paste the proof for each important risk.
- **Cleared**: what you examined, and why it is safe.
- **Before merge**: the cheapest test or reproduction that catches the real failure. Include the path of each proof script.

Cite real code. Remove private data before you put the writeup in a public location.
