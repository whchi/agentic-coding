---
description: Build and run scoped acceptance tests, including real-browser verification with Chrome DevTools MCP and browser Back, Forward, and Reload state checks.
---

# /qa

根據使用者指定的範圍，或目前已完成的卡片、Acceptance Criteria、相關程式碼與現有測試，建立並執行自動化測試與必要的真實瀏覽器驗證。

先列出本次變更、驗收條件與對應測試範圍。以需求和既有契約判定預期結果，不要把目前實作直接當成正確答案；若預期行為不明且影響判定，先釐清，再寫斷言。

## 職責邊界

- QA 負責產生驗收證據；`code-review` 負責審查變更與證據，不因執行 QA 而自動啟動完整 code review
- 測試層級、mock / fake / real 與 fixtures 的通用判斷，使用可用的 `testing-strategy` skill，並遵守專案明定的限制；skill 不可用時依既有測試慣例執行，不自行安裝
- `better-test-driven-development` 負責測試驅動的產品實作，不因 QA 發現失敗就自動進入修改產品程式的流程
- 已在 `feature-loop verify` 中驗收時，由該流程管理輪次、狀態與修復；本 command 提供驗收方法，不另開一套驗證循環
- 同一程式狀態、環境與測試範圍的可查證結果可以共用；只有變更、證據不足或新風險才補跑，不因切換 QA / review 入口重跑同一批測試
- 專案已有 `verify-<app>` skill（由 `verification-harness` 產生）時，真實 app 的操作依它的 Launch、Doctor、Drive、Evidence、Cleanup 執行；本次變更觸及的功能，以它 feature map 列出的所有入口為驗收範圍。feature map 與實際行為不符時，回報並建議執行 `verification-harness` 的 scoped refresh，不在 QA 中修改它

## 測試要求

- 驗證主要 Happy Path、重要錯誤情境、edge cases 與受影響的 regression
- 適用時驗證權限、404/403、錯誤 ID、URL manipulation 等情境
- 優先沿用專案既有測試框架與測試結構
- API、business logic、authorization 等情境優先使用程式化測試
- Unit Tests 的第三方依賴全部 mock；不要把這個限制套用成 UI 測試只能驗證 mock 畫面
- 本 command 授權新增或調整測試並執行驗證；發現產品缺陷時回報，不要自行修改 production behavior
- 實際執行新增與相關既有測試；缺少環境、帳號或工具時，回報未驗證項目與原因，不得以 mock 結果宣稱真實流程通過

## 真實瀏覽器驗證

本次變更涉及 UI、Routing、Browser State 或使用者互動流程時，必須執行真實瀏覽器驗證，不得僅以 Unit Tests、API Tests、Mock UI 或靜態程式碼分析取代。

### 工具選擇

- **Chrome DevTools MCP**：優先用於真實瀏覽器操作與互動驗收，包含點擊、輸入、導覽、畫面狀態、Network、Console 與 Browser History
- **Playwright**：用於建立及執行可重複的 E2E / Regression Tests，驗證完整使用者流程與資料狀態
- 若既有 Playwright 測試已完整覆蓋本次驗收條件，且具備可查證的真實瀏覽器執行證據，可直接共用，不必重複使用 Chrome DevTools 驗證相同情境
- Chrome DevTools MCP 不可用時，可使用 Playwright 或專案既有的真實瀏覽器工具完成等效驗證，並記錄替代方式
- 不因工具不可用而自行安裝額外工具，除非使用者明確授權

### 驗證原則

1. 實際操作受影響的 UI 流程，不得僅透過 API 呼叫模擬使用者操作
2. 驗證具體欄位值、資料內容、選取狀態、互動結果與頁面導覽，不能只確認元素存在或頁面沒有報錯
3. 檢查相關 Network Request、Response、HTTP Status 與 Console Error，確認沒有影響驗收條件的異常
4. 涉及新增、修改、刪除時，驗證資料持久化結果；適用時透過 API、Network 或資料庫確認
5. 等待可觀察的載入完成條件再斷言，避免固定 sleep
6. 必要時保留 Screenshot、Trace、Console Log 或 Network Evidence，並對應具體驗收條件
7. 每個不同的行為規則選代表案例，不對所有操作排列組合

### 完成標準

- **Passed**：本次適用的自動化測試與必要的真實瀏覽器驗證均已通過，具備可查證證據
- **Failed**：已執行驗證且發現不符合需求或既有契約的行為
- **Partial**：部分驗收已完成，但仍有必要項目未驗證，例如缺少真實瀏覽器驗證、帳號、環境或工具
- **Pending Integration**：Worktree 局部驗證已完成，但依計畫必須等串行合併後才能執行完整 Feature / E2E Suite

