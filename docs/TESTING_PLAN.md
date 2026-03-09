# CashWand Manual Testing Plan

**Drafted:** 2026-02-28
**Scope:** Manual User Acceptance Testing (UAT) focusing on data isolation, UI reactivity, and data integrity with custom entities.

---

## 1️⃣ Step-by-Step Testing Checklist

### Scenario 1: First-Time Setup & Multi-Profile Basics
- [ ] 1. Fresh installation / clear App Data. Launch app.
- [ ] 2. Observe default space ("Personal") is automatically created.
- [ ] 3. Navigate to **Settings > Manage Spaces**.
- [ ] 4. Create a second profile named "Household".
- [ ] 5. Use the dropdown in the Dashboard/Settings to switch between "Personal" and "Household".
- [ ] 6. **Verification (Pass/Fail):** Both spaces start with `$0.00` balances, empty history, and default system categories/accounts. No transactions visible cross-profile.

### Scenario 2: Custom Account Operations & Balance Tracking
-_Stay in "Personal" Profile_
- [ ] 1. Navigate to **Settings > Manage Accounts**.
- [ ] 2. Create a new account named "Cash Wallet" with a custom icon.
- [ ] 3. Create another new account named "Primary Bank" and set it as `Default`.
- [ ] 4. Tap 'Add Transaction' (+) on Dashboard. Ensure both new accounts are selectable in the bottom chip list.
- [ ] 5. Add an **Income** transaction of $5,000 mapping to the "Primary Bank" account.
- [ ] 6. Add an **Expense** transaction of $150 mapped to the "Cash Wallet" account.
- [ ] 7. **Verification (Pass/Fail):** Observe changing total balances on the dashboard. Verify "Primary Bank" balance increases correctly and "Cash Wallet" registers the expense without conflating. 

### Scenario 3: Category Customization & Data Fallback
- [ ] 1. Navigate to **Settings > Manage Categories**.
- [ ] 2. Create a new Category named "Pets" choosing a Green color and Dog/Paw icon.
- [ ] 3. Add a new **Expense** transaction of $80 to "Pets" on the "Primary Bank" account.
- [ ] 4. Navigate to Insights Screen. Verify "Pets" segment shows up Green in the pie chart.
- [ ] 5. Go back to **Manage Categories**. Attempt to delete "Pets". Note the warning about fallback to 'Other'. Confirm deletion.
- [ ] 6. Open History screen.
- [ ] 7. **Verification (Pass/Fail):** Ensure the $80 transaction is now mapped to the "Other" category. Ensure the app did not crash or duplicate the record.

### Scenario 4: Profile Isolation Confirmation
- [ ] 1. Switch back to "Household" via the Profile Manager.
- [ ] 2. Open History screen. Verify list is empty.
- [ ] 3. Open Insights screen. Verify no charts are rendering data from "Personal".
- [ ] 4. Navigate to **Manage Categories**. Verify the "Pets" category (if not deleted in Scenario 3) does not exist here.
- [ ] 5. Add a $200 expense to "Household".
- [ ] 6. Switch back to "Personal".
- [ ] 7. **Verification (Pass/Fail):** Personal dashboard balance holds steady at previous value ($5,000 - $150 - $80). "Household" expense is strictly missing from "Personal" views.

### Scenario 5: Account Deletion Edge-Case
-_Return to "Personal" Profile_
- [ ] 1. By default, "Primary Bank" has transactions. 
- [ ] 2. Add an additional mock "Secondary Bank" via Account Manager.
- [ ] 3. Delete "Primary Bank" via the Account Manager context menu.
- [ ] 4. **Verification (Pass/Fail):** System prevents deletion if it's the *only* account. Assuming > 1 account exists, observe transactions re-mapped to another default/target account. Overall `Total Balance` should remain constant, just reshuffled internally.

### Scenario 6: Stress Test & System Robustness
- [ ] 1. Spam create 20 fast-entry transactions (mix between income/expense) hitting "Save" as fast as possible.
- [ ] 2. Rapidly switch profiles back and forth 5-10 times.
- [ ] 3. Immediately background the app. Wait 5 seconds.
- [ ] 4. Resume the app. (If App Lock is enabled, successfully authenticate).
- [ ] 5. Hard close the app (swipe away).
- [ ] 6. Reopen.
- [ ] 7. **Verification (Pass/Fail):** UI handles spam clicking safely. Profile data correctly reloads every time. Restarting the app persists all changes with no lost state.

---

## 2️⃣ Pass/Fail Criteria

| Test Module | Pass Criteria | Fail Criteria |
| :--- | :--- | :--- |
| **Profile Isolation** | Reads/Writes strictly limited to current dropdown ID. | A transaction leaks into another space. |
| **Integrity Fallback** | Deleting Category -> Moves to "Other". Deleting Account -> Moves to another Account. | App crashes due to null reference. Transactions permanently deleted silently. |
| **Math Integrity** | `Dashboard Balance` is perfectly equal to `Sum(Income) - Sum(Expense)` across selected profile accounts. | Floating point inaccuracies or missed tracking. |
| **Stress Response** | Rapidly switching profiles correctly paints UI. | UI renders in 'Loading' state infinitely or data mismatch occurs on rapid switches. |

---

## 3️⃣ Risk Areas to Monitor

*   **SQLite Concurrency:** Watch for Database locks or race conditions if a user clicks `Save Transaction` extremely rapidly. 
*   **Web Persistence Delay:** In browser testing (`kIsWeb`), UI might paint faster than `SharedPreferences` saves. Ensure transactions actually save on full page reload.
*   **Category Extension Decoding:** If someone managed to insert a bad icon `codePoint` or `color hex` string into SQLite manually, the parser `CategoryEntityUI` might throw `FormatException`. Confirm UI falls back perfectly.
*   **UI Jank on Switch:** When switching a heavily-populated profile, verify the `ListView.builder` history does not physically lag the frame rate while replacing widgets.

---

## 4️⃣ Usability Observations to Record (UX Journal)

As you conduct testing, keep a scratchpad open to note the following human-factors:
*   *Is "Switching Profiles" hidden? Do users know the dashboard header is clickable, or do they only find it in Settings?*
*   *Is it confusing to add a Transaction before explicitly editing the Categories? Should the "Add Transaction" view have a shortcut to create a new category directly?*
*   *Does the color picker in `Manage Categories` feel limiting with just 8 options?*
*   *Does the Biometric PIN pad shake animation feel organic or jarring when typing the wrong password?*

---

## 5️⃣ Suggested Future Improvements (Post-MVP)

1.  **Inline Creation:** Allow users to type a category string in the 'Add Transaction' screen and hit a floating "Create" button on-the-fly instead of needing to navigate to Settings.
2.  **Bulk Management:** Provide a feature to bulk-reassign transactions. (e.g. User wants to delete "Food", but remap to "Groceries" instead of the system "Other").
3.  **Color Wheel UX:** Replace the fixed 8-color circle picker with a sleek Hue slider for more personalization.
4.  **Transfer Types:** Add a native `Transfer` type alongside `Income` and `Expense` so users can track moving money from "Bank" to "Cash" without inflating total reporting.
