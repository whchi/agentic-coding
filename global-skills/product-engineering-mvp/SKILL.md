---
name: product-engineering-mvp
description: Evaluate MVP scope, build-versus-buy choices, and delivery costs when an early product needs a practical path to validation.
---

# Product Engineering MVP

Use this skill when technical choices should be driven by business value and learning speed.

## Principles

- Before MVP validation, use managed services when they reduce time and operational burden.
- When the team is small, avoid owning infrastructure that does not differentiate the product.
- Technical choices should serve business value, not engineering taste.
- Simple problems get simple solutions. Complex solutions need a real reason.

## Cost Estimation

Include cost categories material to the proposed MVP:

- Engineering time
- Design/product time
- Operations and maintenance
- Managed service fees
- Third-party API costs
- Support burden
- Migration/rework risk
- Opportunity cost

State estimate ranges and the assumptions driving them. Use historical delivery data or identified uncertainty for contingency; do not apply an unexplained fixed percentage.

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
- Cost range, assumptions, and contingency where justified
- Risks and revisit triggers
