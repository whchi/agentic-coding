# Frontend Robust Data Handling

Treat raw API payloads (DTOs) as untrusted transport shapes and separate them from UI **ViewModels** when their contracts differ. Place normalization in an **Anti-Corruption Adapter** at the data boundary rather than scattering optional chaining and fallbacks across components.

- **Boundary parsing & normalization:** parse/normalize optional fields, missing nested objects, and unknown enum values once in the adapter — only where the payload contract requires it. Reuse the project's existing data/query layer; do not invent an adapter for an already stable, schema-typed payload.
- **Discriminated async state:** model lifecycle states explicitly (`idle | loading | ready | error`) instead of independent boolean flags that permit impossible combinations (e.g., `isLoading && error`).
- **Null Object pattern:** substitute a typed fallback/null object for a missing nested record only when it simplifies rendering without erasing user-relevant meaning.
- **State fidelity:** preserve the distinction between `empty`, `unknown`, `unavailable`, `loading`, and `error` whenever the user should see different feedback.
- **Partial failure isolation:** one malformed item or missing relation in a collection must degrade locally rather than crashing sibling rows or the entire view.

Verify malformed and partial inputs permitted by the contract, including mixed completeness within the same list and forward-compatible unknown enum values. Confirm defaults neither leak raw `null`/`undefined`/`NaN` into the UI nor silently mask a business/API error.

Report the data-shape risk, chosen ViewModel/UI state contract, and verification outcome. API contract redesign and general component architecture remain separate decisions.
