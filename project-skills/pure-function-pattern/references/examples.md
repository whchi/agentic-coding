# Pure Function Pattern — Examples

Full worked examples showing the complete module structure: types, helpers, main function, and tests.

## Table of Contents

1. [Coupon Validation](#coupon-validation) — discriminated union, time injection, usage limits
2. [Order Price Calculation](#order-price-calculation) — multi-step calculation, immutable accumulation
3. [Refactoring an Impure Function](#refactoring-an-impure-function) — before/after showing common violations

---

## Coupon Validation

A classic multi-rule validation with runtime dependencies injected as parameters.

### `validateCoupon.ts`

```typescript
// ── Types ────────────────────────────────────────────────────────────────────

export type CouponStatus = 'ACTIVE' | 'INACTIVE' | 'ARCHIVED'

export interface Coupon {
  id: string
  code: string
  status: CouponStatus
  validFrom: Date
  validUntil: Date | null
  maxUses: number | null
  totalUses: number
  maxUsesPerUser: number | null
  allowedProductIds: string[] | null  // null = unrestricted
}

export interface ValidateCouponInput {
  coupon: Coupon | null
  userId: string
  productId: string
  userCouponUses: number           // how many times this user has used this coupon
  now: Date                        // injected — never call Date.now() inside
  allowedProductLookup: Set<string> // precomputed — never build inside
}

export type CouponError =
  | 'COUPON_NOT_FOUND'
  | 'COUPON_INACTIVE'
  | 'COUPON_EXPIRED'
  | 'COUPON_NOT_YET_VALID'
  | 'COUPON_USAGE_LIMIT_REACHED'
  | 'COUPON_USER_LIMIT_REACHED'
  | 'COUPON_PRODUCT_NOT_ALLOWED'

export type CouponResult =
  | { ok: true; couponId: string }
  | { ok: false; error: CouponError }

// ── Helpers ──────────────────────────────────────────────────────────────────
// Each helper checks exactly one rule.
// Return shape is always { ok: true } | { ok: false; error: CouponError }.

function checkExists(coupon: Coupon | null): { ok: true; coupon: Coupon } | { ok: false; error: CouponError } {
  if (coupon === null) return { ok: false, error: 'COUPON_NOT_FOUND' }
  return { ok: true, coupon }
}

function checkStatus(coupon: Coupon): { ok: true } | { ok: false; error: CouponError } {
  if (coupon.status !== 'ACTIVE') return { ok: false, error: 'COUPON_INACTIVE' }
  return { ok: true }
}

function checkDateBounds(coupon: Coupon, now: Date): { ok: true } | { ok: false; error: CouponError } {
  if (now < coupon.validFrom) return { ok: false, error: 'COUPON_NOT_YET_VALID' }
  if (coupon.validUntil !== null && now > coupon.validUntil) return { ok: false, error: 'COUPON_EXPIRED' }
  return { ok: true }
}

function checkGlobalUsage(coupon: Coupon): { ok: true } | { ok: false; error: CouponError } {
  if (coupon.maxUses !== null && coupon.totalUses >= coupon.maxUses) {
    return { ok: false, error: 'COUPON_USAGE_LIMIT_REACHED' }
  }
  return { ok: true }
}

function checkUserUsage(coupon: Coupon, userCouponUses: number): { ok: true } | { ok: false; error: CouponError } {
  if (coupon.maxUsesPerUser !== null && userCouponUses >= coupon.maxUsesPerUser) {
    return { ok: false, error: 'COUPON_USER_LIMIT_REACHED' }
  }
  return { ok: true }
}

function checkProductAllowed(
  coupon: Coupon,
  productId: string,
  allowedProductLookup: Set<string>,
): { ok: true } | { ok: false; error: CouponError } {
  if (coupon.allowedProductIds !== null && !allowedProductLookup.has(productId)) {
    return { ok: false, error: 'COUPON_PRODUCT_NOT_ALLOWED' }
  }
  return { ok: true }
}

// ── Main pure function ────────────────────────────────────────────────────────
// Validation order:
//   1. existence → 2. status → 3. date bounds → 4. global limit
//   → 5. user limit → 6. product restriction
// Each step short-circuits on failure.

export function validateCoupon(input: ValidateCouponInput): CouponResult {
  const { coupon, userId: _userId, productId, userCouponUses, now, allowedProductLookup } = input

  const existsResult = checkExists(coupon)
  if (!existsResult.ok) return existsResult

  const activeCoupon = existsResult.coupon

  const statusResult = checkStatus(activeCoupon)
  if (!statusResult.ok) return statusResult

  const dateResult = checkDateBounds(activeCoupon, now)
  if (!dateResult.ok) return dateResult

  const globalResult = checkGlobalUsage(activeCoupon)
  if (!globalResult.ok) return globalResult

  const userResult = checkUserUsage(activeCoupon, userCouponUses)
  if (!userResult.ok) return userResult

  const productResult = checkProductAllowed(activeCoupon, productId, allowedProductLookup)
  if (!productResult.ok) return productResult

  return { ok: true, couponId: activeCoupon.id }
}
```

### `validateCoupon.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { validateCoupon, type Coupon, type ValidateCouponInput } from './validateCoupon'

// ── Factory helper ────────────────────────────────────────────────────────────
// Sensible defaults; override only what each test cares about.

const NOW = new Date('2024-06-01T12:00:00Z')

function makeCoupon(overrides: Partial<Coupon> = {}): Coupon {
  return {
    id: 'coupon-1',
    code: 'SAVE10',
    status: 'ACTIVE',
    validFrom: new Date('2024-01-01'),
    validUntil: new Date('2024-12-31'),
    maxUses: null,
    totalUses: 0,
    maxUsesPerUser: null,
    allowedProductIds: null,
    ...overrides,
  }
}

function makeInput(overrides: Partial<ValidateCouponInput> = {}): ValidateCouponInput {
  return {
    coupon: makeCoupon(),
    userId: 'user-1',
    productId: 'product-1',
    userCouponUses: 0,
    now: NOW,
    allowedProductLookup: new Set(),
    ...overrides,
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

describe('validateCoupon', () => {
  it('returns ok for a fully valid coupon', () => {
    expect(validateCoupon(makeInput())).toEqual({ ok: true, couponId: 'coupon-1' })
  })

  it('returns COUPON_NOT_FOUND when coupon is null', () => {
    expect(validateCoupon(makeInput({ coupon: null }))).toEqual({
      ok: false,
      error: 'COUPON_NOT_FOUND',
    })
  })

  it('returns COUPON_INACTIVE when status is not ACTIVE', () => {
    expect(validateCoupon(makeInput({ coupon: makeCoupon({ status: 'ARCHIVED' }) }))).toEqual({
      ok: false,
      error: 'COUPON_INACTIVE',
    })
  })

  it('returns COUPON_NOT_YET_VALID when now is before validFrom', () => {
    const coupon = makeCoupon({ validFrom: new Date('2025-01-01') })
    expect(validateCoupon(makeInput({ coupon, now: new Date('2024-01-01') }))).toEqual({
      ok: false,
      error: 'COUPON_NOT_YET_VALID',
    })
  })

  it('returns COUPON_EXPIRED when now is after validUntil', () => {
    const coupon = makeCoupon({ validUntil: new Date('2024-01-01') })
    expect(validateCoupon(makeInput({ coupon, now: new Date('2024-06-01') }))).toEqual({
      ok: false,
      error: 'COUPON_EXPIRED',
    })
  })

  it('returns ok when validUntil is null (no expiry)', () => {
    const coupon = makeCoupon({ validUntil: null, validFrom: new Date('2024-01-01') })
    expect(validateCoupon(makeInput({ coupon, now: new Date('2099-01-01') }))).toEqual({
      ok: true,
      couponId: 'coupon-1',
    })
  })

  it('returns COUPON_USAGE_LIMIT_REACHED when global cap is hit', () => {
    const coupon = makeCoupon({ maxUses: 100, totalUses: 100 })
    expect(validateCoupon(makeInput({ coupon }))).toEqual({
      ok: false,
      error: 'COUPON_USAGE_LIMIT_REACHED',
    })
  })

  it('returns ok when one use remains globally', () => {
    const coupon = makeCoupon({ maxUses: 100, totalUses: 99 })
    expect(validateCoupon(makeInput({ coupon }))).toEqual({ ok: true, couponId: 'coupon-1' })
  })

  it('returns COUPON_USER_LIMIT_REACHED when per-user cap is hit', () => {
    const coupon = makeCoupon({ maxUsesPerUser: 3 })
    expect(validateCoupon(makeInput({ coupon, userCouponUses: 3 }))).toEqual({
      ok: false,
      error: 'COUPON_USER_LIMIT_REACHED',
    })
  })

  it('returns COUPON_PRODUCT_NOT_ALLOWED when product is not in the allowed list', () => {
    const coupon = makeCoupon({ allowedProductIds: ['product-A', 'product-B'] })
    const lookup = new Set(['product-A', 'product-B'])
    expect(
      validateCoupon(makeInput({ coupon, productId: 'product-C', allowedProductLookup: lookup })),
    ).toEqual({ ok: false, error: 'COUPON_PRODUCT_NOT_ALLOWED' })
  })

  it('returns ok when product is in the allowed list', () => {
    const coupon = makeCoupon({ allowedProductIds: ['product-A'] })
    const lookup = new Set(['product-A'])
    expect(
      validateCoupon(makeInput({ coupon, productId: 'product-A', allowedProductLookup: lookup })),
    ).toEqual({ ok: true, couponId: 'coupon-1' })
  })

  it('returns ok when allowedProductIds is null (unrestricted)', () => {
    const coupon = makeCoupon({ allowedProductIds: null })
    expect(validateCoupon(makeInput({ coupon, allowedProductLookup: new Set() }))).toEqual({
      ok: true,
      couponId: 'coupon-1',
    })
  })

  describe('order of checks', () => {
    it('returns COUPON_NOT_FOUND before COUPON_INACTIVE', () => {
      // Both conditions are true — first check wins
      expect(validateCoupon(makeInput({ coupon: null }))).toEqual({
        ok: false,
        error: 'COUPON_NOT_FOUND',
      })
    })

    it('returns COUPON_INACTIVE before date checks', () => {
      const coupon = makeCoupon({
        status: 'INACTIVE',
        validFrom: new Date('2025-01-01'), // also not-yet-valid
      })
      expect(validateCoupon(makeInput({ coupon }))).toEqual({
        ok: false,
        error: 'COUPON_INACTIVE',
      })
    })
  })
})
```

---

## Order Price Calculation

Shows immutable accumulation and multi-step calculation without any I/O.

### `calculateOrderPrice.ts`

```typescript
// ── Types ────────────────────────────────────────────────────────────────────

export interface OrderItem {
  productId: string
  unitPrice: number   // in cents
  quantity: number
}

export interface DiscountRule {
  type: 'PERCENTAGE' | 'FIXED'
  value: number   // percentage (0–100) or fixed cents
  minOrderTotal: number | null  // minimum pre-discount total to qualify
}

export interface CalculateOrderPriceInput {
  items: OrderItem[]
  discounts: DiscountRule[]
  taxRatePercent: number  // e.g. 8.5 for 8.5%
}

export interface OrderPriceBreakdown {
  subtotal: number       // sum of item totals, in cents
  discountTotal: number  // total discount applied, in cents
  taxableAmount: number  // subtotal - discountTotal
  tax: number            // in cents, rounded down
  total: number          // taxableAmount + tax
}

export type OrderPriceResult =
  | { ok: true; breakdown: OrderPriceBreakdown }
  | { ok: false; error: 'INVALID_ITEM' | 'NEGATIVE_DISCOUNT' | 'INVALID_TAX_RATE' }

// ── Helpers ──────────────────────────────────────────────────────────────────

function calculateSubtotal(items: OrderItem[]): { ok: true; subtotal: number } | { ok: false; error: 'INVALID_ITEM' } {
  for (const item of items) {
    if (item.unitPrice < 0 || item.quantity <= 0) return { ok: false, error: 'INVALID_ITEM' }
  }
  const subtotal = items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0)
  return { ok: true, subtotal }
}

function applyDiscount(subtotal: number, rule: DiscountRule): number {
  if (rule.minOrderTotal !== null && subtotal < rule.minOrderTotal) return 0
  if (rule.type === 'PERCENTAGE') return Math.floor(subtotal * (rule.value / 100))
  return Math.min(rule.value, subtotal) // fixed discount cannot exceed subtotal
}

function calculateDiscountTotal(
  subtotal: number,
  discounts: DiscountRule[],
): { ok: true; discountTotal: number } | { ok: false; error: 'NEGATIVE_DISCOUNT' } {
  let total = 0
  for (const rule of discounts) {
    if (rule.value < 0) return { ok: false, error: 'NEGATIVE_DISCOUNT' }
    total += applyDiscount(subtotal, rule)
  }
  return { ok: true, discountTotal: Math.min(total, subtotal) }
}

function calculateTax(
  taxableAmount: number,
  taxRatePercent: number,
): { ok: true; tax: number } | { ok: false; error: 'INVALID_TAX_RATE' } {
  if (taxRatePercent < 0 || taxRatePercent > 100) return { ok: false, error: 'INVALID_TAX_RATE' }
  return { ok: true, tax: Math.floor(taxableAmount * (taxRatePercent / 100)) }
}

// ── Main pure function ────────────────────────────────────────────────────────
// Calculation order:
//   1. validate items + compute subtotal
//   2. apply discounts (capped at subtotal)
//   3. compute tax on taxable amount
//   4. sum total

export function calculateOrderPrice(input: CalculateOrderPriceInput): OrderPriceResult {
  const subtotalResult = calculateSubtotal(input.items)
  if (!subtotalResult.ok) return subtotalResult

  const { subtotal } = subtotalResult

  const discountResult = calculateDiscountTotal(subtotal, input.discounts)
  if (!discountResult.ok) return discountResult

  const { discountTotal } = discountResult
  const taxableAmount = subtotal - discountTotal

  const taxResult = calculateTax(taxableAmount, input.taxRatePercent)
  if (!taxResult.ok) return taxResult

  const { tax } = taxResult

  return {
    ok: true,
    breakdown: {
      subtotal,
      discountTotal,
      taxableAmount,
      tax,
      total: taxableAmount + tax,
    },
  }
}
```

### `calculateOrderPrice.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { calculateOrderPrice, type OrderItem, type DiscountRule } from './calculateOrderPrice'

function makeItems(overrides: Partial<OrderItem>[] = []): OrderItem[] {
  return overrides.map(o => ({ productId: 'p1', unitPrice: 1000, quantity: 1, ...o }))
}

describe('calculateOrderPrice', () => {
  it('calculates a simple order with no discounts', () => {
    const result = calculateOrderPrice({
      items: makeItems([{ unitPrice: 500, quantity: 2 }]),
      discounts: [],
      taxRatePercent: 10,
    })
    expect(result).toEqual({
      ok: true,
      breakdown: {
        subtotal: 1000,
        discountTotal: 0,
        taxableAmount: 1000,
        tax: 100,
        total: 1100,
      },
    })
  })

  it('applies a percentage discount', () => {
    const discount: DiscountRule = { type: 'PERCENTAGE', value: 20, minOrderTotal: null }
    const result = calculateOrderPrice({
      items: makeItems([{ unitPrice: 1000, quantity: 1 }]),
      discounts: [discount],
      taxRatePercent: 0,
    })
    expect(result).toEqual({
      ok: true,
      breakdown: { subtotal: 1000, discountTotal: 200, taxableAmount: 800, tax: 0, total: 800 },
    })
  })

  it('skips discount when order total is below minOrderTotal', () => {
    const discount: DiscountRule = { type: 'FIXED', value: 500, minOrderTotal: 2000 }
    const result = calculateOrderPrice({
      items: makeItems([{ unitPrice: 1000, quantity: 1 }]),
      discounts: [discount],
      taxRatePercent: 0,
    })
    expect(result).toEqual({
      ok: true,
      breakdown: { subtotal: 1000, discountTotal: 0, taxableAmount: 1000, tax: 0, total: 1000 },
    })
  })

  it('caps discount total at subtotal (cannot go negative)', () => {
    const discount: DiscountRule = { type: 'FIXED', value: 9999, minOrderTotal: null }
    const result = calculateOrderPrice({
      items: makeItems([{ unitPrice: 500, quantity: 1 }]),
      discounts: [discount],
      taxRatePercent: 0,
    })
    expect(result).toEqual({
      ok: true,
      breakdown: { subtotal: 500, discountTotal: 500, taxableAmount: 0, tax: 0, total: 0 },
    })
  })

  it('returns INVALID_ITEM when unitPrice is negative', () => {
    expect(
      calculateOrderPrice({
        items: makeItems([{ unitPrice: -100 }]),
        discounts: [],
        taxRatePercent: 10,
      }),
    ).toEqual({ ok: false, error: 'INVALID_ITEM' })
  })

  it('returns INVALID_ITEM when quantity is zero', () => {
    expect(
      calculateOrderPrice({
        items: makeItems([{ quantity: 0 }]),
        discounts: [],
        taxRatePercent: 10,
      }),
    ).toEqual({ ok: false, error: 'INVALID_ITEM' })
  })

  it('returns NEGATIVE_DISCOUNT when a discount rule has a negative value', () => {
    const discount: DiscountRule = { type: 'FIXED', value: -50, minOrderTotal: null }
    expect(
      calculateOrderPrice({ items: makeItems(), discounts: [discount], taxRatePercent: 0 }),
    ).toEqual({ ok: false, error: 'NEGATIVE_DISCOUNT' })
  })

  it('returns INVALID_TAX_RATE when tax rate exceeds 100', () => {
    expect(
      calculateOrderPrice({ items: makeItems(), discounts: [], taxRatePercent: 101 }),
    ).toEqual({ ok: false, error: 'INVALID_TAX_RATE' })
  })
})
```

---

## Refactoring an Impure Function

Shows common violations and how to fix each one.

### Before (impure)

```typescript
// ❌ Multiple purity violations

import { db } from '../db'                          // hidden I/O dependency
import { featureFlags } from '../config/flags'      // hidden global state

export async function applyPromoCode(code: string, userId: string) {
  const promo = await db.promo.findFirst({ where: { code } })  // I/O inside function

  if (!promo) throw new Error('Promo not found')               // throws for expected case

  const now = new Date()                                        // non-deterministic
  if (promo.expiresAt < now) throw new Error('Promo expired')  // throws for expected case

  if (featureFlags.newPromoEngine) {                            // reads hidden global state
    return promo.discountV2
  }

  return promo.discount
}
```

### After (pure)

```typescript
// ✅ All violations resolved

// ── Types ────────────────────────────────────────────────────────────────────

export interface Promo {
  code: string
  discount: number
  discountV2: number
  expiresAt: Date
}

export interface ApplyPromoInput {
  promo: Promo | null       // caller fetches from DB, passes result in
  now: Date                 // injected — deterministic
  useNewEngine: boolean     // injected — no hidden flag reads
}

export type PromoError = 'PROMO_NOT_FOUND' | 'PROMO_EXPIRED'

export type PromoResult =
  | { ok: true; discount: number }
  | { ok: false; error: PromoError }

// ── Pure function ─────────────────────────────────────────────────────────────

export function applyPromoCode(input: ApplyPromoInput): PromoResult {
  if (input.promo === null) return { ok: false, error: 'PROMO_NOT_FOUND' }
  if (input.promo.expiresAt < input.now) return { ok: false, error: 'PROMO_EXPIRED' }

  const discount = input.useNewEngine ? input.promo.discountV2 : input.promo.discount
  return { ok: true, discount }
}

// ── The caller (service layer) now owns the I/O ───────────────────────────────
//
// async function applyPromoService(code: string, userId: string) {
//   const promo = await db.promo.findFirst({ where: { code } })
//   return applyPromoCode({
//     promo,
//     now: new Date(),
//     useNewEngine: featureFlags.newPromoEngine,
//   })
// }
```

### `applyPromoCode.test.ts`

```typescript
import { describe, it, expect } from 'vitest'
import { applyPromoCode, type Promo } from './applyPromoCode'

const VALID_PROMO: Promo = {
  code: 'SUMMER20',
  discount: 200,
  discountV2: 250,
  expiresAt: new Date('2099-01-01'),
}

const NOW = new Date('2024-06-01')

describe('applyPromoCode', () => {
  it('returns ok with discount using old engine', () => {
    expect(applyPromoCode({ promo: VALID_PROMO, now: NOW, useNewEngine: false })).toEqual({
      ok: true,
      discount: 200,
    })
  })

  it('returns ok with discountV2 using new engine', () => {
    expect(applyPromoCode({ promo: VALID_PROMO, now: NOW, useNewEngine: true })).toEqual({
      ok: true,
      discount: 250,
    })
  })

  it('returns PROMO_NOT_FOUND when promo is null', () => {
    expect(applyPromoCode({ promo: null, now: NOW, useNewEngine: false })).toEqual({
      ok: false,
      error: 'PROMO_NOT_FOUND',
    })
  })

  it('returns PROMO_EXPIRED when expiresAt is in the past', () => {
    const expired = { ...VALID_PROMO, expiresAt: new Date('2020-01-01') }
    expect(applyPromoCode({ promo: expired, now: NOW, useNewEngine: false })).toEqual({
      ok: false,
      error: 'PROMO_EXPIRED',
    })
  })
})
```
