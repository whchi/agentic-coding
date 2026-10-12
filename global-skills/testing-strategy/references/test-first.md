# Focused Test-First Implementation

Use this mode for explicitly requested test-first work or an authorized bug fix with an obvious, cheap test path. An explicit request does not make an impractical test useful; explain the obstacle and use a closer executable check.

## Workflow

1. Identify intended behavior, the affected path, and the smallest observable reproduction.
2. Choose the nearest existing unit, component, or integration test. Reuse an existing failing test when it captures the requirement.
3. Add the smallest regression test, then run it before changing production code. Confirm it fails for the intended reason, not broken setup. If it passes unexpectedly, correct the reproduction or establish that the behavior already works.
4. Make the smallest fix while preserving nearby contracts.
5. Rerun the regression test and affected checks. Refactor only when needed by this change and keep the tests green.

## When test-first is impractical

Unclear reproduction, production-only state, broad harness setup, brittle mocks, slow infrastructure, or unrelated fixture churn are reasons to use a targeted script, reproduction command, browser flow, snapshot, or focused integration check instead. A temporary diagnostic script can be useful evidence without becoming a permanent test.

If the fix already exists, preserve it. Use a pre-fix revision when practical to demonstrate sensitivity; otherwise state that failing-before was not observed. Do not delete working code to recreate red.

Keep a flaky reproduction controlled where possible and document the remaining variability; one green run does not prove an intermittent bug is gone. Additional sibling coverage needs a concrete affected contract, not speculative expansion.

Report the before/after check and observed results. If either half could not run, name the reason and the alternative evidence. Never claim a red-green cycle that was not observed.
