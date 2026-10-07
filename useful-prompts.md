# 進化
 restate in your own words what you think my goals are and what the problem i'm trying to solve is
# 測試
根據目前已完成的卡片、Acceptance Criteria、相關程式碼與現有測試，建立並執行自動化測試。

要求：

- 驗證主要 Happy Path
- 驗證重要錯誤情境與 edge cases
- 驗證權限、404/403、錯誤 ID、URL manipulation 等情境
- 檢查可能受到影響的 regression
- 優先沿用專案既有測試框架與測試結構
- API、business logic、authorization 等情境優先使用程式化測試
- 需要驗證真實 UI、routing、browser behavior 或完整使用者流程時，使用 Playwright / Browser 測試
- 不要為了測試而修改 production behavior
- 實際執行新增與相關既有測試

完成後只回報：

1. 新增了哪些測試
2. 測試結果
3. 發現哪些問題
4. 若有失敗，說明 Expected / Actual
