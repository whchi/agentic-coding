# Testing Standards

Test structure, naming, and best practices.

## Test Structure (AAA Pattern)

```typescript
test('calculates similarity correctly', () => {
  // Arrange
  const vector1 = [1, 0, 0]
  const vector2 = [0, 1, 0]

  // Act
  const similarity = calculateCosineSimilarity(vector1, vector2)

  // Assert
  expect(similarity).toBe(0)
})

test('fetches user by ID', async () => {
  // Arrange
  const mockUser = { id: '123', name: 'Test User' }
  mockFetch.mockResolvedValue({ json: () => mockUser })

  // Act
  const result = await fetchUser('123')

  // Assert
  expect(result).toEqual(mockUser)
  expect(mockFetch).toHaveBeenCalledWith('/api/users/123')
})
```

## Test Naming

```typescript
// ✅ GOOD: Descriptive, behavior-focused
test('returns empty array when no markets match query', () => { })
test('throws error when OpenAI API key is missing', () => { })
test('falls back to substring search when Redis unavailable', () => { })
test('sorts results by similarity score descending', () => { })
test('limits results to specified count', () => { })

// ❌ BAD: Vague, implementation-focused
test('works', () => { })
test('test search', () => { })
test('tests the function', () => { })
test('valid input', () => { })
```

### Naming Patterns

| Test Type | Pattern | Example |
|-----------|---------|---------|
| Success case | `returns {expected} when {condition}` | `returns user when ID exists` |
| Error case | `throws {error} when {condition}` | `throws Error when ID is empty` |
| Edge case | `handles {edge case}` | `handles empty array` |
| Integration | `integrates with {system}` | `integrates with Stripe API` |

## Test Organization

```
tests/
├── unit/
│   ├── utils/
│   │   ├── formatDate.test.ts
│   │   └── calculateSimilarity.test.ts
│   └── hooks/
│       ├── useDebounce.test.ts
│       └── useAuth.test.ts
├── integration/
│   ├── api/
│   │   ├── markets.test.ts
│   │   └── users.test.ts
│   └── services/
│       └── search.test.ts
└── e2e/
    ├── market-creation.spec.ts
    └── user-flow.spec.ts
```

## Mocking

### Function Mocks

```typescript
// Simple mock
const mockFetch = jest.fn()
mockFetch.mockResolvedValue({ data: 'test' })

// Mock with implementation
const mockCalculate = jest.fn((a, b) => a + b)

// Spy on existing function
jest.spyOn(console, 'error').mockImplementation(() => {})

// Mock return value once
mockFetch
  .mockResolvedValueOnce({ data: 'first' })
  .mockResolvedValueOnce({ data: 'second' })
```

### Module Mocks

```typescript
// Mock entire module
jest.mock('@/lib/api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: '123' })
}))

// Mock with factory
jest.mock('@/lib/database', () => ({
  db: {
    query: jest.fn()
  }
}))
```

### Timer Mocks

```typescript
beforeEach(() => {
  jest.useFakeTimers()
})

afterEach(() => {
  jest.useRealTimers()
})

test('debounce waits for delay', () => {
  const callback = jest.fn()
  const debounced = debounce(callback, 500)

  debounced()
  expect(callback).not.toHaveBeenCalled()

  jest.advanceTimersByTime(500)
  expect(callback).toHaveBeenCalled()
})
```

## Async Testing

```typescript
// Promises
test('resolves with data', async () => {
  await expect(fetchUser('123')).resolves.toEqual({ id: '123' })
})

// Rejections
test('rejects on error', async () => {
  await expect(fetchUser('invalid')).rejects.toThrow('User not found')
})

// Async/await
test('handles async operation', async () => {
  const result = await fetchMarkets()
  expect(result).toHaveLength(10)
})

// Wait for condition
test('waits for element', async () => {
  render(<Component />)
  await screen.findByText('Loaded')
  expect(screen.getByText('Loaded')).toBeInTheDocument()
})
```

## Test Data

### Fixtures

```typescript
// tests/fixtures/user.ts
export const mockUser = {
  id: 'user-123',
  name: 'Test User',
  email: 'test@example.com'
}

export const mockAdmin = {
  ...mockUser,
  role: 'admin'
}

// Usage
import { mockUser, mockAdmin } from '../fixtures/user'
```

### Factories

```typescript
// tests/factories/market.ts
export function createMarket(overrides = {}) {
  return {
    id: 'market-123',
    name: 'Test Market',
    status: 'active',
    ...overrides
  }
}

// Usage
const market = createMarket({ status: 'resolved' })
```

## Coverage

```typescript
// Jest coverage thresholds
// jest.config.js
module.exports = {
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80
    }
  }
}

// Run with coverage
// npm test -- --coverage
```