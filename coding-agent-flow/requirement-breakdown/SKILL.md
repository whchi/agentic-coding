---
name: requirement-breakdown
description: 將需求或設計稿拆成 user goal、Gherkin 驗收情境與 tracker 無關的 cards.json；用於需求拆解、情境 review 與開卡清單，不負責實際建卡。
---

# 需求拆解

依使用者已有的資料開始，完成所要求的拆解範圍。可直接 review 既有 Scenario，或由確認過的 Goal 產出卡片；不必重走完整流程，也不在每個中間產出後停下等批准。

沿用 repo 的主題／需求目錄與使用者語言。只有位置會影響既有資料、或需求缺口影響驗收結果時才詢問；其他可逆選擇說明後繼續。

## 來源與追溯

- 外部文件或設計稿存成主題下的來源快照，記出處、擷取日期與來源修改時間；既有 `source/` 或 `design/` 可直接沿用。
- 沿用來源的角色、狀態、欄位與術語。來源沒決定的產品行為不自行補成事實。
- 需要使用者決定的缺口列出可選讀法與影響；已知事實先查資料，不拿來問使用者。
- 把確認的規則、Scenario 與術語存回文件；尚未決定的記「來源落差」，標明暫採讀法及受影響卡片。
- 交付文件與 `cards.json`；臨時核對工具不必變成專案的新工具層。

## 依產出讀參考

| 當前工作 | 參考 |
| --- | --- |
| 建立來源快照、Goal、Feature、Scenario | [user-goal-format.md](references/user-goal-format.md) |
| 釐清驗收缺口或 review Scenario | [review-and-grill.md](references/review-and-grill.md) |
| 產出拆解清單、估點與 JSON | [breakdown-json-format.md](references/breakdown-json-format.md) |

不要為了修改一段 Scenario 載入所有格式與建卡細節。

## Goal 與驗收情境

Goal 描述角色想達成的結果，Feature 是可獨立驗收的能力。跨 Goal 的規則放「共同前提」；使用穩定的 Goal／Feature／Scenario 編號。

一個 Scenario 一個觸發動作 `When`；`Given` 是前提，`Then` 是可觀察結果。涵蓋適用的正常、替代、拒絕與不變量情境，不為湊數虛構拒絕流程。設計稿看不出的操作目的或導航去向列為缺口。

Review 要覆蓋範圍內每條 Scenario，可合併報告無發現項目。修正已授權的內容；只做 review 的請求則先交付 findings。

## 卡片與估點

- Goal 預設只作追溯代號，不開 Epic；Feature 對應一張卡；Scenario 對應 AC 與 Gherkin，不另開卡。跨 Goal 不合卡。
- Feature Summary 用「身為<角色>，我要能夠<能力>，以完成<目的>」。Task 用直接任務句，只有需要時才拆子項；母卡點數維持 umbrella，子項不重複計點。
- 階段與優先序照來源；來源沒標就留白。
- `breakdown.md` 與 `cards.json` 的 Summary、卡數、Scenario 數與點數一致；tracker 設定只放 `meta.target`。
- 估點沿用本主題已確認的單位、每日點數與開發方式；缺失才問，不沿用其他專案假設。明寫包含／不包含的工作、未決假設，以及換算工作天時是否平行。
- 估實際工作，不為偏好上限壓低數字；高點數說明原因，依能否獨立驗收決定拆分。

## 交棒邊界

拆解完成不表示已授權建立外部 issue。先完成可檢查的清單與估點基準；實際建卡由 tracker 流程在明確授權後執行，Jira 使用 `requirement-to-jira`。

下游只以 `cards.json` 建卡：有 `key` 先讀現況，避免覆蓋他人修改；新建後逐張回填 `key`，最後讀回核對。來源變動時只重做受影響的 Goal、Scenario、review 與卡片，不重建未變內容。
