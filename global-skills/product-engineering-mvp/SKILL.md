---
name: product-engineering-mvp
description: Use when making early product engineering decisions, estimating MVP costs, pricing technical effort, choosing managed services vs custom builds, or balancing business value against implementation complexity.
---

# Product Engineering MVP

Use this skill when technical choices should be driven by business value and learning speed.

## Principles

- Before MVP validation, use managed services when they reduce time and operational burden.
- When the team is small, avoid owning infrastructure that does not differentiate the product.
- Technical choices should serve business value, not engineering taste.
- Simple problems get simple solutions. Complex solutions need a real reason.

## Cost Estimation

List all plausible costs:

- Engineering time
- Design/product time
- Operations and maintenance
- Managed service fees
- Third-party API costs
- Support burden
- Migration/rework risk
- Opportunity cost

After estimating, add a buffer around 50 percent unless there is strong historical data.

## Pricing / Value Lens

When product pricing is part of the discussion:

1. Estimate customer value created or cost saved.
2. Compare similar competitors and substitutes.
3. Avoid pricing so low that it attracts the wrong user segment.
4. Revisit price after learning from real usage.

## Build vs Buy

Prefer buying/managed services for:

- Auth
- Database hosting
- File storage
- Email
- Payments
- Analytics
- Search
- Scheduling
- Background jobs when hosted options fit

Build custom when:

- It is core differentiation.
- Existing services block the product model.
- Compliance, data control, or scale requires ownership.
- The cost of the service clearly exceeds ownership cost.

## Output

Return:

- Business goal
- Fastest MVP path
- Managed services to use
- What to build custom
- Cost estimate with buffer
- Risks and revisit triggers
