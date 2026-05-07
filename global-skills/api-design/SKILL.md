---
name: api-design
description: Use when designing, implementing, or reviewing REST API endpoints, API contracts, resource URLs, HTTP status codes, pagination, filtering, response shapes, request validation, error handling, auth boundaries, versioning, rate limits, SPA update flows, or REST/RPC/GraphQL tradeoffs.
origin: ECC
---

# API Design Patterns

Use this for REST API design and review. Optimize for consistent contracts, correct HTTP semantics, clear errors, and compatibility with existing clients.

## API Design Workflow

1. Identify audience: public API, partner API, internal API, or service-to-service.
2. Define the resource and lifecycle operation before choosing URL/method.
3. Choose response shape: envelope for public/partner APIs, flat allowed for internal APIs if existing conventions use it.
4. Choose list behavior: pagination, filtering, sorting, and field selection.
5. Define error shape and status codes before implementation.
6. Define where request validation, authorization, and exception mapping happen.
7. Confirm auth, rate limits, and documentation updates.
8. Check existing endpoints for naming and response consistency.

## Boundaries

Use related skills instead of stretching this one:

- `domain-driven-design-advisor` for DDD fit, aggregate design, bounded contexts, and domain modeling.
- `repository-boundary-review` for whether persistence, use cases, and aggregates own the right behavior.
- `testing-strategy` for choosing test level, mocks, fixtures, and coverage.
- `frontend-robust-data-handling` for adapting API payloads into render-safe frontend view models.

## Audience Defaults

| API Type | Response Shape | Pagination | Versioning | Rate Limits |
|----------|----------------|------------|------------|-------------|
| Public | Envelope | Cursor default | Explicit version | Required |
| Partner | Envelope | Cursor or offset by use case | Explicit version | Required |
| Internal app | Existing convention | Offset acceptable for small sets | Avoid until needed | Optional |
| Service-to-service | Existing convention | Cursor for large sets | Contract/version by deploy model | Usually required |

## Resource Design

### URL Structure

```text
# Resources are nouns, plural, lowercase, kebab-case
GET    /api/v1/users
GET    /api/v1/users/:id
POST   /api/v1/users
PUT    /api/v1/users/:id
PATCH  /api/v1/users/:id
DELETE /api/v1/users/:id

# Sub-resources for ownership or containment
GET    /api/v1/users/:id/orders
POST   /api/v1/users/:id/orders

# Actions that do not map to CRUD; use verbs sparingly
POST   /api/v1/orders/:id/cancel
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
```

### Naming Rules

```text
# GOOD
/api/v1/team-members
/api/v1/orders?status=active
/api/v1/users/123/orders

# BAD
/api/v1/getUsers
/api/v1/user
/api/v1/team_members
/api/v1/users/123/getOrders
```

## Endpoint Style

Use REST for resource lifecycle operations and common CRUD. Use RPC-style endpoints for operation-heavy workflows that do not naturally map to a resource update. Use GraphQL only when clients need flexible relationship traversal and the team can manage the added complexity, authorization, and performance risks.

Do not bind route params directly to data type selection or query behavior without explicit validation.

## Methods And Status Codes

| Method | Idempotent | Safe | Use For |
|--------|------------|------|---------|
| GET | Yes | Yes | Retrieve resources |
| POST | No | No | Create resources, trigger actions |
| PUT | Yes | No | Full replacement of a resource |
| PATCH | Usually no | No | Partial update of a resource |
| DELETE | Yes | No | Remove a resource |

| Situation | Status | Notes |
|-----------|--------|-------|
| Successful read/update with body | `200 OK` | GET, PUT, PATCH |
| Created resource | `201 Created` | Include `Location` header |
| Successful action with no body | `204 No Content` | DELETE, sometimes PUT/PATCH |
| Malformed JSON or invalid query syntax | `400 Bad Request` | Request cannot be parsed |
| Missing/invalid auth | `401 Unauthorized` | Include auth challenge when applicable |
| Authenticated but not allowed | `403 Forbidden` | Use `404` instead only to avoid enumeration |
| Resource not found | `404 Not Found` | Do not return `200` with error body |
| State conflict or duplicate | `409 Conflict` | Duplicate email, invalid state transition |
| Semantically invalid input | `422 Unprocessable Entity` | Valid JSON, invalid fields |
| Rate limited | `429 Too Many Requests` | Include `Retry-After` |
| Unexpected failure | `500 Internal Server Error` | Do not expose internals |

For more detail, see `references/status-codes.md`.

## Response Shape

### Choosing A Shape

| Context | Preferred Shape | Why |
|---------|-----------------|-----|
| Public or partner API | Envelope | Stable place for `meta`, `links`, and future fields |
| Internal API with existing flat responses | Existing convention | Consistency beats abstract purity |
| New internal API with list endpoints | Envelope for collections | Pagination metadata needs a home |

### Success

```json
{
  "data": {
    "id": "abc-123",
    "email": "alice@example.com",
    "name": "Alice"
  }
}
```

For SPA create/update flows, return useful updated data when it prevents an immediate redundant GET. Do this only when the extra payload is stable and clearly useful to the client workflow.

### Collection

```json
{
  "data": [{ "id": "abc-123", "name": "Alice" }],
  "meta": { "has_next": true, "next_cursor": "opaque-cursor" },
  "links": { "self": "/api/v1/users?limit=20" }
}
```

