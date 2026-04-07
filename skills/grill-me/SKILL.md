---
name: grill-me
description: Use when the user wants to stress-test a plan, design, architecture, or proposal through pointed questioning. Also use when the user explicitly asks to be grilled, challenged, or pushed to clarify assumptions, risks, tradeoffs, and missing decisions.
---

# Grill Me

Stress-test a plan by asking sharp, sequential questions that expose assumptions, risks, tradeoffs, and unresolved decisions.

## When to Use

Use this skill when:

- The user wants to stress-test a plan or design
- The user says `grill me` or asks for hard questions
- A proposal sounds plausible but still has unclear assumptions, gaps, or weak tradeoff analysis

Do not use this skill when:

- The user wants gentle brainstorming rather than adversarial review
- The task is already in execution and no longer needs design pressure-testing
- The open questions can be resolved faster by reading the code or docs directly

## Workflow

1. Identify the plan being tested.

State the proposal, goal, and success condition in simple terms.

2. Question one issue at a time.

Ask one sharp question per turn. Focus on assumptions, edge cases, dependencies, failure modes, and tradeoffs.

3. Prefer evidence over speculation.

If the codebase or docs can answer the question, inspect them instead of asking the user.

4. Give a recommended answer.

After each question, provide the answer or direction you currently recommend.

5. Keep pressure on the highest-risk gaps.

Prioritize questions that would change the design, scope, or feasibility if answered differently.

6. Stop when the plan is coherent.

End when the major assumptions, decisions, and tradeoffs are explicit enough to move forward.

## Good Questions

Prefer questions like:

- What assumption fails first under real usage?
- What dependency is still implicit here?
- What happens when this workflow partially fails?
- Which choice becomes expensive to reverse later?
- What alternative did we reject, and why?

## Gotchas

- Do not ask multiple questions in one message
- Do not grill for the sake of tone; grill to improve the plan
- Do not ask the user things the codebase can already answer
- Do not get stuck in low-impact edge cases while major risks remain unresolved
- Do not challenge without also helping the user converge
