---
name: write-a-prd
description: Use when the user wants a PRD, feature spec, or implementation-ready product plan for a new feature, workflow change, or ambiguous product idea. Also use when the request needs structured clarification before engineering work can be scoped, tested, or tracked.
---

Write a PRD that is clear enough for product discussion and concrete enough for engineering planning.

Match the user's language. If the user writes in Traditional Chinese, write in zh-TW. Keep important technical terms in English when that improves clarity.

## When to Use

Use this skill when:

- The user asks for a PRD, feature spec, or structured feature planning
- The idea is still fuzzy and needs clarification before implementation
- Product intent needs to be connected to engineering scope, risks, and testing
- The team needs a planning document that can later become an issue or execution artifact

Do not use this skill when:

- The user only wants a quick brainstorm or rough idea dump
- The request is already an implementation plan rather than a requirements document
- The user wants code changes now instead of a planning artifact

## Supporting Reference

If the request is early-stage, ambiguous, or product-heavy, read `references/product-discovery.md` before drafting.

Use it to strengthen:

- product vision and positioning
- representative personas and pain points
- user journey and touchpoints
- feature mapping
- technical risks and validation gaps

Do not mirror its structure blindly. Pull in only the parts that improve the current PRD.

## Workflow

1. Clarify the request.

Ask for the problem, desired outcome, constraints, and any existing solution ideas. If the request is vague, ask focused follow-up questions instead of guessing.

2. Inspect the current system.

Explore the repo and surrounding product surface to verify assumptions, constraints, and likely integration points.

3. Frame the problem.

Understand both:

- Product perspective:
  - What user problem is being solved?
  - Who are the most important users or personas?
  - What is the current pain?
  - What is the value of solving it?
  - What workflow or user journey is changing?
- Engineering perspective:
  - What systems or modules are likely involved?
  - What technical constraints or dependencies matter?
  - What risks, unknowns, or validation gaps exist?
  - What testing strategy would give confidence?

4. Identify implementation shape.

Sketch the major modules or system areas likely to change. Prefer deep modules with stable interfaces when possible.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

5. Confirm key decisions.

Check important assumptions with the user before locking them into the PRD. Confirm which modules or flows deserve explicit testing emphasis.

6. Write the PRD.

Use the template below. Expand sections in proportion to their importance; do not fill every section mechanically.

## Writing Principles

- Be concrete. Replace vague phrases with observable user problems, specific workflows, and meaningful tradeoffs.
- Stay user-centered. A PRD should explain why the feature matters to users, not just what engineers will build.
- Stay technically grounded. Do not promise behavior that conflicts with the current codebase or architecture.
- Surface uncertainty honestly. If something needs validation, say so explicitly instead of fabricating certainty.
- Prefer stable decisions over fragile detail. Include architectural and interface decisions, but avoid file paths and code snippets that will become stale quickly.
- Make the document useful for implementation. The PRD should help someone plan the work, not just admire the thinking.

## Gotchas

- Do not guess missing product facts. If market, user, or technical details are unknown, label them as unknowns.
- Do not turn the PRD into a code plan. Focus on requirements, decisions, risks, and validation.
- Do not write fake personas or market gaps unless they are grounded in the user's context.
- Do not pad the document with repetitive user stories just to make it look thorough.
- Do not force every section to be equally detailed. Expand what matters most for the current feature.

<prd-template>

## Title

A concise feature or initiative name.

## Problem Statement

Describe the problem from the user's perspective.

Include, when relevant:

- The target users or personas affected
- Their current pain points
- The workflow that is breaking down or missing
- Why this matters now
- Any meaningful market gap or product opportunity

## Solution

Describe the solution from the user's perspective.

Include, when relevant:

- The product vision for this change
- The core user experience or flow that will exist after the feature ships
- The major capabilities being introduced
- Important constraints, tradeoffs, or non-goals that shape the solution

## User Stories

Provide a numbered list of user stories covering the main journey, important decision points, failure cases, and operational needs where relevant.

Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

Prefer coverage over sheer volume. Do not generate repetitive or low-value variants.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions
- Reliability or scalability considerations
- Technical unknowns that require validation

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)
- The highest-risk flows that need explicit coverage
- What should be validated manually vs automatically, if relevant

## Out of Scope

A description of the things that are out of scope for this PRD.

## Further Notes

Any further notes about the feature.

This is a good place for:

- Open questions
- Follow-up research items
- Assumptions that should be revisited later
- Risks that are understood but not yet fully solved

</prd-template>

## Quality Bar

Before finalizing the PRD, check that it:

- Explains the user value clearly
- Names the most important personas or user segments
- Captures the end-to-end journey, not just isolated features
- Identifies the main modules or system areas impacted
- Surfaces meaningful implementation and testing decisions
- Calls out unknowns instead of hiding them
- Avoids stale low-level detail like file paths or code snippets
