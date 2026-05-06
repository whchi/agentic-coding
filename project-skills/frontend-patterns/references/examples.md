# Frontend Patterns Examples

Code examples for patterns described in SKILL.md. Keep examples when they fix project style or show APIs the model may get wrong; do not include outdated patterns only because they are familiar.

## Component Patterns

### Composition

```typescript
interface CardProps {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}

export function Card({ children, variant = 'default' }: CardProps) {
  return <div className={`card card-${variant}`}>{children}</div>
}

export function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>
}

export function CardBody({ children }: { children: React.ReactNode }) {
  return <div className="card-body">{children}</div>
}
```

### Compound Components

```typescript
interface TabsContextValue {
  activeTab: string
  setActiveTab: (tab: string) => void
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined)

export function Tabs({ children, defaultTab }: {
  children: React.ReactNode
  defaultTab: string
}) {
  const [activeTab, setActiveTab] = useState(defaultTab)

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {children}
    </TabsContext.Provider>
  )
}

export function Tab({ id, children }: { id: string, children: React.ReactNode }) {
  const context = useContext(TabsContext)
  if (!context) throw new Error('Tab must be used within Tabs')

  return (
    <button className={context.activeTab === id ? 'active' : ''} onClick={() => context.setActiveTab(id)}>
      {children}
    </button>
  )
}
```

## Custom Hooks

### useToggle

Use tiny custom hooks to standardize repeated UI state. Do not add `useCallback` by default unless the project expects stable function identities for this hook.

```typescript
export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue)

  const toggle = () => setValue(current => !current)
  const setTrue = () => setValue(true)
  const setFalse = () => setValue(false)

  return { value, toggle, setTrue, setFalse, setValue }
}
```

### useDebounce

Keep debouncing as value transformation. Trigger user actions from handlers or query abstractions, not from a second effect that watches the debounced value.

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedValue(value), delay)
    return () => window.clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

const debouncedQuery = useDebounce(searchQuery, 300)
```

## State Management

### Context + Reducer

Use this for deep-tree client state with related transitions. Split contexts when values update at different frequencies.

```typescript
interface State {
  items: Item[]
  selectedId: string | null
  status: 'idle' | 'loading' | 'ready' | 'error'
}

type Action =
  | { type: 'itemsLoaded'; items: Item[] }
  | { type: 'itemSelected'; id: string }
  | { type: 'loadingStarted' }
  | { type: 'loadingFailed' }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'itemsLoaded':
      return { ...state, items: action.items, status: 'ready' }
    case 'itemSelected':
      return { ...state, selectedId: action.id }
    case 'loadingStarted':
      return { ...state, status: 'loading' }
    case 'loadingFailed':
      return { ...state, status: 'error' }
  }
}

const ItemsContext = createContext<{ state: State; dispatch: Dispatch<Action> } | undefined>(undefined)

export function useItems() {
  const context = useContext(ItemsContext)
  if (!context) throw new Error('useItems must be used within ItemsProvider')
  return context
}
```

## Forms

### Short Controlled Form

```typescript
export function NameForm({ onSubmit }: { onSubmit: (name: string) => void }) {
  const [name, setName] = useState('')
  const error = name.trim() ? null : 'Name is required'

  return (
    <form
      onSubmit={event => {
        event.preventDefault()
        if (!error) onSubmit(name.trim())
      }}
    >
      <label htmlFor="name">Name</label>
      <input
        id="name"
        value={name}
        onChange={event => setName(event.target.value)}
        aria-invalid={Boolean(error)}
        aria-describedby={error ? 'name-error' : undefined}
      />
      {error && <p id="name-error">{error}</p>}
      <button type="submit" disabled={Boolean(error)}>Save</button>
    </form>
  )
}
```

## Error Boundaries

### Class Error Boundary

React error boundaries still require class components unless the project uses a dedicated library.

```typescript
interface ErrorBoundaryState {
  error: Error | null
}

export class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback?: React.ReactNode },
  ErrorBoundaryState
> {
  state: ErrorBoundaryState = { error: null }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error boundary caught:', error, errorInfo)
  }

  render() {
    if (this.state.error) {
      return this.props.fallback ?? <p>Something went wrong.</p>
    }

    return this.props.children
  }
}
```

## Performance

### Memoization

Profile before memoizing. Use these only when render cost or prop identity churn is measured or obvious from the component boundary.

```typescript
const sortedItems = useMemo(() => {
  return [...items].sort((a, b) => a.label.localeCompare(b.label))
}, [items])

const handleSelect = useCallback((id: string) => {
  setSelectedId(id)
}, [])

export const ItemRow = React.memo(function ItemRow({ item }: { item: Item }) {
  return <li>{item.label}</li>
})
```

### Code Splitting

```typescript
import { lazy, Suspense } from 'react'

const HeavyChart = lazy(() => import('./HeavyChart'))

export function Dashboard({ data }: { data: ChartData }) {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart data={data} />
    </Suspense>
  )
}
```

### Virtualization

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

export function VirtualItemList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,
    overscan: 5
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`
            }}
          >
            <ItemRow item={items[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

## Animation

### Framer Motion

```typescript
import { motion, AnimatePresence } from 'framer-motion'

export function AnimatedItemList({ items }: { items: Item[] }) {
  return (
    <AnimatePresence>
      {items.map(item => (
        <motion.div
          key={item.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.3 }}
        >
          <ItemRow item={item} />
        </motion.div>
      ))}
    </AnimatePresence>
  )
}
```

## Accessibility

### Keyboard Navigation

```typescript
export function Dropdown({ options, onSelect }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false)
  const [activeIndex, setActiveIndex] = useState(0)

  const handleKeyDown = (event: React.KeyboardEvent) => {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault()
        setActiveIndex(index => Math.min(index + 1, options.length - 1))
        break
      case 'ArrowUp':
        event.preventDefault()
        setActiveIndex(index => Math.max(index - 1, 0))
        break
      case 'Enter':
        event.preventDefault()
        onSelect(options[activeIndex])
        setIsOpen(false)
        break
      case 'Escape':
        setIsOpen(false)
        break
    }
  }

  return <div role="combobox" aria-expanded={isOpen} aria-haspopup="listbox" onKeyDown={handleKeyDown} />
}
```

### Focus Management

```typescript
export function Modal({ isOpen, onClose, children }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null)
  const previousFocusRef = useRef<HTMLElement | null>(null)

  useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement as HTMLElement
      modalRef.current?.focus()
    } else {
      previousFocusRef.current?.focus()
    }
  }, [isOpen])

  return isOpen ? (
    <div ref={modalRef} role="dialog" aria-modal="true" tabIndex={-1} onKeyDown={event => event.key === 'Escape' && onClose()}>
      {children}
    </div>
  ) : null
}
```