### Error

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be a valid email address", "code": "invalid_format" }
    ]
  }
}
```

## Pagination

| Use Case | Default |
|----------|---------|
| Admin dashboards, small datasets under 10K | Offset |
| Infinite scroll, feeds, large datasets | Cursor |
| Public APIs | Cursor by default; offset only when users need page numbers |
| Search results | Offset often fits user expectations |

Cursor pagination must use a stable sort and deterministic tie-breaker. For example, sort by `(created_at DESC, id DESC)` and encode both values in the cursor. Do not use only `id > cursor_id` unless the list is actually ordered by ascending `id`.

For SQL examples, see `references/pagination.md`.

## Filtering, Sorting, Search, Fields

| Need | Convention | Example |
|------|------------|---------|
| Equality filter | Query params | `/api/v1/orders?status=active` |
| Comparison filter | Bracket notation | `/api/v1/products?price[gte]=10&price[lte]=100` |
| Multiple values | Comma-separated | `/api/v1/products?category=electronics,clothing` |
| Nested field | Dot notation | `/api/v1/orders?customer.country=US` |
| Sorting | `sort`, prefix `-` for descending | `/api/v1/products?sort=-featured,price` |
| Search | `q` for full-text query | `/api/v1/products?q=wireless+headphones` |
| Sparse fields | `fields` and optional `include` | `/api/v1/users?fields=id,name,email` |

## Authentication And Authorization

```text
GET /api/v1/users
Authorization: Bearer <token>

GET /api/v1/data
X-API-Key: <api-key>
```

Rules:
- Authentication proves who the caller is.
- Authorization proves the caller can access this resource or action.
- Check resource-level ownership before returning private data.
- Use `404` instead of `403` only when intentionally avoiding resource enumeration.
- Never include stack traces, SQL errors, token contents, or secret values in responses.

## Request Boundary

Validate route params, query params, headers, body fields, and file metadata when the request enters the backend. Normalize values once near the request boundary, then pass typed or validated data inward.

Keep validation and authorization separate:

- Validation proves the request shape is acceptable.
- Authorization proves the caller may perform the action on the target resource.
- Route params should not select data type, tenant, mode, or query behavior until explicitly validated.

## Error Boundaries

Map known application errors to status codes at a shared outer boundary such as a controller, route handler, or adapter. Internally log enough detail to debug, but expose only stable public error codes and messages.

Do not expose:

- SQL errors
- Stack traces
- Vendor exception names
- Raw DB, Redis, network, or file-system details
- Secret or token values

## Localization Ownership

Frontend owns presentation strings by default because it knows the locale and rendering context.

Backend owns text when it is:

- API error content
- User-entered content that needs server-side control, moderation, transformation, or persistence
- Backend-generated ordering, ranking, grouping, or configuration that affects displayed text
- Admin-configured content later rendered to end users

## Backend Layering Notes

When the backend uses DDD or clean architecture:

- Controllers and request handlers parse input and call application use cases.
- DTOs belong near the application or interface-adapter boundary, not inside pure domain objects.
- Domain objects should not depend on HTTP, request schemas, ORM models, or response presenters.
- Use cases decide output shape; aggregate roots should not change because a screen needs a different response.
- Repository interfaces should reflect aggregate roots and domain language, while repository implementations can use ORM, DAO, or query-builder details.
- External systems should enter through adapters so their domain language does not leak into the core domain.

## Rate Limiting

```text
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000

HTTP/1.1 429 Too Many Requests
Retry-After: 60
```

Use rate limits for public, partner, authentication, and expensive endpoints. Internal APIs may still need limits when one caller can overload a shared dependency.

## Versioning

Do not add new versions until there is a real compatibility need.

Defaults:
- Public or partner API: start at `/api/v1` if external clients need stable contracts.
- Internal-only API: avoid versioning unless multiple deployed clients must coexist.
- Breaking changes require a new version or compatibility window.
- Non-breaking changes include adding fields, optional query params, or new endpoints.

Breaking changes:
- removing or renaming fields
- changing field types
- changing URL structure
- changing authentication method

For public deprecations, announce ahead of time and use `Sunset` headers before returning `410 Gone` after the sunset date.

## API Design Checklist

Before shipping a new endpoint:

- [ ] Audience and compatibility expectations are explicit
- [ ] Resource URL uses plural kebab-case nouns and no CRUD verbs
- [ ] HTTP method matches the operation
- [ ] Status codes are semantic, not `200` for everything
- [ ] Request input is validated with a schema or equivalent contract
- [ ] Validation happens at the request boundary before business logic or persistence
- [ ] Error responses follow the standard shape with stable codes
- [ ] Low-level IO exceptions are mapped before crossing user-facing boundaries
- [ ] List endpoints have pagination and documented limits
- [ ] Filtering, sorting, search, and field selection match existing conventions
- [ ] Authentication is required or the endpoint is explicitly public
- [ ] Authorization checks resource ownership or permissions
- [ ] Rate limits are configured or intentionally omitted
- [ ] Responses do not leak internal details
- [ ] OpenAPI/Swagger or equivalent contract docs are updated

## Gotchas

- **Don't version internal APIs by reflex** — version only when clients need compatibility windows.
- **Don't over-engineer pagination** — offset is fine for small admin datasets.
- **Don't use unstable cursors** — cursor fields must match the sort order and include a tie-breaker.
- **Don't envelope everything blindly** — public APIs benefit from envelopes; internal APIs may follow existing flat conventions.
- **Watch response size** — sparse fields and pagination matter more than envelope debates.
- **404 vs 403 is a product/security choice** — use `404` for enumeration resistance, otherwise distinguish missing from forbidden.

## References

Read supporting files only when needed:
- `references/status-codes.md` for detailed HTTP status guidance
- `references/pagination.md` for offset/cursor examples and stable cursor rules
- `references/review-rules.md` for endpoint review checklists covering response shape, request validation, API-facing return contracts, and edge cases
- `references/implementation-examples.md` for TypeScript, Django REST Framework, and Go handlers
