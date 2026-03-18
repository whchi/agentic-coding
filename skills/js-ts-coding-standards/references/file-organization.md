# File Organization

Project structure and file naming conventions.

## Project Structure

```
src/
├── app/                    # Next.js App Router
│   ├── api/               # API routes
│   │   ├── markets/
│   │   │   ├── route.ts   # GET, POST /api/markets
│   │   │   └── [id]/
│   │   │       └── route.ts # GET, PUT, DELETE /api/markets/:id
│   │   └── users/
│   ├── (auth)/           # Route group for auth pages
│   │   ├── login/
│   │   └── signup/
│   ├── markets/           # Market pages
│   │   ├── page.tsx       # /markets
│   │   └── [id]/
│   │       └── page.tsx   # /markets/:id
│   ├── layout.tsx         # Root layout
│   └── page.tsx           # Home page
├── components/            # React components
│   ├── ui/               # Generic UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Modal.tsx
│   │   └── index.ts       # Barrel export
│   ├── forms/            # Form components
│   │   ├── MarketForm.tsx
│   │   └── SearchForm.tsx
│   └── layouts/          # Layout components
│       ├── Header.tsx
│       ├── Footer.tsx
│       └── Sidebar.tsx
├── hooks/                # Custom React hooks
│   ├── useAuth.ts
│   ├── useDebounce.ts
│   └── useLocalStorage.ts
├── lib/                  # Utilities and configs
│   ├── api/             # API clients
│   │   ├── markets.ts
│   │   └── users.ts
│   ├── utils/           # Helper functions
│   │   ├── formatDate.ts
│   │   └── validate.ts
│   ├── constants.ts     # Constants
│   └── config.ts        # Configuration
├── types/                # TypeScript types
│   ├── market.types.ts
│   ├── user.types.ts
│   └── api.types.ts
└── styles/              # Global styles
    ├── globals.css
    └── variables.css
```

## File Naming Convention

| File Type | Convention | Example |
|-----------|------------|---------|
| Component | PascalCase.tsx | `Button.tsx`, `MarketCard.tsx` |
| Hook | camelCase with 'use' prefix | `useAuth.ts`, `useDebounce.ts` |
| Utility | camelCase.ts | `formatDate.ts`, `calculateScore.ts` |
| Type | camelCase.types.ts | `market.types.ts`, `api.types.ts` |
| API route | route.ts | `app/api/markets/route.ts` |
| Page | page.tsx | `app/markets/page.tsx` |
| Layout | layout.tsx | `app/layout.tsx` |
| Config | camelCase.ts or kebab-case.ts | `config.ts`, `api-client.ts` |

## Component Organization

### Single File

```
components/
└── Button.tsx        # Small component, single file
```

### Component Folder

```
components/
└── MarketCard/
    ├── index.tsx       # Main component export
    ├── MarketCard.tsx  # Component implementation
    ├── MarketCard.test.tsx
    ├── MarketCard.styles.ts
    └── types.ts
```

### Barrel Export

```typescript
// components/ui/index.ts
export { Button } from './Button'
export { Input } from './Input'
export { Modal } from './Modal'

// Usage
import { Button, Input, Modal } from '@/components/ui'
```

## Import Order

```typescript
// 1. External libraries (React, Next, third-party)
import { useState } from 'react'
import { useRouter } from 'next/router'
import { z } from 'zod'

// 2. Internalcomponents
import { Button } from '@/components/ui'
import { MarketForm } from '@/components/forms'

// 3. Hooks and utilities
import { useAuth } from '@/hooks/useAuth'
import { formatDate } from '@/lib/utils'

// 4. Types
import type { Market } from '@/types/market.types'

// 5. Constants and config
import { API_BASE_URL } from '@/lib/constants'

// 6. Styles (if applicable)
import styles from './MarketCard.module.css'
```

## Environment Files

```
.env.local          # Local overrides (gitignored)
.env.development     # Development environment
.env.production      # Production environment
.env.example         # Template (committed to git)
```

## Barrel Export Size Limit

Keep barrel exports small. If an `index.ts` file re-exports more than 10 items, split into subdirectories.

```typescript
// ✅ GOOD: Focused barrel export
// components/ui/index.ts
export { Button } from './Button'
export { Input } from './Input'
export { Modal } from './Modal'
export { Select } from './Select'

// ❌ BAD: Exporting everything
// components/index.ts
export * from './ui'
export * from './forms'
export * from './layouts'
export * from './market'
export * from './user'
// ... 50 more exports
```