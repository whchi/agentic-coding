# Naming Conventions

Use when names are ambiguous or a naming convention must be established. Existing repository conventions and domain terms take precedence; avoid renaming unrelated code.

| Meaning | Useful pattern | Example |
| --- | --- | --- |
| Boolean predicate | `is`, `has`, `can`, `should` | `hasPermission` |
| Collection | Plural noun | `markets` |
| Calculation | Verb and result | `calculateTotal` |
| Conversion | `parse`, `format`, `to` | `parseMarket` |
| Event handler | `handle` + event | `handleSubmit` |
| Bounded quantity | Name with unit | `timeoutMs`, `priceCents` |

Use domain vocabulary consistently. Short names are fine in a small, unambiguous scope; longer names should add meaning rather than repeat the type.

For types, prefer domain names such as `Market` or `MarketStatus`; avoid adding `I`/`T` prefixes unless the project requires them. Distinguish fetching remote data from reading local state when that distinction helps callers.

For files, preserve the surrounding convention: React components often use `MarketCard.tsx`, hooks `useAuth.ts`, and utilities either camelCase or kebab-case. Do not mix naming systems within the same module category.

Use uppercase constants where the project uses them for fixed configuration, such as `MAX_RETRIES`; ordinary runtime bindings remain camelCase. A `const` declaration alone does not determine naming or immutability.
