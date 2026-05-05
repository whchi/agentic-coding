---
name: iterative-retrieval
description: Use when subagents need codebase context they cannot predict upfront—multi-file refactors, unfamiliar codebases, or "context too large" failures. Provides a 4-phase loop for progressive context refinement.
---

# Iterative Retrieval

A 4-phase loop that progressively refines context for subagents.

## Skip When
- Task affects a single known file
- You already know which files are relevant
- Task is trivial (typos, single-line changes)
- Codebase is small enough to fit in context

## Workflow

When retrieving context for a subagent task:

1. **Dispatch.** Start with a broad search using the task's keywords and likely file patterns. Don't over-specify — the first cycle is for discovery.

2. **Evaluate.** Score each result on relevance to the task:
   - **High (0.8-1.0):** Directly implements target functionality
   - **Medium (0.5-0.7):** Related patterns, types, or interfaces
   - **Low (0.2-0.4):** Tangentially related
   - **None (0-0.2):** Irrelevant, exclude from onward searches

   For each file, also note what context is still missing.

3. **Refine.** Update the search: add terminology discovered in high-relevance files, add file patterns from their locations, exclude confirmed irrelevant paths, and target specific gaps identified in step 2.

4. **Repeat.** Run the refined search. Stop when you have 3+ high-relevance files with no critical gaps, or after 3 cycles maximum — whichever comes first. Send the files scored >= 0.7 to the subagent.

## When to Stop
- 3+ files scored >= 0.7 and no critical gaps → send context
- 3 cycles completed → send best available context
- No matches >= 0.5 after 3 cycles → the task may need clarification, not more retrieval

## Examples

**Bug fix — terminology discovery:**
- Cycle 1: Search "token", "auth", "expiry" → finds auth.ts (0.9), tokens.ts (0.8), user.ts (0.3)
- Evaluate: user.ts is noise. Discover missing "refresh", "jwt" terminology from auth.ts.
- Cycle 2: Search "refresh", "jwt" → finds session-manager.ts (0.95), jwt-utils.ts (0.85). Done.

**Feature implementation — naming mismatch:**
- Cycle 1: Search "rate", "limit", "api" → no matches. The codebase uses "throttle."
- Cycle 2: Search "throttle", "middleware" → finds throttle.ts (0.9), middleware/index.ts (0.7). Missing router patterns.
- Cycle 3: Search "router", "express" → finds router-setup.ts (0.8). Done.

## Gotchas
- **Over-engineering:** Don't use this when you already know the target files.
- **Infinite refinement:** 3 cycles max, even if relevance is low.
- **Terminology mismatch:** First cycle often reveals naming conventions. Expect to refine keywords.
- **No matches:** If cycle 3 yields nothing >= 0.5, ask the user to point at relevant files rather than looping blindly.
