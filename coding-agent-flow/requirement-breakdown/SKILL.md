---
name: requirement-breakdown
description: 把模糊的需求、規格或設計稿拆成 user goal、BDD（Gherkin GWT）、review 與 epic/feature/task，產出 `user-goal.md`、`breakdown.md` 與交棒用的 `cards.json`（不綁任何 issue tracker）。當使用者要把需求拆成可驗收的 Goal／Scenario、寫或 review 需求層級的 GWT 驗收條件、或把需求整理成可開卡的清單與估點時使用。Do NOT use 寫 PRD／產品規格（write-a-prd）、單純 stress-test 計畫（grilling／grill-with-docs）、寫或 review 測試程式（testing-strategy）、或把 cards.json 真的建到 Jira（requirement-to-jira）。Use to turn vague requirements or mockups into user goals, Gherkin scenarios, and a tracker-agnostic cards.json backlog. Do NOT use for PRDs (write-a-prd), plain plan stress-tests (grilling), test code (testing-strategy), or creating Jira issues (requirement-to-jira).
---

# 需求拆解方法

與產品、tracker 無關。固定六步，每一步有明確產出；✔ 表示必須取得使用者確認才進下一步。

| # | 步驟 | 產出 | gate |
|---|---|---|---|
| 0 | 來源入庫 | `<主題>/source/`：來源快照 + README（出處、日期） | — |
| 1 | 釐清並定 Goal | `user-goal.md` 骨架：共同前提 + Goal / Feature（必要時 `CONTEXT.md`） | ✔ 確認骨架 |
| 2 | 寫 Scenario（BDD） | 同一個 `user-goal.md`，Scenario 寫在 Feature 底下 | — |
| 3 | Review | 修正後的 `user-goal.md` + 未決的「來源落差」 | ✔ 確認 |
| 4 | 成卡 | `breakdown.md`（給人讀）+ `cards.json`（固定格式） | ✔ 看完整清單與估點基準 |
| 5 | 交棒 | 由下游照 `cards.json` 建／改卡，回填卡號 | ✔ 明確 go |

一次只推進一步，每步結束停下來給使用者看。不要從需求一路衝到建卡。

語言跟著使用者：使用者用繁體中文就寫 zh-TW，技術名詞（OIDC、Session、Gherkin…）保留英文。

## 從哪一步進、寫到哪裡

- 照使用者手上已有的東西進場：只要 review 既有的 Scenario／GWT → 直接 Step 3，先報告 findings，改檔前取得同意；已有確認過的 `user-goal.md` → Step 4；從頭拆 → Step 0。
- 第一次寫檔前確認主題目錄放哪：沿用 repo 既有的需求／文件目錄慣例；沒有慣例就問，不要自己在 repo 根目錄開新目錄。

## 四條貫穿全程的規則

- **來源沒寫的，不自行補。** 缺口有兩種處理：能問使用者的，照 Step 1／3 的 grill 問，答案**落檔**後才算來源；使用者還沒決定的，記進「來源落差」，寫清楚有幾種讀法、先按哪一種、影響哪幾張卡。不要在拆解過程中替來源做決定。
- **用來源的字。** 角色、狀態、欄位名一律沿用來源的詞；不要自己發明同義詞，也不要把 `pending_verification` 這種狀態值翻成中文。名詞一換，追溯就斷了。
- **決策落檔。** grill 出來的結論當場寫進檔案：規則與 Scenario 進 `user-goal.md`，術語進 `CONTEXT.md`。只留在對話裡的決策等於不存在。
- **交付資料，不是工具。** 要交的是 `user-goal.md`、`breakdown.md`、`cards.json` 這幾個檔案本身，不是產生它們的腳本。需要核對數字就跑完講結果，不要把驗證程式留在 repo。

## Step 0 — 來源入庫

輸入可能是需求文件、wiki／Notion 頁、設計稿（`.png` / `index.html`）、口述。

- **外部來源一律先存進 repo** 再拆：`<主題>/source/` 放原件，加 `README.md` 記出處（URL）、擷取日期、來源自己的最後修改時間。否則來源一改，沒有人說得出當初拆的是哪一版。骨架見 `references/user-goal-format.md`。
- 設計稿另外記版面結構、design token、互動實際做了什麼（沒做的也要寫）。
- 已存在的 `design/` 目錄視同 `source/`，不必搬。
- 口述需求沒有外部來源，直接進 Step 1；使用者的回答由 Step 1 的 grill 落進 `user-goal.md`。
- 先把來源讀完再開口。

## Step 1 — 釐清並定 Goal

用 grill 把模糊的輸入收斂成 Goal / Feature。做法與規則見 `references/review-and-grill.md`。

- 一個 Goal = 一個使用者想達成的結果，用「作為<角色>，我希望<能力>，而不需要<原本的負擔>」寫。**Goal 不是功能清單**，「管理後台」不是 Goal。
- Goal 底下切 Feature：一塊可以獨立驗收的能力。編號 `Goal N` / `Feature N.x`。
- 文件開頭寫「共同前提」，放跨 Goal 都成立的規則（識別鍵、系統職責邊界、正常流程不得做的事）。後面每個 Scenario 都可以引用它，review 時也靠它抓矛盾。
- 設計稿衍生的 Goal 給獨立編號，只描述畫面本身，不描述它屬於誰、點下去去哪裡——那些通常是來源沒寫的東西，要問，不要猜。
- 輸入本來就是結構完整的文件時，不必從頭 grill：直接把文件整理進骨架，缺口留給 Step 3。

收尾：Goal / Feature 骨架給使用者確認後才寫 Scenario。檔案骨架見 `references/user-goal-format.md`。

