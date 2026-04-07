---
name: write-a-prd
description: Use when the user wants a PRD, feature spec, or structured feature planning that connects product intent, user needs, implementation decisions, and testing scope. Also use when a feature idea is still fuzzy and needs guided clarification before it becomes an engineering-ready PRD.
---

Write a PRD that is product-aware and engineering-ready. The goal is not just to summarize an idea, but to turn it into a document that gives product and engineering a shared understanding of what should be built, why it matters, and how to validate it.

Match the user's language. If the user writes in Traditional Chinese, write in zh-TW. Keep important technical terms in English when that improves clarity.

If the request is still vague, do not guess. Ask focused clarification questions first.

If you need a stronger product-discovery frame, read `example.md` in this skill directory before drafting. Use it as a reference for the quality bar, interview depth, and analysis dimensions. Do not copy it mechanically. Pull in what is useful: product vision, market positioning, representative personas, end-to-end user journey, feature mapping, and explicit technical unknowns.

## Workflow

1. Ask the user for a detailed description of the problem, the desired outcome, known constraints, and any solution ideas they already have.

2. Explore the repo to verify their assumptions and understand the current state of the codebase, product surface, and surrounding architecture.

3. Clarify the request until you reach a shared understanding. Resolve important ambiguities one-by-one instead of letting them leak into the PRD.

4. Analyze the request from both a product and engineering perspective:

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

5. Sketch the major modules that will need to be built or modified. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

6. Once you have a complete understanding of the problem and solution, write the PRD using the template below. If the user wants execution tracking, the PRD should be suitable for submission as a GitHub issue.

## Writing Principles

- Be concrete. Replace vague phrases with observable user problems, specific workflows, and meaningful tradeoffs.
- Stay user-centered. A PRD should explain why the feature matters to users, not just what engineers will build.
- Stay technically grounded. Do not promise behavior that conflicts with the current codebase or architecture.
- Surface uncertainty honestly. If something needs validation, say so explicitly instead of fabricating certainty.
- Prefer stable decisions over fragile detail. Include architectural and interface decisions, but avoid file paths and code snippets that will become stale quickly.
- Make the document useful for implementation. The PRD should help someone plan the work, not just admire the thinking.

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

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

The user stories should reflect the real journey of the product, not just a flat list of CRUD actions. Cover key touchpoints, decision points, happy paths, failure paths, and admin or operational needs where relevant.

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
