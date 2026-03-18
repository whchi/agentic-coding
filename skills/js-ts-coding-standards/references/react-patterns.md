# React Patterns

Component structure, hooks, and state management standards.

## Component Structure

```typescript
// ✅ GOOD: Functional component with types
interface ButtonProps {
  children: React.ReactNode
  onClick: () => void
  disabled?: boolean
  variant?: 'primary' | 'secondary'
}

export function Button({
  children,
  onClick,
  disabled = false,
  variant = 'primary'
}: ButtonProps) {
  return (
    <button
      onClick={onClick}
      disabled={disabled}
      className={`btn btn-${variant}`}
    >
      {children}
    </button>
  )
}

// ❌ BAD: No types, unclear structure
export function Button(props) {
  return <button onClick={props.onClick}>{props.children}</button>
}
```

### Component Organization

```typescript
// Typical component file structure:
// 1. Imports
// 2. Types and interfaces
// 3. Component definition
// 4. Sub-components (if closely related)
// 5. Utility functions (if component-specific)

import { useState } from 'react'

interface Props {
  initialValue: number
}

export function Counter({ initialValue }: Props) {
  const [count, setCount] = useState(initialValue)
  
  return (
    <div>
      <span>{count}</span>
      <button onClick={() => setCount(c => c + 1)}>+</button>
    </div>
  )
}
```

## Custom Hooks

### useDebounce

```typescript
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}

// Usage
const debouncedQuery = useDebounce(searchQuery, 500)
```

### useLocalStorage

```typescript
export function useLocalStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => void] {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch {
      return initialValue
    }
  })

  const setValue = (value: T) => {
    setStoredValue(value)
    window.localStorage.setItem(key, JSON.stringify(value))
  }

  return [storedValue, setValue]
}
```

## State Management

### useState

```typescript
// ✅ GOOD: Functional update for state based on previous state
setCount(prev => prev + 1)

// ❌ BAD: Direct state reference (can be stale in async)
setCount(count + 1)

// ✅ GOOD: Object updates with spread
setUser(prev => ({ ...prev, name: 'New Name' }))

// ❌ BAD: Mutating state directly
user.name = 'New Name'
setUser(user)
```

### useReducer

Use for complex state with multiple actions:

```typescript
type State = { count: number }
type Action = { type: 'increment' } | { type: 'decrement' } | { type: 'reset' }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 }
    case 'decrement':
      return { count: state.count - 1 }
    case 'reset':
      return { count: 0 }
  }
}

const [state, dispatch] = useReducer(reducer, { count: 0 })
```

## Conditional Rendering

```typescript
// ✅ GOOD: Clear, readable conditions
{isLoading && <Spinner />}
{error && <ErrorMessage error={error} />}
{data && <DataDisplay data={data} />}

// ✅ GOOD: Early returns for complex conditions
function UserCard({ user }) {
  if (!user) return <EmptyState />
  if (user.isBanned) return <BannedMessage />
  
  return <UserProfile user={user} />
}

// ❌ BAD: Ternary hell
{isLoading 
  ? <Spinner /> 
  : error 
    ? <ErrorMessage error={error} /> 
    : data 
      ? <DataDisplay data={data} /> 
      : null}
```

## Event Handlers

```typescript
// ✅ GOOD: Named handlers with clear purpose
const handleSubmit = useCallback((e: React.FormEvent) => {
  e.preventDefault()
  onSubmit(formData)
}, [formData, onSubmit])

const handleChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
  setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }))
}, [])

// ❌ BAD: Inline handlers in JSX
<button onClick={() => {
  // 10 lines of logic
}}>Submit</button>
```

## Key Prop

```typescript
// ✅ GOOD: Stable, unique keys
{items.map(item => (
  <ItemCard key={item.id} item={item} />
))}

// ❌ BAD: Index as key (unstable on reorder)
{items.map((item, index) => (
  <ItemCard key={index} item={item} />
))}

// ❌ BAD: Generated keys (regenerates on every render)
{items.map(item => (
  <ItemCard key={Math.random()} item={item} />
))}
```