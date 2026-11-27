# File Organization

Use when adding a module or resolving a real ownership or import issue. Do not reorganize an existing tree merely to match a generic template.

- **Colocate by owning responsibility:** keep a cohesive component or rule with its tests and private helpers. Split styles, types, or helpers only when responsibilities diverge or local conventions require it.
- Preserve framework-reserved filenames where that framework is actually in use.
- Use `import type` for type-only dependencies so bundlers and `verbatimModuleSyntax` erase them cleanly; follow the project's formatter/linter for import order.
- **Barrel-file hazards:** restrict `index.ts` barrel exports to genuine package/public boundaries. Deep internal re-export barrels degrade bundler **tree-shaking**, slow test startup/HMR, and trigger **circular dependency / TDZ (`ReferenceError`)** failures at runtime.
- Follow project environment-file conventions; commit `.env.example` with placeholders, never real credentials.

Avoid creating empty directories or single-caller pass-through wrapper files.
