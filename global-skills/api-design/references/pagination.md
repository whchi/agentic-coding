# Pagination Reference

## Offset Pagination

Use for small datasets, admin dashboards, and search results where users expect page numbers.

```text
GET /api/v1/users?page=2&per_page=20
```

```sql
SELECT * FROM users
ORDER BY created_at DESC, id DESC
LIMIT 20 OFFSET 20;
```

Pros:
- Easy to implement
- Supports jumping to page N

Cons:
- Slow at large offsets
- Can be inconsistent with concurrent inserts/deletes

## Cursor Pagination

Use for feeds, infinite scroll, large datasets, and public APIs where stable performance matters.

```text
GET /api/v1/users?cursor=opaque-cursor&limit=20
```

Use cursor fields that match the sort order. If sorting by `created_at DESC`, include both `created_at` and `id` in the cursor so ties are deterministic.

```sql
SELECT * FROM users
WHERE (created_at, id) < (:cursor_created_at, :cursor_id)
ORDER BY created_at DESC, id DESC
LIMIT 21;
```

Fetch one extra row to determine whether `has_next` is true.

```json
{
  "data": [],
  "meta": {
    "has_next": true,
    "next_cursor": "opaque-cursor"
  }
}
```

Pros:
- Consistent performance regardless of position
- More stable with concurrent inserts/deletes

Cons:
- Cannot jump to arbitrary page
- Cursor must be treated as opaque by clients

## Cursor Rules

- Cursor must encode every field needed to resume the sort order.
- Always include a deterministic tie-breaker, usually `id`.
- Keep cursors opaque; clients should not depend on cursor internals.
- Do not use only `id > :cursor_id` unless the API sorts by ascending `id`.
