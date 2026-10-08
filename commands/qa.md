---
description: Build and run scoped acceptance tests, including browser Back, Forward, and Reload state checks for changed UI flows.
---

# /qa

根據使用者指定的範圍，或目前已完成的卡片、Acceptance Criteria、相關程式碼與現有測試，建立並執行自動化測試。

先列出本次變更、驗收條件與對應測試範圍。以需求和既有契約判定預期結果，不要把目前實作直接當成正確答案；若預期行為不明且影響判定，先釐清，再寫斷言。

## 職責邊界

- QA 負責產生驗收證據；`code-review` 負責審查變更與證據，不因執行 QA 而自動啟動完整 code review
- 測試層級、mock / fake / real 與 fixtures 的通用判斷，使用可用的 `testing-strategy` skill，並遵守專案明定的限制；skill 不可用時依既有測試慣例執行，不自行安裝
- `better-test-driven-development` 負責測試驅動的產品實作，不因 QA 發現失敗就自動進入修改產品程式的流程
- 已在 `feature-loop verify` 中驗收時，由該流程管理輪次、狀態與修復；本 command 提供驗收方法，不另開一套驗證循環
- 同一程式狀態、環境與測試範圍的可查證結果可以共用；只有變更、證據不足或新風險才補跑，不因切換 QA / review 入口重跑同一批測試

## 測試要求

- 驗證主要 Happy Path、重要錯誤情境、edge cases 與受影響的 regression
- 適用時驗證權限、404/403、錯誤 ID、URL manipulation 等情境
- 優先沿用專案既有測試框架與測試結構
- API、business logic、authorization 等情境優先使用程式化測試
- 需要驗證真實 UI、routing、browser behavior 或完整使用者流程時，使用專案既有的瀏覽器測試工具，例如 Playwright
- unit tests 的第三方依賴全部 mock；不要把這個限制套用成 UI 測試只能驗證 mock 畫面
- 本 command 授權新增或調整測試並執行驗證；發現產品缺陷時回報，不要自行修改 production behavior
- 實際執行新增與相關既有測試；缺少環境、帳號或工具時，回報未驗證項目與原因，不得以 mock 結果宣稱真實流程通過

## Worktree 驗證範圍

使用 worktree 開發時，遵守以下順序：平行開發與局部驗證 → 串行合併 → 完整 feature / e2e 套件。

- worktree 可跑 unit tests、lint、type-check；feature / e2e 僅跑自身修改範圍，先選定測試檔案或案例
- 局部測試可跨元件驗證本次修改，但不得擴大到無關流程；無法限定測試範圍時，回報限制並留待合併後執行
- 不建立臨時分支組合、試合併或跨 worktree 測試矩陣
- 完整 feature / e2e 套件只在計畫中的串行合併全部完成後，針對整合結果執行
- 執行 QA 不代表授權合併分支；合併尚未完成時，將完整套件標記為待執行

## 畫面狀態測試

針對本次調整涉及的頁面與流程，驗證瀏覽器「上一頁（Back）、下一頁（Forward）、重整（Reload）」後的狀態。這裡指瀏覽器歷史導覽；若本次修改包含列表分頁，也要另測畫面上的上一頁／下一頁按鈕。沒有相關 UI 變更時，標記不適用。

1. 先列出適用的狀態，例如 URL path / query / hash、篩選、排序、頁碼、分頁籤、選取項目、表單草稿與已儲存資料，逐項寫明 Back、Forward、Reload 後應保留、重設或重新載入的值及其需求依據。不要假設所有狀態都必須保留；不適用的項目略過。
2. 透過真實 UI 建立有差異的歷史狀態，例如列表設定篩選與頁碼後進入詳細頁。執行 Back，確認回到預期 URL、畫面與狀態；接著執行 Forward，確認再次進入正確頁面與資料。不要用直接開啟 URL 代替 Back / Forward。
3. 在有代表性的狀態執行 Reload，確認 URL 與畫面一致，應保存的資料仍在，暫存狀態依契約保留或重設；若流程涉及提交，確認重整或歷史導覽不會重複寫入。
4. 等待可觀察的載入完成條件再斷言，沿用專案既有做法，避免固定 sleep。驗證具體欄位值、選取狀態與資料內容，不能只確認頁面可見或沒有報錯；必要時保留截圖或 trace 作為證據。
5. 每個不同的狀態保存規則選代表案例，不排列組合所有篩選、頁碼與導覽順序。在 worktree 中只測本次修改範圍，完整 regression 留到串行合併後。

## 完成後回報

1. 新增或調整了哪些測試，以及對應的驗收條件
2. 實際執行的命令、範圍與結果；區分自動化測試和手動瀏覽器驗證
3. Back / Forward / Reload 的狀態驗證結果；若有失敗，附重現步驟、Expected / Actual 與可用的證據
4. 發現的問題、未驗證項目與原因，並標明是否仍待合併後執行完整套件；未執行不得寫成通過
