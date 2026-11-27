# React Effect Refactoring Examples

Read only the rewrite matching the smell under review. Apply the invariants in [effect boundaries](effects.md); fewer effects alone is not the goal.

## 1. Derived state during render (eliminate effect waterfall)

```typescript
// Bad: cascading state sync causes extra renders and loop risk
function Cart({ subtotal }: { subtotal: number }) {
  const [tax, setTax] = useState(0)
  const [total, setTotal] = useState(0)
  useEffect(() => { setTax(subtotal * 0.1) }, [subtotal])
  useEffect(() => { setTotal(subtotal + tax) }, [subtotal, tax])
}

// Good: compute directly in the render pass (SSOT)
function Cart({ subtotal }: { subtotal: number }) {
  const tax = subtotal * 0.1
  const total = subtotal + tax
}
```

## 2. User-triggered work belongs in event handlers

```typescript
// Bad: boolean relay flag defers a user action to an effect
const [pendingLike, setPendingLike] = useState(false)
useEffect(() => {
  if (!pendingLike) return
  postLike()
  setPendingLike(false)
}, [pendingLike])

// Good: execute directly at the event boundary
<button onClick={() => postLike()}>Like</button>
```

## 3. Async fetch race cancellation (`AbortController`)

When no query layer exists, cancel in-flight requests in cleanup so an older slow response cannot overwrite a newer selection (also survives StrictMode double-invocation).

```typescript
function ProductDetail({ productId }: { productId: string }) {
  const [product, setProduct] = useState<Product | null>(null)

  useEffect(() => {
    const controller = new AbortController()

    fetchProduct(productId, { signal: controller.signal })
      .then(setProduct)
      .catch(error => {
        if (error instanceof DOMException && error.name === 'AbortError') return
        throw error
      })

    return () => controller.abort()
  }, [productId])
}
```

## 4. Reset local state on identity change with `key`

```typescript
// Remounts form state cleanly when userId changes (only when full subtree reset is intended)
function ProfileEditorPage({ userId }: { userId: string }) {
  return <ProfileForm key={userId} userId={userId} />
}
```

## 5. External mutable store (`useSyncExternalStore`)

Prefer `useSyncExternalStore` over `useEffect` + `useState` when subscribing to browser or non-React stores so concurrent renders cannot observe torn snapshots.

```typescript
function useOnlineStatus(): boolean {
  return useSyncExternalStore(
    onStoreChange => {
      window.addEventListener('online', onStoreChange)
      window.addEventListener('offline', onStoreChange)
      return () => {
        window.removeEventListener('online', onStoreChange)
        window.removeEventListener('offline', onStoreChange)
      }
    },
    () => navigator.onLine,
  )
}
```

## Smell checklist

- `useEffect(() => setDerived(...), [source])` — compute during render
- `setFlag(true)` followed by effect-driven work and `setFlag(false)` — move to event handler
- `useEffect` fetching without `AbortController` / `ignore` flag cleanup — stale-response race
- Custom empty-deps wrapper (`useMountEffect`) hiding reactive props/state — defeats `exhaustive-deps`
- Effect manually resetting several `useState` fields when an entity `id` prop changes — evaluate `key={id}`
