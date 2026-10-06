---
name: requirement-to-jira
description: 把 requirement-breakdown 產出的 `cards.json` 建到 Jira、更新由它建出的卡、或核對 Jira 與 `cards.json` 是否一致。只負責 Jira 這一層：站台、欄位對應、建卡與回填卡號、讀回核對。需要 Jira MCP 工具。Do NOT use 拆需求、寫 Gherkin、review、估點（requirement-breakdown），也不要用在與 `cards.json` 無關的一般 Jira 操作。Use when sending a finished cards.json to Jira, updating cards created from it, or reconciling Jira with cards.json. Do NOT use for breaking down requirements (requirement-breakdown) or general Jira edits unrelated to cards.json.
---

# cards.json → Jira

拆解的方法（來源入庫、釐清 Goal、寫 Scenario、review、成卡、估點）全部在 **`requirement-breakdown`**。這份只做它最後一步（交棒：照 `cards.json` 建卡）的 Jira 部分，**不重寫拆解步驟**。還沒有 `cards.json` 就回去走 `requirement-breakdown`。

本 skill 依賴 `requirement-breakdown`：`cards.json` schema 與卡片描述組裝模板都在它的 `references/breakdown-json-format.md`。找不到那個 skill 就停下來請使用者安裝，不要自己猜描述格式。

用 Jira MCP 查站台、專案、欄位 id，`createJiraIssue` 參數形狀、Status 與 sprint 的坑：`references/jira-mcp.md`。
`cards.json` 欄位怎麼對到 Jira 欄位：`references/cards-json-format.md`。

## 動手前

- 確認有 Jira MCP 工具（`createJiraIssue`、`searchJiraIssuesUsingJql`、`getAccessibleAtlassianResources` 等；工具名前綴依環境而異）。沒有就停下來告訴使用者，不要改用 REST、CSV 匯入或瀏覽器自行建卡。
- `cards.json` 存在。`meta.target` 是空的就依 `references/cards-json-format.md` 填好草稿給使用者確認；`meta.target.system` 必須是 `"jira"`。
- `meta.estimate.unit` 要跟 Jira story point 欄位的實際單位一致；不確定就停下來問，不要自行換算點數。
- 站台、專案、assignee、issue type、story point 欄位 id 一律用 Jira MCP 查出來（見 `references/jira-mcp.md`），填進 `meta.target`；不要寫死，也不要沿用別的專案的值。
- 先做「建新卡」的第 1 步（唯讀前置檢查），再把**最終清單**給使用者：站台／專案／label／assignee、每張卡的 summary 與點數、子項數、合計對 `meta.totals`。等明確的 go。這是對外動作，不接受推論出來的同意；先前的 go 不延伸到這一次，清單變了要重新確認。
- 回填 `key` 直接編輯 `cards.json` 這個檔案，改完確認檔案內容真的變了（有些環境的 sandbox 執行工具不會把寫入落到真正的檔案系統）。不要寫建卡腳本留在 repo；交付的是 `cards.json` 本身。

## 建新卡（`key` 為 null）

1. **前置檢查（唯讀，go 之前做）**：用 `references/jira-mcp.md` 的 JQL 讀出該 label 在 Jira 上已有的卡，逐字比對 summary。對得上的標成「回填 key、不重建」；對不上的列給使用者。舊主題的卡常常已經在 Jira，只是 repo 沒有卡號。
2. 逐張 `createJiraIssue`（參數形狀見 `jira-mcp.md`）。
3. **每建一張立刻把 `key` 回填進 `cards.json`**，再建下一張。中途失敗時，已有 `key` 的卡重跑會被跳過。
4. 檢查回傳的 Status；不是 `To Do` 就 `transitionJiraIssue`。
5. 有 `tasks` 的卡：母卡建好後，每個 `task` 另開一張 `Subtask`（`parent` = 母卡 key，不帶點數），同樣建一張回填一張。
6. 被工具退回就照 `repairHint` 修正後重試一次；仍失敗就停下來報告，不要換參數盲試。

## 改已建的卡（`key` 有值）

不要直接用 `cards.json` 覆蓋。

1. `getJiraIssue`（`view: "evidence"`）讀現況。
2. 和 `cards.json` 比差異，只列**來源變動影響到**的欄位，以及 Jira 上被人改過、與 `cards.json` 不同的欄位。
3. 把差異給使用者看，核可後 `editJiraIssue` 只改核可的欄位。`labels` 等多值欄位是整組覆蓋，要送完整清單。
4. 改完把 `cards.json` 同步成使用者核可的內容。

## 建完 / 改完

- **讀回來核對**，用 `jira-mcp.md` 的 JQL：張數、Status、assignee、點數總和，逐項對 `cards.json` 的 `meta.totals`。母卡與子項分開算。
- 報告給**實際卡號範圍**與核對結果，不要只說「建好了」。核對不符就列出不符項，不要說完成。

## 預設做法（細節在 reference）

- Issue Type `Feature`；子項 `Subtask`
- Summary：`[<產品>] ` 前綴 + 三段式 user story；子項不帶前綴
- Labels 只放產品名，不加 goal 代號
- Status 一律 `To Do`（預設的 `Idea` 在 board 上不顯示）
- Story point 欄位用 Jira MCP 查出的 custom field id（顯示名常是 `Story point estimate`，不是 `Story Points`）
- 不指定 sprint（product backlog）

## 舊做法：不要沿用

goal 代號當 label、`{code:gherkin}` wiki markup、CSV 匯入當主要建卡途徑、`build.mjs`／`verify.mjs` 腳本層——都已被上面的做法取代。
