# 步驟 4 的兩個產出

同一批內容兩種形狀：`breakdown.md` 給人讀，`cards.json` 給建卡用。卡數、點數、Summary 必須一致，改一邊就要改另一邊。

# `cards.json` — 固定格式

步驟 5 **唯一**的建卡依據。一張卡一個物件，欄位固定。tracker 專屬的東西全部收在 `meta.target` 裡，其餘與任何 issue tracker 無關。

```jsonc
{
  "meta": {
    "subject": "sso",                       // 主題／產品代號
    "summary_prefix": "[sso]",              // Summary 前綴；不用前綴就 null
    "source": ["user-goal.md", "source/"],  // 這批卡的來源（路徑相對於主題目錄）
    "generated_at": "2026-09-21",
    "estimate": {
      "unit": "hour",                       // 一點等於什麼
      "per_day": 5,                         // 一天算幾點
      "premise": "AI 開發"                  // 估點前提，換方式就不能互換
    },
    "target": {},                           // tracker 專屬設定，由下游建卡流程填
    "totals": { "goals": 12, "cards": 29, "scenarios": 74, "points": 112 }
  },

  "goals": [
    {
      "code": "G01",                        // 追溯代號，不開卡
      "title": "使用統一 SSO 登入 Product",
      "phase": "P0",                        // 來源沒標就 null，不要自己指派
      "source_ref": "user-goal.md / Goal 1",
      "user_goal": "作為已建立帳號的使用者，我希望…"
    }
  ],

  "cards": [
    {
      "id": "F01.1",                        // 追溯代號，對應 breakdown.md 的章節
      "goal": "G01",
      "title": "Direct OIDC Login",         // 來源的 Feature 名稱
      "summary": "[sso] 身為…，我要能夠…，以完成…。",   // 原字送進 tracker，含前綴
      "points": 8,
      "acceptance_criteria": ["…", "…"],    // 一條對應一個 Scenario
      "gherkin": "Feature: 1.1 Direct OIDC Login\n\n  Scenario: …",
      "scenario_count": 3,
      "tasks": [                            // 直述任務句；不拆就空陣列
        { "title": "…", "key": null }
      ],
      "key": null                           // null = 尚未建立；有值 = 已存在，建卡後回填
    }
  ]
}
```

- 檔案本身是標準 JSON（上面的 `//` 只是這份說明的註解，實際檔案不要寫註解）。
- `gherkin` 用 `\n` 換行；步驟文字與 `user-goal.md` 的 Scenario 一字不差，只去掉 markdown 粗體與條列符號、加上 `Feature:`／`Scenario:` 表頭與編號。
- `tasks` 有值時，每個物件的 `title` 是一個子項的標題，掛在這張卡底下、不另計點。子項有自己的 `key`，建一張回填一張，重跑時 `key` 非 null 的跳過。
- `key` 決定下游動作：null → 建新卡；有值 → 已存在，先讀 tracker 現況再改（見 `SKILL.md` Step 5）。`cards.json` 是建卡當下的快照，不是 tracker 上卡片的即時內容。
- `points` 的單位由 `meta.estimate` 定義。沒有 `meta.estimate` 的 `cards.json` 不算完成。
- 「來源落差」不進 JSON，只留在 `breakdown.md`——它們是要回頭問人的問題，不是卡。

## 卡片描述的組裝模板（固定，不要即興改）

每張卡的描述由 JSON 欄位照這個順序組出來：

````markdown
## Acceptance Criteria

- <acceptance_criteria[0]>
- <acceptance_criteria[1]>

## Gherkin

```gherkin
<gherkin>
```

## 所屬 Goal

<goal.code> <goal.title>

來源：<meta.source join「、」> / <goal.source_ref>
````

子項的描述留空，內容由母卡帶。

## 建卡前的過目清單（可臨時跑程式核對數字，但不要把腳本留在 repo）

拿 `cards.json` 對 `breakdown.md` 看過這幾項再送出：

- `meta.totals` 與 `breakdown.md` 開頭宣告的數字一致；`cards` 長度 = `totals.cards`；`points` 總和 = `totals.points`
- 每個 `card.id`、`card.summary` 都唯一；`summary` 都是「<前綴> 身為…，我要能夠…，以完成…。」（沒有「已完成」這種錯字）
- 每張卡的 `goal` 都在 `goals` 裡；每個 goal 至少有一張卡
- `acceptance_criteria` 條數 = `scenario_count`；`gherkin` 非空
- `points` 都是正數，沒有為了壓上限而改小的數字
- `meta.estimate` 三個欄位都有值
- 「來源落差」裡每一項都標了影響哪幾張卡，且那幾張卡的點數是按暫採的讀法估的
- 初次建卡前所有 `key` 都是 null；重跑時只有 `key` 為 null 的會被建立

# `breakdown.md` 骨架

章節順序固定。

````markdown
# <主題> — 拆解與建卡清單

來源：`user-goal.md`（<標題>）與 `source/`（<擷取日>）。

**N 張卡**，來自 M 個 goal，合計 S 個 Scenario、P 點。

## 層級對應

| 來源 | 產出 | 說明 |
|---|---|---|
| Goal | 不開卡 | 以 `G01`～`GNN` 當追溯代號，寫在描述的「所屬 Goal」 |
| Feature | 一張卡 | Summary 用「身為…我要能夠…以完成…」，描述放 AC 與 Gherkin |
| Scenario | — | 不另開卡，每個 Scenario 對應 AC 的一條與 Gherkin 的一段 |
| task | 子項 | 只有被拆的卡才有，列在該卡區塊的「Tasks」 |

> 代號是為了可追溯性下的，來源沒有。

## 估點基準

**1 點 = <unit>，每天以 <per_day> 點計。前提：<premise>。**

一點包含：<實作、對應測試、人工 review 與跑過驗收、同卡往返>
一點不包含：<規格澄清、技術選型與環境建置、其他系統端接線、安全審查與部署>

合計 **P 點 ≒ D 個工作天**（單一條工作流、不平行）。

估點時的幾個判斷：

- <哪張卡最大、為什麼不拆>
- <哪些卡點數偏高是因為分支多而不是程式多>
- <哪些卡幾乎都是測試時間，因為要求是「不要做某件事」>

## 階段

| Goal | 標題 | 階段 | 卡數 | 點數 |
|---|---|---|---|---|
| G01 | … | P0 | 3 | 18 |
| | **合計** | | **N** | **P** |

---

# G01｜<Goal 標題>

階段：P0 ／ 3 張卡 ／ 18 點 ／ 來源：`user-goal.md / Goal 1`

> <Goal 的 User Goal 原文>

## F01.1 <Feature 名稱>

**Summary**｜<前綴> 身為<角色>，我要能夠<能力>，以完成<目的>。

**Points**｜8

**Acceptance Criteria**

- <每條對應一個 Scenario，寫成可驗收的一句>

**Gherkin**

```gherkin
Feature: 1.1 <Feature 名稱>

  Scenario: 1.1.1 <情境名稱>
    Given …
    When …
    Then …
```

**Tasks**（只有這張卡需要拆時才寫，直述任務句，不套三段式，子項不另計點）

- <任務一>

---

# 來源落差

以下是拆解時發現、**來源沒有寫**的東西。我沒有替它們開卡，也沒有自行補內容——要補請先回頭改來源。

1. **<一句話標題>** — <有幾種讀法、我先按哪一種寫、影響哪幾張卡>
````

落差條目要具體到能直接拿去問人：誰決定、在哪設定、兩種讀法各是什麼、影響哪幾張卡。
