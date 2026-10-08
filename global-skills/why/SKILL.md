---
name: why
description: Investigate why code or a design decision exists using commits, discussions, and documented history; distinguish recorded intent from inference.
origin: backnotprop/pstack@3a60467 (MIT)
---

# Why

Find the motivation for a piece of code from the historical record. Code shows what it does. Code does not show why it exists. The reason is in commits, pull requests (PRs), issues, documents, and discussions.

This skill is read-only. Do not change files, commit, or post comments.

## Terms

- **Target**: the code, pattern, or decision that the question is about.
- **Claim**: one statement about why the target exists.
- **Evidence**: text that a person wrote, with a citation that a reader can open.
- **Tier**: the confidence level of a claim. See [references/epistemics.md](references/epistemics.md).

## Boundaries

- `zoom-out` explains what the code does and where it sits in the system.
- `blast-radius` finds what a change breaks elsewhere. It uses a certainty ladder that measures verification strength. The tiers in this skill measure the reliability of a historical claim. Do not merge the two scales.
- `debugging-playbook` diagnoses a failure that occurs now.

## Step 1. State the target and the question

1. Identify the target: file, line range, symbol, pattern, or named decision.
2. Identify the question type: design rationale, tradeoff, edge case, external constraint, threshold value, dead code, or history.
3. If the target is not clear, use the conversation context to select the most probable target.
4. State your interpretation in one sentence, then continue.

If the user gives a hypothesis ("I assume it is for performance"), record it as one candidate. Do not accept it as the answer.

## Step 2. Build the code anchor

Collect file paths, line ranges, key symbols, the commits that changed the target, PR numbers, and linked issue IDs. Use the commands in [references/git-archaeology.md](references/git-archaeology.md).

```bash
git blame -L <start>,<end> <file>
git log --follow --oneline -- <file>
git log -S '<exact string>' -- <file>
git log -L <start>,<end>:<file>
gh pr view <number> --json title,body,comments,reviews,closingIssuesReferences
```

Follow earlier history when the latest commit does not explain the decision. Stop once the evidence answers the question or further search is unlikely to resolve a stated gap.

## Step 3. Search the sources

Start with available history near the target. A shallow checkout or missing PR access is a limitation, not a reason to invent context or search the entire history.

1. Read commit messages, PR bodies, review comments, and linked issues for each relevant commit.
2. Read code comments, tests, ADRs, CHANGELOG entries, and `docs/` near the target.
3. If the target is defensive code, search for incident history. Defensive code includes retries, timeouts, null guards, rate limits, and feature flags.

Other sources are optional. Use them only when the harness has a tool for them. These sources are issue trackers, team chat, long-form documents, observability, error tracking, and analytics. See [references/optional-sources.md](references/optional-sources.md).

- Do not invent a tool or a search result.
- If a tool fails authentication, record the source as a gap.
- If no tool exists for a source, record the source as "not available".

## Step 4. Optional fan-out

Use a single agent for a focused investigation. Consider authorized delegation only for substantial, independent source searches; available sources alone do not require fan-out.

Give each subagent the question, the code anchor, and one source. Tell each subagent to return evidence, not conclusions:

- the searches it ran, with the exact queries;
- verbatim quotes with citations, authors, and dates;
- contradictions and gaps;
- leads that point to a different source.

You then do Step 5 yourself, with all subagent results.

## Step 5. Classify each claim

1. Put each claim in one tier: Direct, Supported, Inferred, Speculative, or Unknown.
2. Attach a citation to each Direct and Supported claim.
3. Use hedged words for Inferred and Speculative claims.
4. Do not use the code as evidence for its own intent.
5. When two sources disagree, show both with citations. Do not select the source that gives a simpler story.
6. Spot-check each citation that a conclusion depends on.

The full rules and the calibration check are in [references/epistemics.md](references/epistemics.md).

## Output

Use the sections that help answer the question. For a simple finding, a cited explanation with confidence and any gap is sufficient.

- **The question**: one or two sentences.
- **The code**: paths, line ranges, and symbols.
- **What we found**: `[Direct]` and `[Supported]` claims, each with a citation.
- **What we can infer**: `[Inferred]` claims, each with the reasoning chain. Remove if empty.
- **Competing hypotheses**: each with evidence for and evidence against. Remove if one answer is clear.
- **Contradictions**: sources that disagree, with both citations. Remove if empty.
- **What we do not know**: `[Unknown]` items, with the sources and queries that you searched.
- **Sources consulted**: one line for each source category, including sources that were empty, failed, or not available.
- **Confidence summary**: one or two sentences.

If the user plans to change the target, add a constraint set:

- **Preserve**: behavior that a Direct or Supported claim requires.
- **Change**: behavior that the evidence shows is obsolete or accidental.
- **Avoid**: approaches that the history shows failed or were rejected.
- **Risk**: items where the evidence is Inferred, Speculative, or Unknown.

Mark the tier of the claim that supports each constraint.
