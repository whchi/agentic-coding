# File Organization

Use when adding a module or resolving a real ownership/import problem. Do not reorganize an existing tree merely to match a generic template.

- Put code with the feature or layer that owns its behavior.
- Keep a small component in one file. Split implementation, styles, types, or tests only when they have distinct responsibilities or local conventions require it.
- Preserve framework-reserved filenames, such as Next.js `page.tsx`, `layout.tsx`, and `route.ts`, where that framework is actually in use.
- Follow the configured formatter/linter for import order; use `import type` for type-only dependencies.
- Keep barrel exports scoped to a stable public boundary. Split because of cycles, accidental coupling, or unclear ownership rather than a fixed export count.
- Follow the project's environment-file conventions. Commit examples with placeholder values, not credentials.

A colocated feature might contain:

```text
markets/
  MarketCard.tsx
  MarketCard.test.tsx
  market.ts
```

This is an example, not a required structure. Avoid creating empty directories or extra wrapper/index files without a caller.
