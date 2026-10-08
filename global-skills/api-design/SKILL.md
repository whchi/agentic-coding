---
name: api-design
description: Design or review REST endpoint contracts when adding an endpoint or changing its request, response, authorization, or compatibility behavior.
origin: ECC
---

# API Design Patterns

Preserve the published contract and conventions of the affected API. For a new contract, choose the resource, lifecycle operation, and consumer needs before choosing routes or response shapes.

## Contract decisions

- Use resource-oriented routes and HTTP semantics. Use action endpoints when an operation does not naturally fit a resource update.
- Keep success and error shapes consistent for the API surface. Envelopes help when clients need metadata or links; existing flat responses do not need a migration merely for style.
- Validate and normalize request data at the boundary. Keep shape validation separate from authorization, and check resource ownership before returning private data.
- Map application errors at a shared outer boundary. Expose stable codes and messages; keep SQL errors, stack traces, vendor details, and secrets in protected diagnostics.
- Bound collections and expensive requests. Choose pagination and rate limits from actual client usage and load, not from a universal endpoint template.
- Preserve compatibility for deployed consumers. Version or provide a migration window for breaking changes; adding a version to every internal endpoint is unnecessary.
- Document the resulting contract and verify changed success, failure, and permission behavior within the repository's allowed test scope.

Treat naming, envelopes, pagination styles, and version prefixes as defaults subordinate to existing client contracts. A field addition can still break strict consumers; verify compatibility rather than assuming every additive change is harmless.

## Read only the relevant reference

- [Review rules](references/review-rules.md): request validation, return contracts, error boundaries, and edge cases during endpoint review.
- [Status codes](references/status-codes.md): selecting success and failure responses.
- [Pagination](references/pagination.md): offset/cursor tradeoffs and stable cursor SQL.
- [Implementation examples](references/implementation-examples.md): handler sketches for TypeScript, Django REST Framework, and Go.

For a review, report concrete contract issues, affected consumers, compatibility risks, and the smallest safe fix. A request to review does not itself authorize changing the API.
