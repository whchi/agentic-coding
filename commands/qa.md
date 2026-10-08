---
description: "Build and run acceptance checks for a specified change, including real-browser and history-state verification when UI behavior changes."
---

# /qa

產生本次變更的可查證驗收證據。先從需求、Acceptance Criteria 與既有契約確認預期行為、範圍和完成條件；不可把目前實作當作正確答案。只有影響驗收判定的缺失資訊才需要釐清。

本 command 授權新增或調整測試並執行驗證。產品修復若已在使用者請求內，繼續修復與局部驗證，不重複要求許可；只有 QA 授權時，回報產品缺陷，不自行修改 production behavior。

## 選擇必要的驗證

- 沿用專案框架與測試慣例；需要選測試層級、mock / fake / real 或 fixtures 時，使用可用的 `testing-strategy`，不因缺少 skill 自行安裝。
- 覆蓋本次需求、重要錯誤路徑與受影響的 regression。權限、錯誤 ID、URL manipulation 等案例只在相關行為受影響時加入。
- Unit Tests 的第三方依賴全部 mock；此規則不表示 UI 驗收只能看 mock 畫面。
- 同一程式狀態、環境與範圍的可查證結果可共用。只有修改、失敗、證據不足或新風險才補跑。
- QA 不自動啟動完整 code review；在 `feature-loop verify` 內時，沿用該流程的輪次、狀態與修復管理。
- 若有 `verify-<app>` skill，依其 Launch、Doctor、Drive、Evidence、Cleanup 操作真實 app，覆蓋 feature map 中本次受影響功能的入口。地圖與實際不符時回報，建議 scoped refresh；QA 本身不授權改寫 harness。

## 真實瀏覽器與狀態

涉及 UI、Routing、Browser State 或互動流程時，必須有真實瀏覽器證據。靜態檢查、API Tests 或 Mock UI 不能替代。

優先用可用的 Chrome DevTools MCP 互動驗收，或用 Playwright／專案既有真實瀏覽器工具。已具備完整且可查證的 Playwright 證據時，不重複操作相同情境；記錄實際工具。工具缺失時回報限制，不自行安裝。

- 透過 UI 操作受影響流程，斷言具體欄位值、選取狀態、資料與結果，不只確認元素存在。
- 檢查與驗收條件相關的 Network、HTTP Status 和 Console 異常；涉及寫入時確認持久化結果。
- 等待可觀察的載入條件，避免固定 sleep。必要時保留 Screenshot、Trace、Console 或 Network Evidence。
- 針對每種受影響的狀態規則選代表案例，不排列組合全部操作。

涉及導覽或狀態保存時，先依需求列明 Back、Forward、Reload 後哪些 URL、篩選／排序／頁碼、分頁籤、選取項目、草稿或已存資料應保留、重設或重新載入。

透過 UI 建立有差異的歷史狀態，執行真正的 Browser Back / Forward，再 Reload；核對 URL、畫面和具體資料。不得用直接開啟 URL 代替歷史導覽。寫入流程需確認導覽或 Reload 不會重複提交。若本次改動也包含列表分頁，另測其上一頁／下一頁按鈕。沒有相關行為時標記 Not Applicable。

## Worktree 範圍

遵守 **平行開發與局部驗證 → 串行合併 → 完整 Feature / E2E Suite**：

- Worktree 可跑 Unit Tests、Lint、Type-check；Feature / E2E 先選本次修改的測試檔案或案例。可跨元件驗證此行為，不擴及無關流程。
- 無法限定範圍時，回報限制並留待合併後執行。真實瀏覽器操作遵守相同範圍。
- 共用瀏覽器或環境無法隔離 Session、資料與狀態時，改為串行驗證。
- 不建立臨時分支組合、試合併或跨 Worktree 測試矩陣。
- 完整套件只在計畫中的串行合併完成後，對整合結果執行。QA 本身不授權合併。

## 完成與回報

完成已授權範圍內的測試建立、執行，以及自身測試改動造成的問題修正；缺少必要帳號、環境、工具或產品修復授權時，明列未完成項目。

回報驗收範圍與條件、修改的測試、實際命令與結果、瀏覽器流程與狀態證據、問題的 Expected / Actual 和重現方式，以及未驗證原因。區分自動化 E2E 與互動式瀏覽器證據。

最終狀態依證據判定：

- **Passed**：適用的自動化測試與必要瀏覽器驗證均通過。
- **Failed**：已驗證行為違反需求或契約。
- **Partial**：仍缺必要驗收項目；只有 mock 結果或頁面載入成功不足以通過。
- **Pending Integration**：局部驗證完成，完整套件待計畫中的串行合併後執行。

同時存在失敗與未驗證項目時，兩者都回報，不用單一狀態掩蓋限制。未執行的檢查不得宣稱通過。
