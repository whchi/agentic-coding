---
name: tdd-typescript
description: Use when applying TDD in TypeScript or JavaScript projects and choosing test commands, framework patterns, fixtures, mocks, or coverage configuration.
---

# TDD — TypeScript / JavaScript

Read `SKILL.md` first for the TDD philosophy and cycle. This file only covers TypeScript/JavaScript commands and examples.

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

# Coverage report, if configured by the project
npm run test:coverage
```

---

## Coverage Config

Example coverage gate when the project chooses an 80% threshold:

```json
{
  "jest": {
    "coverageThreshold": {
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
  await expect(page.getByRole('heading', { name: /markets/i })).toBeVisible()

  await page.getByRole('textbox', { name: /search/i }).fill('election')

  const results = page.getByTestId('market-card')
  await expect(results.first()).toContainText(/election/i)

  await page.getByRole('button', { name: /active/i }).click()
  await expect(results).toHaveCount(3)
})
```

---

## Mocking External Services

Prefer real code with fake boundaries over deep module mocks. Before adding mocks, read `testing-anti-patterns.md`.

```typescript
interface EmailClient {
  sendWelcomeEmail(email: string): Promise<void>
}

class FakeEmailClient implements EmailClient {
  sentTo: string[] = []

  async sendWelcomeEmail(email: string) {
    this.sentTo.push(email)
  }
}

test('sends welcome email after signup', async () => {
  const emailClient = new FakeEmailClient()
  const service = new SignupService({ emailClient })

  await service.signup({ email: 'alice@example.com' })

  expect(emailClient.sentTo).toEqual(['alice@example.com'])
})
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
    ├── markets.spec.ts           # E2E tests, when the project has browser coverage
    └── auth.spec.ts
```

---

## CI/CD

Project CI owns exact commands. The TDD requirement is that CI runs the relevant test suite and any configured coverage gate.
