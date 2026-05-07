---
name: frontend-robust-data-handling
description: Use when frontend code consumes backend data, needs null object/default object handling, protects UI rendering from missing fields, or designs adapters between API payloads and UI state. Do NOT use for general React architecture or API contract design.
---

# Frontend Robust Data Handling

Use this skill when UI rendering should stay stable despite incomplete, missing, or changing backend data.

## Boundaries

Use related skills for adjacent concerns:

- `frontend-patterns` for component architecture, forms, state placement, performance, accessibility, and server-state library choices.
- `api-design` when the backend API contract itself should change.
- `testing-strategy` for choosing unit/integration/e2e coverage shape.

## Principle

Frontend code should protect the render layer from raw backend uncertainty. Use adapters, defaults, and null object patterns so missing data creates intentional UI states instead of runtime errors or broken display.

## Workflow

1. Identify the API payload and the UI model separately.
2. Create a mapping/adaptation boundary near data fetching.
3. Normalize optional fields into explicit defaults where the UI expects stable values.
4. Use null object patterns for common missing nested objects.
5. Keep loading, empty, error, and partial-data states explicit.
6. Do not let raw backend shape leak through many components.
7. Preserve meaningful absence when the UI must distinguish unknown, empty, and unavailable.
8. Add tests for absent fields, empty lists, partial nested objects, and invalid enum values.

## Patterns

Good:

- `toUserViewModel(apiUser)` maps raw API to render-safe data.
- Components receive stable arrays, strings, booleans, and known variants.
- Missing optional relations become explicit empty/null object states.

Bad:

- Deep optional chaining throughout the component tree.
- UI branches directly on raw backend status strings.
- One missing nested field breaks the whole page.
- Defaults erase important business meaning.

## Output

Return:

- Raw data risks
- Suggested UI model
- Adapter/default strategy
- States to render
- Tests to add
