# API Review Rules

Use these rules when reviewing or designing endpoint contracts, request boundaries, response shapes, and API-facing interface contracts.

## Response And Route Shape

Check:

1. Endpoints do not end with a trailing slash.
2. Route parameters are validated before they decide what data to fetch.
3. Response keys use camelCase unless the existing contract uses another convention.
4. Success responses return the payload directly or follow the existing envelope convention.
5. Error responses use one explicit, consistent shape.
6. Internal exception details, SQL errors, stack traces, and low-level IO details are not exposed.
7. Create/update endpoints for SPA clients return useful data when it prevents an immediate redundant GET.
8. Public APIs include readable links when relationships or follow-up actions matter.

Output:

- Contract issues
- Compatibility risks
- Suggested response shape
- Suggested status codes

## Request Validation

Principle: do not trust caller-provided data. Validate at the boundary before business logic or persistence.

Check:

1. Validate path params, query params, headers, body fields, and file metadata.
2. Reject unknown enum values and primitive strings used as implicit modes.
3. Prefer constants, enums, or discriminated unions for condition values.
4. Confirm route params are not blindly bound to data type, tenant, mode, or query behavior.
5. Validate authorization separately from request shape validation.
6. Normalize values once near the boundary, then pass typed or validated data inward.
7. Return consistent validation errors without leaking implementation details.

Output:

- Missing validation
- Risk
- Recommended schema or guard
- Where validation should live

## Exception Boundary

Principle: handle expected application errors at a shared outer boundary, and wrap low-level IO errors before they cross user-facing boundaries.

Check:

1. Define application-level exceptions for known failure modes.
2. Map each known exception to an HTTP status code or caller-facing error code.
3. Throw or return the application-level error where the decision is known.
4. Do not expose DB, Redis, file-system, network, or vendor exception details to outside callers.
5. Wrap low-level errors near the user-facing IO boundary, such as a controller, handler, or adapter.
6. Preserve internal logs and trace IDs for debugging.
7. Keep unexpected errors generic to callers.

Output:

- Current boundary
- Leaky errors
- Missing mappings
- Suggested error shape/status code

## API Contract Return Shape

Use this for functions, methods, API handlers, and library interfaces that define API-facing contracts.

Check:

1. Prefer returning one stable self-defined type when the result has structure.
2. Returning `null` or a primitive is acceptable for simple cases if the contract is explicit.
3. Avoid returning more than two unrelated shapes from one function or endpoint.
4. Avoid parameters that accept many unrelated types.
5. Use generics only when runtime behavior genuinely depends on caller-provided type or shape.
6. Replace primitive condition values with enums, constants, or discriminated unions.
7. Make error cases explicit instead of mixing magic values into success returns.

Output:

- Current contract
- Ambiguity or type explosion
- Suggested replacement type
- Migration notes

## API Edge Cases

Cover these before inventing exotic cases:

| Shape | Examples |
|---|---|
| No value | Empty list, empty string, null, undefined, absent field, missing relation |
| One value | Single row, single item, one selected option, one character |
| Ordinary value | Common valid production path |
| Maximum value | Configured limit, page size, field length, quota, full capacity |
| Mixed sizes | Small/medium/large in the same request, sorted and unsorted |
| Invalid shape | Wrong type, unknown enum, malformed date, invalid ID |
| Duplicate/conflict | Repeated items, unique constraint collision, idempotency retry |
| Permission/state boundary | Allowed vs denied, draft vs published, active vs deleted |

Output a table with:

- Case
- Why it matters
- Expected behavior
- Suggested test level