## Step 2 — 每個 Feature 寫出 BDD

- 每個 Feature 底下寫 `### Scenario N.x.y — 名稱`，用 `**Given** / **When** / **Then** / **And**` 條列。
- **一個 Scenario 一個 `When`。** 需要兩個動作就拆兩個 Scenario。Given 只放前提，不放動作；Then 只放可觀察的結果，不放操作。
- 正常流程、替代流程、被拒絕的流程都要有。只有 happy path 的 Feature 是沒拆完的 Feature。
- 安全性與不變量寫成「不得…」的 Then：不得建立第二筆、不得洩漏帳號是否存在、不得因此授權。這類 Scenario 的實作可能是零行程式碼，但測試必須把它釘住。
- Scenario 是後面 AC 與 Gherkin 的唯一來源，句子要能直接當驗收步驟讀。

## Step 3 — Review

逐條 Scenario 掃 checklist（五類，見 `references/review-and-grill.md`），**每條 Scenario 都要有檢查結果**，不是只列發現的問題。

- 掃出的 findings 排成問題隊列（上游決策先問），照 `references/review-and-grill.md` 的 grill 規則收斂。
- 解掉的當場改 `user-goal.md`（或 `CONTEXT.md`）。
- 使用者還沒決定的，才進步驟 4 的「來源落差」。
- **這裡要有使用者確認點**，確認完才整理建卡。

## Step 4 — 整理成 epic / feature / task

層級對應：

| 來源 | 產出 | 說明 |
|---|---|---|
| Goal | **不開卡** | 當追溯代號 `G01`…，寫進卡片描述的「所屬 Goal」與 `breakdown.md` 的章節 |
| Feature | **一張卡** | Summary 用「身為…我要能夠…以完成…」，描述放 AC + Gherkin |
| Scenario | — | 不另開卡，每個 Scenario 對應 AC 一條 + Gherkin 一段 |
| task | **子項** | 只在某張卡真的需要拆時才開，掛在那張卡底下 |

- Epic／Goal 預設不開卡，只當追溯代號。要開 Epic 卡請使用者明說。
- **Feature 用三段式**：「身為<角色>，我要能夠<能力>，以完成<目的>。」角色取自 Given 的主體，能力取自 When/Then，目的是這張卡對使用者的結果。不要寫成「已完成」。
- **task 直接 task**：直述任務句，不套三段式。母卡點數維持原值當 umbrella，子項不另計點，避免加總重複。
- 一張卡可以合併同一 Feature 底下的多個 Scenario；跨 Goal 不合卡。
- 階段／優先序照來源抄。來源沒標就留白，不要自己指派。
- 產出兩個檔案：`breakdown.md`（給人讀，含來源落差）與 `cards.json`（固定格式，給建卡用）。同一份內容兩種形狀，卡數／點數／Summary 必須一致。沒有 `cards.json` 就不要進步驟 5。
- 前綴、估點單位等主題設定放 `cards.json` 的 `meta`；label、assignee 等 tracker 專屬設定放 `meta.target`，由下游建卡流程填。這些都不寫進 skill。

Schema、描述組裝模板與建卡前的人工過目清單見 `references/breakdown-json-format.md`。

### 估點

先跟使用者確認三件事再估，不要沿用上一個專案的假設：**一點等於什麼**（小時？抽象點數？）、**一天算幾點**、**開發方式**（AI 開發與純人工的點數不可互換）。下游 tracker 若固定了單位，以 tracker 為準。

不管單位是什麼，這幾條照做：

- 明寫一點**包含**什麼（實作、對應測試、人工 review 與跑過驗收、同一張卡內反覆修正到 AC 全綠）與**不包含**什麼（規格澄清、技術選型、環境建置、其他系統端的接線、安全審查、部署）。估點會被引用，基準沒寫等於沒估。
- **實際超過偏好上限就填實際值**，不要為了符合上限把數字壓小。要拆卡是因為它可以獨立驗收，不是因為點數難看。
- 點數高的理由要寫一句：分支多、要釘住「不得發生」的行為、狀態機難想清楚——這些跟程式碼行數無關。
- 「來源落差」裡尚未決定的項目，估點時寫明採哪一種讀法；那段工夫不在點數內。
- 把合計換算成工作天時講清楚假設（單一條工作流、不平行）。

## Step 5 — 交棒

- **只照 `cards.json` 建卡**，不要從 markdown 或對話記憶湊欄位。
- 建卡前把完整清單給使用者、**等明確的 go**。這是對外動作，一次幾十張卡收回來很痛。
- **create 或 update 由 `key` 決定**：`key` 為 null → 建新卡；有值 → 這張卡已存在，**先讀 tracker 上的現況再動手**。卡建出去後常會在 tracker 被人改過（AC 重寫、加子項、換狀態），直接用 `cards.json` 覆蓋會抹掉那些修改。要改就只改來源變動影響到的欄位，並把差異給使用者看過。
- **每建一張立刻回填 `key`**，不要等全部建完。中途失敗時，`key` 非 null 的卡重跑會被跳過，不會重複開卡。
- 建完**讀回來核對**：張數、狀態、指派人、點數總和，逐項對 `cards.json` 的 `meta.totals`。不要假設建卡成功。
- 報告時給實際卡號範圍，不要只說「建好了」。

來源之後有變動時，從受影響的步驟重進：改 `user-goal.md` → 重做 Step 3 → 更新 `cards.json` → 依上面的 update 規則處理已建的卡。

具體要建到哪個系統、欄位怎麼對應、有哪些坑，由下游的建卡流程負責（Jira 見 `requirement-to-jira`）。
