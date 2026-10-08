---
description: "Create or refresh architecture codemaps after structural changes or when the user requests a codebase map."
---

# /update-codemaps

Produce concise, navigable documentation of observed module responsibilities, boundaries, entry points, and data flow.

Use the requested scope; otherwise inspect the project structure to choose useful maps. Follow existing codemap placement, or use `docs/CODEMAPS/` when none exists. Create only maps supported by the project: architecture, backend, frontend, data, dependencies, or contexts as relevant.

Read `CONTEXT.md` for domain language and `CONTEXT-MAP.md` when mapping domain boundaries. Follow relevant ADRs rather than loading every document. Describe observed responsibilities when domain terminology is unavailable.

## Content

- Prefer source paths, public interfaces, and compact flow diagrams over copied implementation.
- Link a top-level map to deeper maps with the task or question each answers.
- Trace important relationships to inspected code. Distinguish observed behavior from uncertain or stale documentation.
- Include external services and shared dependencies where they affect boundaries.
- Add freshness metadata with the actual inspection date and scope. Do not invent scan counts or token estimates.

For existing maps, preserve hand-written context and update facts supported by the change. A large diff is a reason to inspect carefully, not an automatic approval gate. Continue authorized edits and repairs; report an unresolved semantic conflict rather than silently replacing it. Apply the repository's approval rule before deleting files.

Verify referenced paths and key relationships, then review the diff for unsupported claims and accidental loss of useful context. Documentation-only changes need content and diff checks, not application suites.

Return changed map paths, meaningful architecture changes, verification results, and uninspected or uncertain areas. Write a separate scan report only when requested or required by the project.
