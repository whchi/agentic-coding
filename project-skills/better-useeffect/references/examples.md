# React Without Direct useEffect Examples

Use these examples when you need a concrete rewrite pattern.

## 1. Derive state during render

```typescript
// Bad: derived state is synchronized through an effect
function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);
  const [filteredProducts, setFilteredProducts] = useState<Product[]>([]);

  useEffect(() => {
    setFilteredProducts(products.filter((product) => product.inStock));
  }, [products]);
}

// Good: derive in the same render pass
function ProductList() {
  const [products, setProducts] = useState<Product[]>([]);
  const filteredProducts = products.filter((product) => product.inStock);
}
```

### Derived-state loop hazard

```typescript
// Bad: chained synchronized state increases loop risk
function Cart({ subtotal }: { subtotal: number }) {
  const [tax, setTax] = useState(0);
  const [total, setTotal] = useState(0);

  useEffect(() => {
    setTax(subtotal * 0.1);
  }, [subtotal]);

  useEffect(() => {
    setTotal(subtotal + tax);
  }, [subtotal, tax, total]);
}

// Good: compute directly from inputs
function Cart({ subtotal }: { subtotal: number }) {
  const tax = subtotal * 0.1;
  const total = subtotal + tax;
}
```

## 2. Use a query abstraction for fetching

```typescript
// Bad: component owns fetching lifecycle details
function ProductPage({ productId }: { productId: string }) {
  const [product, setProduct] = useState<Product | null>(null);

  useEffect(() => {
    fetchProduct(productId).then(setProduct);
  }, [productId]);
}

// Good: query library owns caching and async coordination
function ProductPage({ productId }: { productId: string }) {
  const { data: product } = useQuery({
    queryKey: ["product", productId],
    queryFn: () => fetchProduct(productId),
  });
}
```

## 3. Put user-triggered work in handlers

```typescript
// Bad: state flag relays an action to an effect
function LikeButton() {
  const [liked, setLiked] = useState(false);

  useEffect(() => {
    if (liked) {
      postLike();
      setLiked(false);
    }
  }, [liked]);

  return <button onClick={() => setLiked(true)}>Like</button>;
}

// Good: handler is the action boundary
function LikeButton() {
  return <button onClick={() => postLike()}>Like</button>;
}
```

## 4. Restrict mount-only external sync to `useMountEffect`

```typescript
function useMountEffect(callback: () => void | (() => void)) {
  useEffect(callback, []);
}
```

### Conditional mounting instead of guarding inside an effect

```typescript
// Bad: effect waits for props to become ready
function VideoPlayer({ isLoading }: { isLoading: boolean }) {
  useEffect(() => {
    if (!isLoading) {
      playVideo();
    }
  }, [isLoading]);
}

// Good: mount only when the component is actually ready
function VideoPlayerWrapper({ isLoading }: { isLoading: boolean }) {
  if (isLoading) {
    return <LoadingScreen />;
  }

  return <VideoPlayer />;
}

function VideoPlayer() {
  useMountEffect(() => playVideo());
}
```

### Persistent shell plus conditional instance

```typescript
function VideoPlayerInstance() {
  useMountEffect(() => playVideo());
}

function VideoPlayerContainer({ isLoading }: { isLoading: boolean }) {
  return (
    <>
      <VideoPlayerShell isLoading={isLoading} />
      {!isLoading && <VideoPlayerInstance />}
    </>
  );
}
```

## 5. Reset with `key`

```typescript
// Bad: effect tries to simulate remount behavior
function VideoPlayer({ videoId }: { videoId: string }) {
  useEffect(() => {
    loadVideo(videoId);
  }, [videoId]);
}

// Good: mount-only load plus parent-controlled remount
function VideoPlayer({ videoId }: { videoId: string }) {
  useMountEffect(() => {
    loadVideo(videoId);
  });
}

function VideoPlayerWrapper({ videoId }: { videoId: string }) {
  return <VideoPlayer key={videoId} videoId={videoId} />;
}
```

## Smell Checklist

Reach for this skill when you see code like:

- `useEffect(() => setX(...), [...])`
- `useEffect(() => { fetch(...).then(setState) }, [...])`
- `setFlag(true)` followed by effect-driven work and reset
- effect guards that wait for readiness flags
- effect-based resets when IDs or props change
