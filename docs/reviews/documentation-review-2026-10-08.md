# 文件審查（2026-10-08）

## 範圍

本報告保留以下 8 份一般文件的審查紀錄：`AGENTS.md`、`AGENTS.long-running.md`、`README.md`、`README.pi.md`、`CONTEXT.example.md`、`evals/README.md`，以及 `docs/audits/` 的兩份歷史報告。已依使用者要求移除選用模型路由文件及其審查項目。

排除所有 skill 套件、`coding-agent-flow/`、`meta-prompts/` 與既有 commands / prompts 的內容審查。唯一例外是使用者要求將 QA prompt 放入 `commands/`；讀取既有 command 的格式作為依據，不修改其他 command。另讀取 installer、eval runner、policy check 與 `.gitignore`，核對文件描述。

本報告是當日快照。既有歷史 audit 中的 skills findings 未重新驗證，不能當作目前仍存在的問題。

## 已調整

- [README](../../README.md) 的 provider 安裝路徑表混入 `evals/` 與 `CONTEXT.example.md` 兩列，欄位數和語意都不符；已移回 Structure 表格。
- 新增 [QA command](../../commands/qa.md)，保留局部驗證、串行合併後跑整包，以及 Back / Forward / Reload 狀態檢查。補上缺少環境時的回報方式，並明確區分 QA 與產品修復、合併授權。
- `setup.sh` 的 `COMMANDS` 加入 `qa`，README 登錄安裝方式；`AGENTS.md` 和 `useful-prompts.md` 改指向唯一的 QA 來源，避免同一流程維護兩份。
- 保留本次開始前 `AGENTS.md` 與 `useful-prompts.md` 的其他既有修改，不改 skills。
- 後續確認 `qa`、`code-review` 維持 command，`testing-strategy` 維持 skill；分工與相同狀態下共用驗證證據的規則已寫入 README 和 QA command。

## 建議後續調整

| 優先序 | 文件與位置 | 問題與影響 | 最小建議 |
|---|---|---|---|
| 高 | [README](../../README.md) 的 References / UI/UX；`.gitignore` 的 `docs/audits/*` | README 把決策依據指向被忽略、未追蹤的 audit，新 clone 無法讀取，與 AGENTS 的 repo 作為紀錄來源不一致。 | 將仍有效的決策摘要保存到可追蹤的 `docs/decisions/`，README 改連該摘要；歷史報告可繼續保留為本機快照。 |
| 中 | [AGENTS.long-running.md](../../AGENTS.long-running.md) 的 When This Applies | 「提供 ticket」、「3 個檔案」或「5 次工具呼叫」任一條件都觸發長任務筆記，與後文排除小型機械修改的規則不夠一致。短任務也可能被迫建立額外文件。 | 用跨 session、需交接或存在未決設計作為主要條件；檔案數與呼叫數只作輔助訊號，明定小型機械修改的例外優先。 |
| 中 | [AGENTS.md](../../AGENTS.md) 的 Respect Context Budgets | 無專案 budget 時，以輸出品質已明顯下降作為停止訊號，與「下降前停止」的要求存在時序矛盾。 | 改成出現 context 壓力、重複讀取或決策遺失風險時先做 checkpoint；引用 long-running 文件處理詳細交接步驟。 |
| 低 | [README.pi.md](../../README.pi.md) 的套件版本與 Installation commands | 「Installed globally」看似即時狀態，但沒有觀測日期；表格列固定版本，安裝指令卻不帶版本，無法重現表格狀態。 | 明確標示為歷史快照並提供實際查核日期；若目的是重現環境，指令應帶表格版本。不要補猜測日期或宣稱這是目前已安裝版本。 |
| 低 | [CONTEXT.example.md](../../CONTEXT.example.md) 的 Example dialogue | 用「Skill 是完整流程、Command 是單一 prompt」區分兩者，容易被理解成 command 不可含多步驟流程，與本 repo 的 command 形式不符。 | 用包裝和入口區分：skill 是含 `SKILL.md` 的可重用行為包，command 是明確呼叫的 prompt 入口；兩者都可包含多步驟。 |
| 低 | [README](../../README.md) 的 References | 外部參考、安裝操作與核心 repo 使用方式放在同一頁；兩段 OpenCode JSON 設定混在 `bash` code fence，複製整段到 shell 會失敗。 | 將 shell 操作與 `jsonc` 設定拆開；外部參考需要再擴充時，另放參考索引並保留入口。 |

未直接改寫上述政策或歷史資訊，以免把文件 review 擴大成模型路由、版本選擇或決策紀錄重建。

## 其餘文件

- `evals/README.md`：與 runner 的隔離 workspace、stdin / stdout JSON、預設 runs 和環境變數契約一致，沒有發現需要立即修正的內容。可補一句命令從 repo root 執行，以及 exit code 0 / 1 / 2 分別表示通過、測試未全過、輸入或 adapter 設定錯誤。
- 兩份歷史 audits 都含後續修正紀錄；保留原始 findings 與當時驗證結果，不把它們改寫成新的現況報告。上述被忽略的決策依據是目前可直接確認的文件分發問題。

## 驗證

- `git diff --check`、`bash -n setup.sh`：通過。
- `bash tests/command-skill-policy.sh`：通過，包含 command frontmatter 與 source / manifest / README 一致性；這是既有靜態政策檢查，不代表重新審查 skills。
- `./setup.sh all reinstall commands --project qa --target /private/tmp --dry-run`：五個 provider 均通過，未寫入安裝目錄。
- 檢查上述文件、QA 入口與本報告的 13 個本機 Markdown 連結目標：全部存在；README 的 audit 引用原為 inline code，因此另外透過 `git ls-files docs/audits` 與 `.gitignore` 確認其未追蹤狀態。
- QA frontmatter 與 Gemini TOML literal string 分隔符檢查：通過。
- 提交前在新的系統暫存目錄實際安裝 QA 到五個 provider 的 project 路徑：四份 Markdown 與來源完全一致，Gemini TOML 可解析且 description / prompt 與來源一致；未修改使用者的全域安裝。

不在本次驗證範圍：外部連結可用性、第三方套件最新版本、真實 agent 的 command discovery / invocation，以及實際應用程式的 feature / e2e。
