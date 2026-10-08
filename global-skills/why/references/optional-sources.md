# Optional Sources

Use a source in this file only when the harness has a tool for it. MCP tool names often contain the server name, such as `mcp__<server>__<tool>`. Examine the tool schema before the first call.

## General rules

- Search each available source. Record each query exactly.
- Read the full item: the full issue, the full document, or the full chat thread. The reason is often in a comment or a reply.
- Record a verbatim quote, a link or an ID, the author, and the date for each item.
- If a tool fails authentication, stop and record the source as a gap. Do not invent results.
- If no tool exists for a category, write "not available" in Sources consulted.
- Correlation in time is Inferred evidence, not Direct evidence. Other changes can occur in the same time window.
- An empty result after the retention limit of a source is a gap. It is not evidence that nothing happened.

## Categories

### Issue tracker

Examples: Jira, Linear, GitHub Issues.

- Open the issue IDs from the code anchor first. Read all comments.
- Search by feature name, symbol, and business term.
- If the issue is a child issue, open the parent. The parent often states the reason.
- Examine labels and milestones, such as `customer-request`, `incident`, or `compliance`.
- Errors: an issue scope can change after a reopen. A "Why" field with template text is not evidence.

### Long-form documents

Examples: Confluence, Notion, Google Docs.

- Search by feature name, symbol, author, and error string.
- Read the full page. Open child pages and pages that link to it.
- Errors: a design document can describe a plan that changed later. Compare the document with the PR. Record each difference as a contradiction.

### Team chat

Examples: Slack, Microsoft Teams.

- Search messages from the PR author near the merge date.
- Search for the PR URL, or for `/pull/<number>`.
- Search for the error string that the target handles.
- Read the full thread for each relevant message.
- Errors: a casual joke is not a decision. Direct messages are often not searchable.

### Observability

Examples: Datadog, Grafana, New Relic.

- Find the dashboards and monitors for the owning service. A monitor threshold can explain a constant in the code.
- Compare a metric with the merge date of the target.
- Errors: a dashboard shows that a team measured something. It does not show that the code exists because of it.

### Error tracking

Examples: Sentry, Rollbar.

- Search for the exception class, error message, or function that the target handles.
- Compare the first-seen and last-seen dates with the merge date.
- Errors: a refactor can move an error to a new issue ID. A "resolved" status is a human action, not proof of a fix.

### Analytics warehouse

Examples: Databricks, Snowflake, BigQuery.

- Confirm that a table exists before you query it.
- Limit each query to a time window, such as 30 days before and after the merge date.
- For a threshold constant, compare the constant with the p99 of the related value before the merge date.
- Errors: a new event in the data can mean new instrumentation, not new user behavior.

## Incident history

Use this angle when the target is defensive code. Examples are retries, timeouts, null guards, rate limits, and feature flags.

- In git, search for commit messages with "incident", "hotfix", "revert", or "defensive".
- In each available optional source, search for incidents and postmortems near the merge date.
- If you find a postmortem, read the action items. Action items often link to the code change.
- Agreement across two or more sources is Supported evidence. An example is an incident ID that is in an issue, a postmortem, and the PR.
