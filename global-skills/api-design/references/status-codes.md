# Status Code Reference

Use HTTP status codes semantically. Do not return `200 OK` with an embedded failure status.

## Success

| Status | Use For | Notes |
|--------|---------|-------|
| `200 OK` | Successful read/update with response body | GET, PUT, PATCH |
| `201 Created` | Resource creation | Include `Location` header |
| `202 Accepted` | Async work accepted but not complete | Include status URL when available |
| `204 No Content` | Success with no response body | DELETE, idempotent actions |

## Client Errors

| Status | Use For | Notes |
|--------|---------|-------|
| `400 Bad Request` | Malformed JSON, invalid query syntax | Request cannot be parsed |
| `401 Unauthorized` | Missing or invalid authentication | Authentication problem, not authorization |
| `403 Forbidden` | Authenticated but not authorized | Caller is known but not allowed |
| `404 Not Found` | Resource does not exist | May also hide forbidden resources |
| `409 Conflict` | State conflict or duplicate | Duplicate email, invalid transition |
| `422 Unprocessable Entity` | Semantically invalid fields | Valid JSON, invalid data |
| `429 Too Many Requests` | Rate limit exceeded | Include `Retry-After` |

## Server Errors

| Status | Use For | Notes |
|--------|---------|-------|
| `500 Internal Server Error` | Unexpected failure | Do not expose details |
| `502 Bad Gateway` | Upstream service failed | Gateway/proxy dependency failure |
| `503 Service Unavailable` | Temporary overload or maintenance | Include `Retry-After` when possible |

## Common Mistakes

```text
# BAD: 200 for everything
HTTP/1.1 200 OK
{ "status": 404, "success": false, "error": "Not found" }

# GOOD: semantic status code
HTTP/1.1 404 Not Found
{ "error": { "code": "not_found", "message": "User not found" } }

# BAD: 500 for validation errors
# GOOD: 400 for malformed requests, 422 for semantic validation failures

# BAD: 200 for created resources
# GOOD: 201 Created with Location header
HTTP/1.1 201 Created
Location: /api/v1/users/abc-123
```
