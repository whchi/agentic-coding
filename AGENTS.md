# AGENTS.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Principles

1. The code repository is the only system of record: **if knowledge is not in the repo, it does not exist for the agent**. Discussions, decisions in your head, and external documents—if they affect development, they must be saved as versioned artifacts in the repo.
2. This file is a map, not an encyclopedia: keep it around 100 lines and point to deeper content in `docs/`. Each level should show only its own information and the next step.
3. Turn good taste into rules: use tools like linters, structural tests, type checks, and CI checks to enforce rules, not just written guidelines. Things that can be checked by machines are better than long text.
4. Plans are first-class artifacts: for multi-step or risky work, execution plans should include progress logs, be versioned, and be stored in `docs/`.
5. Do continuous cleanup: fix technical debt in small steps over time instead of waiting for a big cleanup.
6. When stuck, fix the environment, not by trying harder: when the agent has problems, ask **"what context, tools, or constraints are missing?"** and then add them into the repo.

## 2. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before coding, make uncertainty explicit:
- State assumptions that affect the implementation.
- If the task has materially different interpretations, present options before choosing.
- Ask only when missing information affects correctness, data safety, public APIs, migrations, or user-visible behavior. Otherwise, make the smallest reversible assumption and state it.

## 3. Keep the Solution Small

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 4. Keep the Diff Small

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 5. Goal-Driven Execution

**Define success criteria. Loop until verified.**

For every non-trivial task:
1. Define the intended behavior.
2. Add or identify a verification method.
3. Implement the smallest change.
4. Run the relevant check.
5. Report what was changed and what was verified. Do not claim verification you did not perform. If you could not run a check, say so and explain why.

When finished, report:
- What changed
- What was verified
- What was not verified, and why
- Any unrelated issues noticed but not changed

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