若本次包含 UI 變更，只有程式化測試通過、缺少必要的真實瀏覽器驗證證據時，不得標記 Passed。

沒有相關 UI 變更時，真實瀏覽器驗證可標記為 Not Applicable，不影響其他驗收結果。

## Worktree 驗證範圍

使用 worktree 開發時，遵守以下順序：

**平行開發與局部驗證 → 串行合併 → 完整 Feature / E2E Suite**

- Worktree 可跑 Unit Tests、Lint、Type-check；Feature / E2E 僅跑自身修改範圍，先選定測試檔案或案例
- 局部測試可跨元件驗證本次修改，但不得擴大到無關流程；無法限定測試範圍時，回報限制並留待合併後執行
- Chrome DevTools MCP 的真實瀏覽器驗證同樣遵守 Worktree 範圍限制，不操作無關功能
- 若多個 Worktree 共用瀏覽器或測試環境，避免互相覆蓋 Session、資料與狀態；無法隔離時改為串行驗證
- 不建立臨時分支組合、試合併或跨 Worktree 測試矩陣
- 完整 Feature / E2E Suite 只在計畫中的串行合併全部完成後，針對整合結果執行
- 執行 QA 不代表授權合併分支；合併尚未完成時，將完整套件標記為 Pending Integration

## 畫面狀態測試

針對本次調整涉及的頁面與流程，透過真實瀏覽器驗證「上一頁（Back）、下一頁（Forward）、重整（Reload）」後的狀態。

這裡指瀏覽器歷史導覽；若本次修改包含列表分頁，也要另測畫面上的上一頁／下一頁按鈕。

沒有相關 UI 變更時，標記 Not Applicable。

### 1. 定義狀態保存規則

先列出適用的狀態，例如：

- URL path / query / hash
- 篩選、排序、頁碼
- 分頁籤、選取項目
- 表單草稿與已儲存資料

逐項寫明 Back、Forward、Reload 後應保留、重設或重新載入的值及其需求依據。

不要假設所有狀態都必須保留；不適用的項目略過。

### 2. Back / Forward

使用 Chrome DevTools MCP 或等效的真實瀏覽器工具：

1. 透過 UI 建立有差異的歷史狀態，例如列表設定篩選與頁碼後進入詳細頁
2. 執行真正的 Browser Back，確認回到預期 URL、畫面與狀態
3. 執行真正的 Browser Forward，確認再次進入正確頁面與資料
4. 驗證具體欄位值、選取項目與資料內容

不得使用直接開啟 URL 代替 Back / Forward。

### 3. Reload

在具有代表性的狀態執行 Browser Reload：

1. 確認 URL 與畫面一致
2. 確認應保存的資料仍然存在
3. 確認暫存狀態依契約保留或重設
4. 涉及資料提交時，確認 Reload 或歷史導覽不會重複寫入
5. 必要時透過 Network 或 API 驗證資料狀態

### 4. 證據與覆蓋範圍

- 等待可觀察的載入完成條件再斷言，沿用專案既有做法，避免固定 sleep
- 驗證具體欄位值、選取狀態與資料內容，不能只確認頁面可見或沒有報錯
- 必要時保留 Screenshot、Trace 或 Network Evidence
- 每個不同的狀態保存規則選代表案例，不排列組合所有篩選、頁碼與導覽順序
- Worktree 中只測本次修改範圍，完整 Regression 留到串行合併後

## 完成後回報

### 1. 驗收範圍

- 本次變更內容
- Acceptance Criteria
- 新增或調整的測試，以及對應驗收條件

### 2. 自動化測試結果

- 實際執行的命令
- 測試檔案、案例與範圍
- Passed / Failed / Skipped 數量
- 相關失敗原因

### 3. 真實瀏覽器驗證結果

- 使用工具：Chrome DevTools MCP / Playwright / 其他
- 實際操作的 UI 流程
- Back / Forward / Reload 的狀態驗證結果
- Network / Console 檢查結果
- 可用的 Screenshot、Trace 或其他驗收證據
- 區分自動化 E2E 與互動式瀏覽器驗證，不得混為一談

### 4. 問題與未驗證項目

- 發現的問題及嚴重程度
- 重現步驟、Expected / Actual
- 未驗證項目與原因
- 是否仍待 Worktree 串行合併後執行完整套件
- 未執行的項目不得寫成通過

### 5. 最終 QA 狀態

依據實際驗收證據，標記：

- Passed
- Failed
- Partial
- Pending Integration

明確說明狀態理由，不得將測試建立成功、Mock 測試通過或頁面可以載入，直接等同於功能驗收通過。
