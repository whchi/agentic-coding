---
description: "Choose real, fake, or mock collaborators for a specific test dependency."
---

# /mock-or-not

Decide from the behavior under test, target test level, and dependency boundary. Use `testing-strategy` when available; otherwise apply the project's testing conventions directly.

- **Real:** actual collaborator when deterministic, practical, and part of the behavior being verified.
- **Fake:** a lightweight working implementation when behavior matters but real infrastructure is impractical.
- **Mock:** a controlled boundary when the external interaction or response is the contract.

Follow project restrictions; in this repository, unit tests must mock third-party dependencies. Do not extend that restriction to integration or real-browser acceptance tests.

Return the dependency and test level, choice with reason, behavior to assert, and material brittleness or fidelity limits. If the request includes writing the test, implement and run the relevant test within the authorized scope.
