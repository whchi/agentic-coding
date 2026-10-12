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
| `400 Bad Request` | Client errors, including malformed requests or validation failures | Not limited to parsing errors; preserve the API's validation contract |
| `401 Unauthorized` | Missing or invalid authentication credentials | Must include an applicable `WWW-Authenticate` challenge |
| `403 Forbidden` | Request understood but refused | Does not require an authenticated caller |
| `404 Not Found` | Resource does not exist | May also hide forbidden resources |
| `409 Conflict` | State conflict or duplicate | Duplicate email, invalid transition |
| `422 Unprocessable Content` | Understood content type and valid syntax, but instructions cannot be processed | Suitable for semantic validation; preserve existing framework constants and API conventions |
| `429 Too Many Requests` | Rate limit exceeded | Recommend `Retry-After` when a useful delay is known; the header is optional |

## Server Errors

| Status | Use For | Notes |
|--------|---------|-------|
| `500 Internal Server Error` | Unexpected failure | Do not expose details |
| `502 Bad Gateway` | Gateway/proxy received an invalid upstream response | Not a catch-all for dependency failures; upstream timeouts use `504 Gateway Timeout` when acting as a gateway/proxy |
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
# GOOD: 400 for malformed requests; 400 or 422 for semantic validation per the API contract

# BAD: 200 for created resources
# GOOD: 201 Created with Location header
HTTP/1.1 201 Created
Location: /api/v1/users/abc-123
```
