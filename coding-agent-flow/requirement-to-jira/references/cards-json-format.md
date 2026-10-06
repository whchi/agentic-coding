# `cards.json` 的 Jira 層

schema 本體在 `requirement-breakdown` skill 的 `references/breakdown-json-format.md`。這份只寫 Jira 專屬的部分：`meta.target` 放什麼、欄位怎麼對到 `createJiraIssue`。

## `meta.target`

```json
{
  "system": "jira",
  "cloudId": "<getAccessibleAtlassianResources 查到的 cloudId>",
  "projectKey": "<使用者確認的專案 key>",
  "issue_type": "Feature",
  "subtask_issue_type": "Subtask",
  "label": "sso",
  "assignee": "<accountId，用 Jira MCP 查>",
  "story_point_field": "<用 Jira MCP 查到的 custom field id>",
  "status": "To Do",
  "sprint": null
}
```

- `label` 只放產品名，不要加 goal 代號。
- `assignee` 填 accountId；沒有指定人就給 `null`，建卡後再補。
- `status` 是建完後要確認的狀態；預設落在別的狀態就 transition 過去。
- `sprint: null` = 留在 product backlog。注意 `[Product]: xxx` 那組偽 sprint 會讓卡從 backlog 查詢消失。
- 站台、專案、欄位 id 與踩過的雷見 `jira-mcp.md`。

## 欄位對應

| `cards.json` | `createJiraIssue` |
|---|---|
| `meta.target.cloudId` / `projectKey` | `cloudId` / `projectKey` |
| `meta.target.issue_type` | `issueType` |
| `card.summary` | `summary`（原字，含前綴，不再拼接） |
| 描述組裝模板（見 `requirement-breakdown` 的 `breakdown-json-format.md`） | `description`，`contentFormat: "markdown"` |
| `meta.target.label` | `labels: [label]` |
| `meta.target.assignee` | `assignee`（頂層參數，accountId） |
| `card.points` + `meta.target.story_point_field` | `additional_fields: { "<story_point_field>": n }` |
| `card.tasks[i].title` | 另一張 `issueType: "Subtask"` + `parent: <母卡 key>`，`labels` 同母卡，不帶點數，summary 不帶前綴 |
| `card.key`、`card.tasks[i].key` | 建卡後把回傳的 issue key 寫回來 |

參數的完整形狀、`assignee` 與 `parent` 的版本差異見 `jira-mcp.md`。

`meta.estimate.unit` 必須和 story point 欄位的實際單位一致；不確定就問使用者，不要自行換算。
