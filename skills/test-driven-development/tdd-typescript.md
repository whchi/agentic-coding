---
name: tdd-typescript
description: TypeScript and JavaScript specific test patterns, commands, and examples. Always used together with `/test-driven-development` base skill.
---

# TDD — TypeScript / JavaScript
> **Before proceeding, read `.config/opencode/test-driven-development/SKILL.md` first.**
> Read the base skill first for TDD philosophy and cycle.

---

## Commands

```bash
# Run a single test file
npx jest path/to/file.test.ts
npx vitest run path/to/file.test.ts

# Run full suite
npm test

# Watch mode during development
npm test -- --watch

# Coverage report
npm run test:coverage
```

---

## Coverage Config

```json
{
  "jest": {
    "coverageThresholds": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

---

## Test Types

### Unit Test (Jest / Vitest)

```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)
    fireEvent.click(screen.getByRole('button'))
    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### Integration Test (API Route)

```typescript
import { NextRequest } from 'next/server'
import { GET } from './route'

describe('GET /api/markets', () => {
  it('returns markets successfully', async () => {
    const request = new NextRequest('http://localhost/api/markets')
    const response = await GET(request)
    const data = await response.json()

    expect(response.status).toBe(200)
    expect(data.success).toBe(true)
    expect(Array.isArray(data.data)).toBe(true)
  })

  it('rejects invalid query params', async () => {
    const request = new NextRequest('http://localhost/api/markets?limit=invalid')
    const response = await GET(request)
    expect(response.status).toBe(400)
  })

  it('handles database errors gracefully', async () => {
    // Mock DB failure, assert graceful error response
  })
})
```

### E2E Test (Playwright)

```typescript
import { test, expect } from '@playwright/test'

test('user can search and filter markets', async ({ page }) => {
  await page.goto('/markets')
  await expect(page.locator('h1')).toContainText('Markets')

  await page.fill('input[placeholder="Search markets"]', 'election')
  await page.waitForTimeout(600) // debounce

  const results = page.locator('[data-testid="market-card"]')
  await expect(results).toHaveCount(5, { timeout: 5000 })
  await expect(results.first()).toContainText('election', { ignoreCase: true })

  await page.click('button:has-text("Active")')
  await expect(results).toHaveCount(3)
})
```

---

## Mocking External Services

### Supabase
```typescript
jest.mock('@/lib/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() => Promise.resolve({
          data: [{ id: 1, name: 'Test Market' }],
          error: null
        }))
      }))
    }))
  }
}))
```

### Redis
```typescript
jest.mock('@/lib/redis', () => ({
  searchMarketsByVector: jest.fn(() => Promise.resolve([
    { slug: 'test-market', similarity_score: 0.95 }
  ])),
  checkRedisHealth: jest.fn(() => Promise.resolve({ connected: true }))
}))
```

### OpenAI
```typescript
jest.mock('@/lib/openai', () => ({
  generateEmbedding: jest.fn(() => Promise.resolve(
    new Array(1536).fill(0.1)
  ))
}))
```

---

## Anti-Patterns

**Don't test implementation details:**
```typescript
// ❌ Internal state
expect(component.state.count).toBe(5)

// ✅ User-visible behavior
expect(screen.getByText('Count: 5')).toBeInTheDocument()
```

**Don't use brittle selectors:**
```typescript
// ❌
await page.click('.css-xyz-123')

// ✅
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

**Don't share state between tests:**
```typescript
// ❌ Tests depend on each other
test('creates user', () => { ... })
test('updates same user', () => { ... }) // depends on above

// ✅ Each test is self-contained
test('updates user', () => {
  const user = createTestUser()
  // ...
})
```

---

## File Organization

```
src/
├── components/
│   └── Button/
│       ├── Button.tsx
│       └── Button.test.tsx       # Unit tests
├── app/
│   └── api/
│       └── markets/
│           ├── route.ts
│           └── route.test.ts     # Integration tests
└── e2e/
    ├── markets.spec.ts           # E2E tests
    └── auth.spec.ts
```

---

## CI/CD

```yaml
# GitHub Actions
- name: Run Tests
  run: npm test -- --coverage
- name: Upload Coverage
  uses: codecov/codecov-action@v3
```
