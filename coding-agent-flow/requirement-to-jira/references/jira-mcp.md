# Jira 站台、欄位與 MCP 參數

建卡與改卡的做法都在這裡。站台、專案、assignee、欄位 id 每個站台都不同：一律用 Jira MCP 查出來填進 `cards.json` 的 `meta.target`，不寫死在 skill 裡，也不沿用別的專案的值。參數形狀依 2026-10-06 的工具 schema，未實測建卡。

## 站台與專案

| 項目 | 值 | 來源 |
|---|---|---|
| 站台 | `meta.target` 對應的 Atlassian 站台 | `getAccessibleAtlassianResources` |
| cloudId | `meta.target.cloudId` | `getAccessibleAtlassianResources` |
| 專案 | `meta.target.projectKey` | 用 Jira MCP 列出可見專案，請使用者確認 |
| Issue Type | 母卡（常見 `Feature`）、子項（常見 `Subtask`）；名稱依專案而異 | 用 Jira MCP 查該專案的 issue type |
| 預設 assignee | `meta.target.assignee`（accountId） | 自己用 `atlassianUserInfo`；他人用 Jira MCP 查 accountId |
| Story point 欄位 | `meta.target.story_point_field`（custom field id；顯示名常是 `Story point estimate`） | 用 Jira MCP 查該 issue type 的欄位；單位問使用者 |
| Workflow 狀態 | 依專案而異 | 讀該專案一張既有的卡，或查可用的 transition |

## 建卡慣例

- Summary：`[<產品>] ` 前綴 + 三段式 user story；子項不帶前綴與三段式。前綴由 `cards.json` 的 `meta.summary_prefix` 決定。
- Labels 只放產品名（`meta.target.label`），子項也放。不要加 goal 代號。
- Status 一律 **`To Do`**。Jira 預設的 `Idea` 在 board 上沒有對應欄位，卡會完全不顯示（連 `dataset: all` 都查不到，只有 JQL 找得到）。2026-09-21 用 MCP 建的卡直接落在 `To Do`，但每次建完仍要查一次狀態，不是 `To Do` 就 transition。
- 不指定 sprint（product backlog）。有一組 `[Product]: xxx` 的偽 sprint（state 為 future），卡被放進去就不算「未排入 sprint」，backlog 查詢會漏掉。卡建出去後被人拉進正式 sprint 是正常的，不必處理。
- 描述用 markdown：`contentFormat: "markdown"`（預設）。不要用 `{code:gherkin}` wiki markup。

## `createJiraIssue` 參數形狀

依 2026-10-06 的工具 schema（**未實測建卡**）：

```jsonc
{
  "cloudId": "<meta.target.cloudId>",
  "projectKey": "<meta.target.projectKey>",
  "issueType": "Feature",                  // 是 issueType，不是 issueTypeName
  "summary": "<card.summary>",             // 原字，含前綴
  "description": "<組裝後的 markdown>",
  "contentFormat": "markdown",
  "labels": ["<label>"],
  "assignee": "<accountId>",               // 頂層參數
  "additional_fields": { "<meta.target.story_point_field>": 8 }   // 點數用 raw id，不依賴名稱解析
}
```

開子項：

```jsonc
{ "issueType": "Subtask", "parent": "<母卡 key>", "summary": "<task.title>", "labels": ["<label>"], "assignee": "<accountId>" }
```

`parent` 在現行 schema 是頂層參數。2026-09-21 的 memory 記的是「`assignee` 要放 `additional_fields` 且格式為 `{"accountId": …}`、`parent` 放 `additional_fields.parent.key`」——和現行 schema 不同，可能是工具改版。**第一次建卡若被退回，照回傳的 `repairHint` 修正後重試一次，並把實際可用的參數形狀回報給使用者，建議更新 repo 裡這份 reference；不要直接改已安裝的 skill 檔。**

## 改卡

- `editJiraIssue` 的 `fields` 是**整組覆蓋**，不是附加：`labels` 要送完整清單。
- 改之前先 `getJiraIssue`（`view: "evidence"` 才看得到 `Story point estimate` 等 custom field），和 `cards.json` 比差異。只改已授權欄位；未涵蓋的差異先確認，避免覆蓋他人改過的 AC、子項、狀態與點數。
- 改狀態用 `transitionJiraIssue`，不是 `editJiraIssue`。
- Jira 上的描述若含圖片等 inline media，用 markdown 改 `description` 會把它們弄掉。這種卡先把差異給使用者看，必要時用 `contentFormat: "html"`，或不動 description。

## 讀回核對

```
project = <meta.target.projectKey> AND labels = <label> ORDER BY key ASC
```

- `fields` 要明確列出 `summary`、`status`、`labels`、`issuetype` 與 `meta.target.story_point_field`，預設的 compact view 不含 custom field。
- 一頁最多 100 筆，超過用 `nextPageToken` 翻頁。
- 子項也會被這個 JQL 撈到，核對張數時母卡與子項分開算。

## 前置檢查：卡已經存在但 `cards.json` 沒有 key

`key` 為 null 不代表 Jira 上沒有。建卡前用上述 JQL 讀出該 label 的卡，逐字比對 summary。唯一且確認對應的回填 key，不重建；多筆同名或未對應的卡先釐清。Create 回應若不確定是否成功，也先查現況再決定是否重試。
