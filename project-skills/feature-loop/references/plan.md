# Plan stage

Only handle features opened by the open stage; write no product code in this stage.

## Before planning

1. Read `docs/features/<slug>.md` in the feature workspace and confirm the user approved planning for this run. If the document does not exist, report that `feature-loop open` must run first and stop.
2. Confirm the workspace matches the document. On an explicit re-plan request — a user-approved revision of the plan's scope, design, or acceptance criteria — start the new plan cycle under the shared workflow before revising the plan. Initial planning or resuming the current plan keeps its cycle and count.
3. Set status to "Planning" and the next step to `feature-loop plan <slug>`. Preserve task and verification history; mark decisions and evidence superseded by the new plan.

## Plan

1. Examine relevant code, docs, design mocks, and the domain skills available to this agent (project or global). Record known facts, reversible assumptions, and open questions separately.
2. Write down the background, scope, and explicit non-goals; acceptance criteria describe observable behavior and the rules to protect.
3. Cover the affected data models, API contracts, and UI states and interactions, following the project instructions (`AGENTS.md` or equivalent) and the relevant domain skills.
4. Split the work into independently verifiable tasks, marking dependencies, expected change locations, matching acceptance criteria, and verification method.
   For work that benefits from parallel execution, record blocking steps, disjoint streams, shared mutable state, and the smallest safe split under "Tasks". Omit this checkpoint for a simple single stream; do not invent workers to fill a template.
5. Using the [shared verification rules](gates.md), build the verification plan from actual package scripts and tools; record commands, where to run them, required environment, and expected results. If a needed verification capability is missing, add a task for it; do not assume commands exist.
6. Ask the user only about open questions affecting correctness, data safety, public APIs, migrations, or user-visible behavior; record the answers in the decision log. Keep the status "Planning" while such blockers remain.

## Report and stop

- When the plan is sufficient to implement, set status to "Ready to build" and the next step to `feature-loop build <slug>`; this means the planning output is complete, not that the user has approved implementation.
- Report the scope, acceptance criteria, main tasks, open questions, and document location so the user can revise the plan or continue to build.
- **This run ends here. Do not start build automatically.** The user's decision to continue approves implementation of this plan.
