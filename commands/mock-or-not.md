---
description: Decide whether a test dependency should be real, a fake, or a mock; use testing-strategy for the complete test-boundary decision.
---

# /mock-or-not

Use this command as a short entry point before adding a test double. Follow `testing-strategy` for the complete decision, using the behavior under test, target test level, and dependency boundary as input.

Use these terms consistently:

- **Real**: the actual collaborator, used when it is cheap, deterministic, and part of the behavior being verified.
- **Fake**: a lightweight working implementation used when the real collaborator is too slow or infrastructure-heavy but behavior still matters.
- **Mock**: a test-controlled boundary used when interaction with an uncontrollable external dependency is the contract.

Return:

- Dependency boundary and target test level
- Real/fake/mock choice with reason
- What behavior should be asserted
- What would make the test brittle
