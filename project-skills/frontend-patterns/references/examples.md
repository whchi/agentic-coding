# Frontend Patterns Examples

Read only the section needed for the current decision. These are focused patterns for bug-prone UI boundaries; preserve the project's libraries and accessible primitives.

## Split Context + Discriminated Reducer

Split frequently changing state from stable `dispatch` so action-only consumers do not rerender when state updates.

```typescript
type ItemsState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'ready'; items: Item[]; selectedId: string | null }
  | { status: 'error'; message: string }

type ItemsAction =
  | { type: 'loadStarted' }
  | { type: 'loadSucceeded'; items: Item[] }
  | { type: 'loadFailed'; message: string }
  | { type: 'selected'; id: string }

const ItemsStateContext = createContext<ItemsState | undefined>(undefined)
const ItemsDispatchContext = createContext<Dispatch<ItemsAction> | undefined>(undefined)

export function ItemsProvider({ children }: { children: React.ReactNode }) {
  const [state, dispatch] = useReducer(itemsReducer, { status: 'idle' })
  return (
    <ItemsStateContext.Provider value={state}>
      <ItemsDispatchContext.Provider value={dispatch}>
        {children}
      </ItemsDispatchContext.Provider>
    </ItemsStateContext.Provider>
  )
}

export function useItemsState(): ItemsState {
  const ctx = useContext(ItemsStateContext)
  if (!ctx) throw new Error('useItemsState must be used within ItemsProvider')
  return ctx
}

export function useItemsDispatch(): Dispatch<ItemsAction> {
  const ctx = useContext(ItemsDispatchContext)
  if (!ctx) throw new Error('useItemsDispatch must be used within ItemsProvider')
  return ctx
}
```

## Accessible Controlled Form

Derive validation state during render, associate errors via `aria-invalid` + `aria-describedby`, and announce errors via `role="alert"` (`aria-live="assertive"`).

```typescript
export function NameForm({ onSubmit }: { onSubmit: (name: string) => void }) {
  const [name, setName] = useState('')
  const [submitted, setSubmitted] = useState(false)
  const error = name.trim() ? null : 'Name is required'
  const visibleError = submitted ? error : null

  return (
    <form
      noValidate
      onSubmit={event => {
        event.preventDefault()
        setSubmitted(true)
        if (!error) onSubmit(name.trim())
      }}
    >
      <label htmlFor="name">Name</label>
      <input
        id="name"
        value={name}
        onChange={event => setName(event.target.value)}
        aria-invalid={Boolean(visibleError)}
        aria-describedby={visibleError ? 'name-error' : undefined}
      />
      {visibleError && (
        <p id="name-error" role="alert">
          {visibleError}
        </p>
      )}
      <button type="submit">Save</button>
    </form>
  )
}
```

## Virtualized List (`@tanstack/react-virtual`)

Use when DOM node count causes measurable INP/scroll jank; position rows with `transform` rather than `top` to stay on the compositor path.

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

export function VirtualItemList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 56,
    overscan: 5,
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div style={{ height: `${virtualizer.getTotalSize()}px`, position: 'relative' }}>
        {virtualizer.getVirtualItems().map(row => (
          <div
            key={items[row.index].id}
            style={{
              position: 'absolute',
              insetBlockStart: 0,
              insetInlineStart: 0,
              width: '100%',
              height: `${row.size}px`,
              transform: `translateY(${row.start}px)`,
            }}
          >
            <ItemRow item={items[row.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

## Native `<dialog>` Focus Containment & Restoration

Prefer native `<dialog>` (or the project's accessible primitive) over hand-rolled focus traps: `showModal()` makes background content `inert`, handles `Escape`, and restores focus to the opener on close.

```typescript
export function Modal({ isOpen, onClose, titleId, children }: ModalProps) {
  const dialogRef = useRef<HTMLDialogElement>(null)

  useEffect(() => {
    const dialog = dialogRef.current
    if (!dialog) return
    if (isOpen && !dialog.open) dialog.showModal()
    if (!isOpen && dialog.open) dialog.close()
  }, [isOpen])

  return (
    <dialog ref={dialogRef} aria-labelledby={titleId} onClose={onClose}>
      {children}
    </dialog>
  )
}
```
