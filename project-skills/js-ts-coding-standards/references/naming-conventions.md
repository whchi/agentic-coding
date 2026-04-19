# Naming Conventions

Variable, function, and file naming standards.

## Variable Naming

```typescript
// ✅ GOOD: Descriptive names
const marketSearchQuery = 'election'
const isUserAuthenticated = true
const totalRevenue = 1000
const hasCompletedOnboarding = false
const canDeleteResource = true

// ❌ BAD: Unclear names
const q = 'election'
const flag = true
const x = 1000
const temp = false
const val = true
```

### Naming Patterns

| Type | Pattern | Example |
|------|---------|---------|
| Boolean | `is*`, `has*`, `can*`, `should*` | `isActive`, `hasPermission`, `canEdit` |
| Number | `*Count`, `*Index`, `*Total` | `itemCount`, `currentIndex`, `totalPrice` |
| Array | Plural nouns | `users`, `markets`, `items` |
| Object | Singular nouns | `user`, `market`, `config` |
| Function | Verb-noun | `fetchUsers`, `calculateTotal`, `validateInput` |

## Function Naming

```typescript
// ✅ GOOD: Verb-noun pattern
async function fetchMarketData(marketId: string) { }
function calculateSimilarity(a: number[], b: number[]) { }
function isValidEmail(email: string): boolean { }
function formatUserName(user: User): string { }
function transformApiResponse(data: unknown): Market[] { }

// ❌ BAD: Unclear or noun-only
async function market(id: string) { }
function similarity(a, b) { }
function email(e) { }
```

### Verb Prefixes

| Prefix | Use Case |
|--------|----------|
| `get*` | Retrieve data (sync) |
| `fetch*` | Retrieve data (async) |
| `calculate*` | Compute derived value |
| `is*`, `has*`, `can*` | Return boolean |
| `validate*` | Check and throw/return result |
| `format*`, `parse*` | Transform data |
| `create*`, `make*` | Construct new instance |
| `update*`, `set*` | Modify existing |
| `delete*`, `remove*` | Remove |
| `handle*` | Event handler |

## File Naming

```
components/Button.tsx          # PascalCase for components
components/MarketCard.tsx     # PascalCase for components
hooks/useAuth.ts               # camelCase with 'use' prefix
hooks/useDebounce.ts           # camelCase with 'use' prefix
lib/formatDate.ts             # camelCase for utilities
lib/api-client.ts              # kebab-case for multi-word
types/market.types.ts          # camelCase with .types suffix
types/api.types.ts             # camelCase with .types suffix
services/market-service.ts     # kebab-case for services
utils/string-utils.ts          # kebab-case for utilities
```

## Interface and Type Naming

```typescript
// ✅ GOOD: Descriptive names, no redundant prefixes
interface User {
  id: string
  name: string
  email: string
}

interface Market {
  id: string
  name: string
  status: 'active' | 'resolved' | 'closed'
}

type MarketStatus = 'active' | 'resolved' | 'closed'
type ApiResponse<T> = {
  data: T
  error?: string
}

// ❌ BAD: Redundant prefixes
interface IUser { }      // No 'I' prefix needed
type TMarket = { }       // No 'T' prefix needed
```

## Constants

```typescript
// ✅ GOOD: SCREAMING_SNAKE_CASE for true constants
const MAX_RETRIES = 3
const DEBOUNCE_DELAY_MS = 500
const API_BASE_URL = 'https://api.example.com'

// ✅ GOOD: camelCase for runtime constants
const defaultConfig = {
  timeout: 5000,
  retries: 3
}

// ❌ BAD: SCREAMING_SNAKE_CASE for non-constants
const USER_INPUT = getUserInput()  // This is a variable, not a constant
```