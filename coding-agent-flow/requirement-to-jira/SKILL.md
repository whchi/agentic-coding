---
name: requirement-to-jira
description: 以 cards.json 在 Jira 建卡、更新或核對並回填卡號；適用已完成的需求拆解清單，不處理一般 Jira 操作。
---

# cards.json → Jira

使用 Jira MCP 處理已完成的 `cards.json`。需求拆解與估點由 `requirement-breakdown` 處理；缺來源時先補齊，不從對話記憶拼湊欄位。

## 需要時讀取

- Schema 與描述模板：[breakdown-json-format.md](../requirement-breakdown/references/breakdown-json-format.md)。
- Jira 欄位與 `meta.target`：[cards-json-format.md](references/cards-json-format.md)。
- 站台查詢、工具參數、JQL、更新注意事項：[jira-mcp.md](references/jira-mcp.md)。

## 準備與授權

先做唯讀查詢與清單核對，再處理對外寫入：

- 確認 Jira MCP 可用；若不可用，說明缺少的能力，不自行換成 REST、CSV 或瀏覽器寫入。
- 用 MCP 核對站台、專案、issue type、assignee、點數欄位與工作流程，填入 `meta.target`；不得借用其他專案的 ID。
- `meta.target.system` 必須是 `"jira"`；估點單位必須與欄位一致，不自行換算。
- 查詢既有卡並比對 summary；唯一且確認對應的卡回填 key，不重建；模糊或多筆對應先釐清。
- 對最終清單取得明確授權：目標站台／專案、每張卡的 Summary／點數、子項及總數。已有授權涵蓋同一清單時繼續；清單或寫入範圍改變才補確認。

回填直接修改原本的 `cards.json`，確認寫入已落地。交付資料，不新增建卡腳本層。

## 建新卡

1. 只建立尚未對應既有 issue 且 `key` 為 null 的卡。
2. 每次成功建立後立即回填 key，再建下一張；母卡與子項都如此。子項指定 parent、不另計點。
3. 依 `meta.target.status` 核對狀態，需要時透過 transition 修正；不自行指定 sprint。
4. 參數被明確拒絕時依工具的 `repairHint` 修正重試一次；仍失敗就保留進度並報告。若回應不確定是否已建立，先查 Jira，不能盲目重送 create。

## 更新已有卡

先讀現況，再列出來源變動影響的欄位及他人修改。只更新授權範圍；`labels` 等多值欄位須保留未要求移除的項目，描述含 inline media 時也須避免遺失。將確認的內容同步回 JSON。

## 核對結果

讀回實際卡號，核對 Summary、母卡／子項數、狀態、assignee 與點數總和；比較 `meta.totals` 時分開計算子項。報告實際卡號與不符項，未完成或核對失敗不能標為完成。
