# Pure Function Pattern — Example

Concise **Impure → Functional Core / Imperative Shell** refactoring showing explicit dependency injection (`now`, feature flags, pre-fetched state), typed Result discriminated union, error precedence, and imperative orchestration. Preserve the project's naming, result type, and test framework.

## Before (impure: hidden I/O, clock, global flag, thrown domain errors)

```typescript
import { db } from '../db'
import { featureFlags } from '../config/flags'

export async function applyPromoCode(code: string) {
  const promo = await db.promo.findFirst({ where: { code } }) // hidden I/O
  if (!promo) throw new Error('Promo not found')              // unchecked exception for expected case
  if (promo.expiresAt < new Date()) throw new Error('Expired') // non-deterministic clock
  return featureFlags.newPromoEngine ? promo.discountV2 : promo.discount // hidden global state
}
```

## After (Functional Core + Imperative Shell)

```typescript
export interface Promo {
  readonly code: string
  readonly discountCents: number
  readonly discountV2Cents: number
  readonly expiresAt: Date
}

export interface ApplyPromoInput {
  readonly promo: Promo | null
  readonly now: Date
  readonly useNewEngine: boolean
}

export type PromoError = 'PROMO_NOT_FOUND' | 'PROMO_EXPIRED'

export type PromoResult =
  | { readonly ok: true; readonly discountCents: number }
  | { readonly ok: false; readonly error: PromoError }

// Functional Core: deterministic, referentially transparent, explicit precedence
// Order: 1. existence -> 2. expiry -> 3. engine selection
export function applyPromoCode({ promo, now, useNewEngine }: ApplyPromoInput): PromoResult {
  if (promo === null) return { ok: false, error: 'PROMO_NOT_FOUND' }
  if (promo.expiresAt < now) return { ok: false, error: 'PROMO_EXPIRED' }

  return {
    ok: true,
    discountCents: useNewEngine ? promo.discountV2Cents : promo.discountCents,
  }
}

// Imperative Shell: owns I/O, clock, and config reads; delegates decision to the core
export async function applyPromoService(code: string): Promise<PromoResult> {
  const promo = await db.promo.findFirst({ where: { code } })
  return applyPromoCode({
    promo,
    now: new Date(),
    useNewEngine: featureFlags.newPromoEngine,
  })
}
```

## Focused behavior tests (Vitest / Jest style)

Test the public contract, boundary conditions, and error precedence directly — no mocks required.

```typescript
const NOW = new Date('2025-06-01T00:00:00Z')
const BASE_PROMO: Promo = {
  code: 'SAVE20',
  discountCents: 200,
  discountV2Cents: 250,
  expiresAt: new Date('2025-12-31T00:00:00Z'),
}

describe('applyPromoCode', () => {
  it('selects discount according to engine flag', () => {
    expect(applyPromoCode({ promo: BASE_PROMO, now: NOW, useNewEngine: false }))
      .toEqual({ ok: true, discountCents: 200 })
    expect(applyPromoCode({ promo: BASE_PROMO, now: NOW, useNewEngine: true }))
      .toEqual({ ok: true, discountCents: 250 })
  })

  it('returns PROMO_NOT_FOUND before checking expiry', () => {
    expect(applyPromoCode({ promo: null, now: NOW, useNewEngine: false }))
      .toEqual({ ok: false, error: 'PROMO_NOT_FOUND' })
  })

  it('rejects expired promo strictly past expiresAt', () => {
    const expired = { ...BASE_PROMO, expiresAt: new Date('2025-05-31T23:59:59Z') }
    expect(applyPromoCode({ promo: expired, now: NOW, useNewEngine: false }))
      .toEqual({ ok: false, error: 'PROMO_EXPIRED' })
  })
})
```
