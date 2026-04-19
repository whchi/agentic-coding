# API Design

REST conventions, validation, and response standards.

## REST Conventions

### Endpoints

```
GET    /api/markets              # List all markets
GET    /api/markets/:id          # Get specific market
POST   /api/markets              # Create new market
PUT    /api/markets/:id          # Update market (full replacement)
PATCH  /api/markets/:id          # Update market (partial)
DELETE /api/markets/:id          # Delete market

# Query parameters for filtering
GET /api/markets?status=active&limit=10&offset=0
GET /api/markets?sort=-created_at&filter[status]=active
```

### Resource Naming

```
# ✅ GOOD: Plural nouns, kebab-case
/api/user-preferences
/api/market-resolutions
/api/OrderItems          # ❌ PascalCase
/api/order_items         # ❌ snake_case
/api/order-item          # ❌ Singular

# ✅ GOOD: Nested resources
/api/users/:id/orders
/api/markets/:id/resolutions

# ❌ BAD: Verbs in URLs
/api/getUser
/api/createMarket
/api/deleteOrder
```

## Response Format

### Standard Structure

```typescript
interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  meta?: {
    total: number
    page: number
    limit: number
  }
}

// Success response
return NextResponse.json({
  success: true,
  data: markets,
  meta: { total: 100, page: 1, limit: 10 }
})

// Error response
return NextResponse.json({
  success: false,
  error: 'Invalid request'
}, { status: 400 })

// Validation error with details
return NextResponse.json({
  success: false,
  error: 'Validation failed',
  details: [
    { field: 'name', message: 'Name is required' },
    { field: 'email', message: 'Invalid email format' }
  ]
}, { status: 400 })
```

### Status Codes

| Code | Use When |
|------|----------|
| 200 | Success (GET, PUT, PATCH) |
| 201 | Created (POST) |
| 204 | No content (DELETE) |
| 400 | Bad request, validation error |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable entity |
| 429 | Rate limit exceeded |
| 500 | Server error |

## Input Validation

### Zod Schema

```typescript
import { z } from 'zod'

const CreateMarketSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1).max(2000),
  endDate: z.string().datetime(),
  categories: z.array(z.string()).min(1),
  resolutionCriteria: z.string().min(10)
})

// In handler
export async function POST(request: Request) {
  const body = await request.json()

  try {
    const validated = CreateMarketSchema.parse(body)
    // Proceed with validated data
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({
        success: false,
        error: 'Validation failed',
        details: error.errors.map(e => ({
          field: e.path.join('.'),
          message: e.message
        }))
      }, { status: 400 })
    }
  }
}
```

### Common Validation Patterns

```typescript
//ID validation
z.string().uuid()
z.string().regex(/^[a-z0-9]+$/)

// Email
z.string().email()

// Date
z.string().datetime()
z.string().date()

// Enum
z.enum(['active', 'resolved', 'closed'])

// Optional
z.string().optional()
z.string().nullable()

// Transform
z.string().transform(s => s.toLowerCase())
z.string().transform(s => s.trim())
```

## Error Handling

### API Error Class

```typescript
class ApiError extends Error {
  constructor(
    public message: string,
    public statusCode: number = 500,
    public code?: string
  ) {
    super(message)
  }
}

// Usage
if (!user) {
  throw new ApiError('User not found', 404, 'USER_NOT_FOUND')
}

// Error handler middleware
export function handleError(error: unknown) {
  if (error instanceof ApiError) {
    return NextResponse.json({
      success: false,
      error: error.message,
      code: error.code
    }, { status: error.statusCode })
  }

  console.error('Unexpected error:', error)
  return NextResponse.json({
    success: false,
    error: 'Internal server error'
  }, { status: 500 })
}
```