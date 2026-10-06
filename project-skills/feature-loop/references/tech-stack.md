# Tech stack

The stack-specific tools and services behind the [shared verification rules](gates.md). This is the stack the loop was written for. When the project's instructions or manifests describe a different stack, follow those and use this file only as an example of the detail to record.

## Runtime and workspace

- Node.js with pnpm workspaces and a single root lockfile. Confirm the Node.js and pnpm versions, and any required PostgreSQL environment, meet the project constraints before running checks.
- Read the root and affected apps' `package.json` for scripts. With workspace filters (`pnpm --filter`), take package names from `package.json` instead of guessing.

## Checks per change scope

| Change scope | Stack-specific checks |
| --- | --- |
| Code | TypeScript type-check of the affected workspaces, plus their build and test scripts. |
| API / contracts | Hono routes: HTTP status, input validation, response data, and failure cases. |
| UI / data interaction | React: build, type-check, and the affected interactions in the browser. |
| Schema / migration | Drizzle: inspect the generated migration SQL; verify in an isolated PostgreSQL 17 test database. |
| Dependencies / workspace config | Each dependency declared in the `package.json` of the app that uses it; one root pnpm lockfile. |
