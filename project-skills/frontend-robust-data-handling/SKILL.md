---
name: frontend-robust-data-handling
description: Keep UI rendering stable when API payloads contain missing, null, partial, or unknown values; use for render-safe adapters and explicit data states.
---

# Frontend Robust Data Handling

Separate the API payload from the UI model when their contracts differ. Put normalization near the data boundary rather than scattering fallback logic across components.

- Normalize optional fields and unknown enum values only where the actual payload contract requires it.
- Use a null object for a missing nested object when it simplifies rendering without erasing meaning.
- Preserve distinctions between unknown, empty, unavailable, loading, and error when they affect the user.
- Keep partial data usable: one missing relation should not break unrelated rows or the whole page.
- Reuse the project's data layer; this skill does not require a new adapter abstraction for an already stable payload.

Check the malformed or partial inputs permitted by the contract, including mixed completeness within a list. Verify that defaults neither render raw `null`/`undefined`/`NaN` nor conceal a business error. Cover unknown enum values when the API can introduce them.

Explain the data risk, chosen UI state, and verification result. API contract redesign and general component architecture are separate decisions.
