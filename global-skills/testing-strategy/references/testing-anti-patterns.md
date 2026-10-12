# Testing Anti-Patterns

Use these checks when mocks or test utilities may conceal a regression.

| Problem | Correction |
| --- | --- |
| Test observes only a mocked component or call count | Assert the actual required output, state, or interaction; a call is valid evidence when sending it is the contract |
| Mock removes state needed to expose the bug | Keep that transition real or use a faithful fake; for duplicate creation, preserve the first write and assert rejection or unchanged state on the second |
| Fixtures invent or omit required fields | Follow the real schema and consumed fields; malformed data belongs only in a case explicitly testing invalid input |
| Setup recreates most of the implementation | Use a smaller public interface or an existing integration test instead of building a parallel mock implementation |
| Production exposes a destructive method only for test cleanup | Keep reset in test utilities or supported lifecycle interfaces |

Do not change expected results just to fit incorrect code. A test failing first does not make its assertions meaningful: it must detect the required behavior breaking while mocks remain unchanged.
