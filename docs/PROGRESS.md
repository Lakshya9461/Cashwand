# 📊 Project Progress Log

## Mobile Expense & Income Tracker

**Last Updated:** 2026-02-26 12:50 IST
---
## Current Status: 💸 Multi-Profiles, PIN Lock, & CashWand Rebrand Shipped

Full MVP of tracking + new financial planning features + multi-profile isolation + PIN/Biometric security boundaries implemented and passing all tests (60/60). App architecture expanded to support security routing cleanly using GoRouter intercept rules and Android platform bindings to biometric services.

---

## Completed Work

### Phase 0: Brainstorming & Requirements (Completed)

#### 0.1 — Project Ideation
- **Date:** 2026-02-25
- **What:** Used the structured brainstorming skill to define the project scope
- **Outcome:** Established core concept — a lightweight mobile expense & income tracker for students and young professionals
- **Key Principle:** Financial awareness without complexity; log a transaction in <5 seconds

#### 0.2 — Product Requirements Document (PRD)
- **Date:** 2026-02-25
- **File:** [`docs/PRD.md`](./PRD.md)
- **What:** Converted the detailed project description into a structured PRD including:
  - ✅ Product goals with measurable success metrics
  - ✅ 2 target personas (College Student "Aisha", Young Professional "Raj")
  - ✅ 12 MVP user stories + 6 post-MVP stories with priorities (P0–P3)
  - ✅ Explicit MVP scope (what's IN and what's OUT)
  - ✅ Non-functional requirements (performance, offline, app size, accessibility)
  - ✅ Constraints and assumptions documented
  - ✅ KPIs — both product and engineering metrics
  - ✅ Risk assessment with mitigations
  - ✅ Decision log (5 key architectural decisions)
  - ✅ Future roadmap (v1.1 → v2.x)

#### 0.3 — Key Decisions Made
| # | Decision | Choice |
|---|----------|--------|
| D1 | Platform | Flutter (changed from original PWA spec) — better native UX |
| D2 | Storage | SQLite local-first — no auth needed for MVP |
| D3 | State management | Provider — simplest, official recommendation |
| D4 | Categories | Predefined (8 types) — reduces MVP complexity |
| D5 | Currency | INR single currency — target audience focused |

---

### Phase 1: Environment Setup (Completed)

#### 1.1 — Flutter SDK Installation
- **Date:** 2026-02-25
- **What:** Installed Flutter SDK to `C:\flutter`
- **Version:** Flutter 3.41.2 (stable), Dart 3.11.0
- **PATH:** Added `C:\flutter\bin` to user PATH permanently

#### 1.2 — VS Code Extensions
- **Date:** 2026-02-25
- **What:** Flutter and Dart extensions installed in VS Code
- **Purpose:** Syntax highlighting, autocomplete, debugging support

#### 1.3 — Environment Health Check
- **Date:** 2026-02-25
- **Command:** `flutter doctor`
- **Results:**
  - ✅ Flutter 3.41.2 (stable channel)
  - ✅ Dart 3.11.0
  - ✅ Windows 11 Education 64-bit (24H2)
  - ✅ Chrome 145 available
  - ✅ Visual Studio Build Tools 2022
  - ✅ Network resources available

#### 1.4 — Setup Guide Created
- **File:** [`docs/SETUP_GUIDE.md`](./SETUP_GUIDE.md)
- **What:** Step-by-step guide covering Flutter installation, project creation, folder structure, dependencies, and running the app

---

### Phase 2: Project Scaffolding (Completed)

#### 2.1 — Flutter Project Creation
- **Date:** 2026-02-25
- **Command:** `flutter create --org com.expensetracker --project-name expense_tracker --platforms android,ios,web .`
- **Location:** `g:\pet projects\finance app\`
- **Platforms:** Android, iOS, Web

#### 2.2 — Clean Architecture Folder Structure
- **Date:** 2026-02-25
- **What:** Created the following layered architecture inside `lib/`:

```
lib/
├── core/              → Shared constants, theme, utilities, extensions
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── extensions/
├── data/              → Data models, SQLite database, repository implementations
│   ├── models/
│   ├── database/
│   └── repositories/
├── domain/            → Pure business logic — entities, enums, interfaces
│   ├── entities/
│   ├── enums/
│   └── repositories/
├── presentation/      → UI screens, state providers, navigation
│   ├── screens/
│   │   ├── dashboard/widgets/
│   │   ├── add_transaction/widgets/
│   │   ├── history/widgets/
│   │   └── insights/widgets/
│   ├── providers/
│   └── navigation/
└── shared/            → Reusable widgets (bottom nav, empty states)
    └── widgets/
```

#### 2.3 — Dependencies Configured
- **Date:** 2026-02-25
- **File:** `pubspec.yaml`
- **What:** Added minimal, purpose-driven dependencies:

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | Lightweight state management |
| `sqflite` | ^2.3.3+2 | Offline SQLite database |
| `path` | ^1.9.0 | File path utilities for DB |
| `fl_chart` | ^0.69.2 | Pie charts for spending insights |
| `go_router` | ^14.8.1 | Declarative navigation |
| `intl` | ^0.19.0 | Date & currency formatting |
| `uuid` | ^4.5.1 | Unique transaction IDs |
| `shared_preferences` | ^2.5.4 | Web local storage persistence |
| `mockito` | ^5.4.4 | Testing mocks (dev) |
| `build_runner` | ^2.4.13 | Code generation (dev) |

- **Result:** `flutter pub get` ✅ succeeded

#### 2.4 — Quality Verification
- **Date:** 2026-02-25
- **Results:**
  - `flutter analyze` → ✅ No issues found
  - `flutter test` → ✅ All tests passed
  - `flutter run -d chrome` → ✅ App launched successfully on localhost:8080

---

## Files Created/Modified

| File | Type | Description |
|------|------|-------------|
| `docs/PRD.md` | 📋 New | Product Requirements Document |
| `docs/SETUP_GUIDE.md` | 📋 New | Flutter setup step-by-step guide |
| `docs/PROGRESS.md` | 📋 New | This progress log |
| `pubspec.yaml` | ✏️ Modified | Added 8 dependencies, updated description |
| `lib/` (17 directories) | 📁 New | Clean architecture folder structure |
| `lib/domain/enums/transaction_type.dart` | 🆕 New | Income/Expense enum with label & sign multiplier |
| `lib/domain/enums/category_type.dart` | 🆕 New | 9 predefined categories with display labels |
| `lib/domain/entities/transaction_entity.dart` | 🆕 New | Immutable, self-validating core entity |
| `lib/domain/repositories/i_transaction_repository.dart` | 🆕 New | Abstract repository interface (9 async methods incl. deleteAll) |
| `docs/DOMAIN_RULES.md` | 📋 New | Clean architecture contract — dependency rules, conversion patterns, good vs bad examples |
| `test/domain/enums/transaction_type_test.dart` | 🧪 New | 5 tests: value count, sign multipliers, labels |
| `test/domain/enums/category_type_test.dart` | 🧪 New | 6 tests: value count, label validity, uniqueness, key categories |
| `test/domain/entities/transaction_entity_test.dart` | 🧪 New | 32 tests: construction, validation, computed props, equality, copyWith |
| `lib/data/models/transaction_model.dart` | 🆕 New | SQLite serialization (toMap/fromMap) + domain conversion (toEntity/fromEntity) |
| `lib/data/database/app_database.dart` | 🆕 New | SQLite singleton with lazy init, table schema, indexes, migration placeholder |
| `lib/data/database/transaction_dao.dart` | 🆕 New | Raw SQL operations isolated from business logic (incl. deleteAll) |
| `lib/data/repositories/transaction_repository.dart` | 🆕 New | Implements ITransactionRepository, bridges Entity↔Model↔DAO |
| `lib/data/repositories/web_transaction_repository.dart` | 🆕 New | SharedPreferences-backed repository for web (persistent browser storage) |
| `test/data/models/transaction_model_test.dart` | 🧪 New | 15 tests: fromEntity, toMap, fromMap, toEntity, round-trip conversion |
| `lib/core/constants/app_colors.dart` | 🆕 New | Dark-themed color palette for premium finance feel |
| `lib/core/utils/currency_formatter.dart` | 🆕 New | INR formatting (standard, compact, signed) |
| `lib/core/utils/date_formatter.dart` | 🆕 New | Date formatting (full, short, monthly, relative) |
| `lib/core/theme/app_theme.dart` | 🆕 New | Material 3 dark theme configuration |
| `lib/core/extensions/category_type_extensions.dart` | 🆕 New | icon and color mapping for enum purity |
| `lib/presentation/providers/transaction_provider.dart`| 🆕 New | Central state management with computed balance/totals/daily breakdown |
| `lib/presentation/navigation/app_router.dart` | 🆕 New | go_router configuration with 4 routes |
| `lib/shared/widgets/balance_card.dart` | 🆕 New | Gradient card with debt-aware red/teal coloring |
| `lib/shared/widgets/transaction_list_item.dart` | 🆕 New | Swipeable row for transactions |
| `lib/shared/widgets/empty_state.dart` | 🆕 New | Reusable empty list placeholder |
| `lib/presentation/screens/dashboard/dashboard_screen.dart` | 🆕 New | Main screen with balance, debt-aware FAB, and recent history |
| `lib/presentation/screens/add_transaction/add_transaction_screen.dart` | 🆕 New | Fast-entry form with validation and chip selectors |
| `lib/presentation/screens/history/history_screen.dart` | 🆕 New | Full scrollable history with Clear All + confirmation dialog |
| `lib/presentation/screens/insights/insights_screen.dart` | 🆕 New | Multi-graph analytics: Donut, Income/Expense Bar, Daily Spending |
| `lib/app.dart` | 🆕 New | Root MaterialApp configuration |
| `lib/main.dart` | ✏️ Modified | Platform-aware DI (Web vs Mobile), portrait lock |
| `test/widget_test.dart` | 🧪 Modified | Updated with proper App smoke test + deleteAll stub |

---

## Completed: Phase 3 Domain Layer Design & Review

### 3.0 — Domain Layer Design Review
- **Date:** 2026-02-25
- **What:** Reviewed planned domain layer tasks and proposed clean design
- **Covered:** File locations, entity responsibilities, validation rules, layer interaction diagram
- **Key Decision:** Domain layer has ZERO external dependencies — pure Dart only
- **Key Decision:** Icons mapped in presentation layer, not stored in domain enums
- **Key Decision:** `salary` category added for income entries (original 8 were expense-only)

---

### Phase 3: Domain Layer (Complete ✅)

#### 3.1 — TransactionType Enum ✅
- **Date:** 2026-02-25
- **File:** `lib/domain/enums/transaction_type.dart`
- **Values:** `income` (+1 sign), `expense` (-1 sign)
- **Design:** Carries `label` (display name) and `sign` (multiplier for balance calc)

#### 3.2 — CategoryType Enum ✅
- **Date:** 2026-02-25
- **File:** `lib/domain/enums/category_type.dart`
- **Values:** food, transport, shopping, bills, entertainment, health, education, salary, other (9 total)
- **Design:** Carries `label` only — icons are a UI concern

#### 3.3 — TransactionEntity ✅
- **Date:** 2026-02-25
- **File:** `lib/domain/entities/transaction_entity.dart`
- **Fields:** id (String), amount (double), type, category, description, date, createdAt
- **Immutability:** All fields `final`, modifications via `copyWith()`
- **Validation:** amount > 0, amount ≤ 10M, description ≤ 100 chars, no future dates
- **Equality:** Identity-based (`id` field) — same id = same transaction
- **Computed:** `signedAmount`, `isIncome`, `isExpense`
- **Purity:** No JSON, no SQLite, no Flutter imports
- **Verification:** `flutter analyze` → No issues found ✅

#### 3.4 — ITransactionRepository Interface ✅
- **Date:** 2026-02-25
- **File:** `lib/domain/repositories/i_transaction_repository.dart`
- **Methods:** 9 async methods (insert, getAll, getById, getByDateRange, getByCategory, update, delete, deleteAll, getMonthlySummary)
- **Retrieval:** `Future<List<>>` over `Stream` — SQLite queries are one-shot reads, Provider handles reactivity
- **Error handling:** Entity validation catches bad data; storage errors propagate naturally; no custom exceptions for MVP
- **Ordering:** Results newest-first by default
- **Verification:** `flutter analyze` → No issues found ✅

#### 3.5 — Domain Unit Tests ✅
- **Date:** 2026-02-25
- **Files:** 3 test files in `test/domain/`
- **Total Tests:** 43 passing
- **Breakdown:**
  - `transaction_type_test.dart` — 5 tests (value count, signs, labels)
  - `category_type_test.dart` — 6 tests (count, labels, uniqueness, key categories)
  - `transaction_entity_test.dart` — 32 tests across 8 groups:
    - Construction (8): valid creation, createdAt auto-set, boundary amounts/descriptions
    - Amount validation (4): zero, negative, exceeds max, small negative
    - Description validation (2): 101 chars, 1000 chars
    - Date validation (3): future rejected, past allowed, very old allowed
    - Computed properties (4): signedAmount for income/expense, isIncome/isExpense
    - Equality (6): same id, different id, hashCode, identity, non-entity, Set dedup
    - copyWith (4): update field, preserve others, validate copy, change type
    - toString (1): contains key fields
- **Command:** `flutter test test/domain/ --reporter expanded`
- **Result:** 43/43 passed in <1 second ✅

---

### Phase 4: Data Layer (Complete ✅)

#### 4.1 — TransactionModel ✅
- **Date:** 2026-02-25
- **File:** `lib/data/models/transaction_model.dart`
- **Serialization:** `toMap()` / `fromMap()` for SQLite
- **Conversion:** `toEntity()` / `fromEntity()` for domain mapping
- **Date format:** ISO 8601 strings (sort correctly in lexicographic order)
- **Enum format:** Stored as `.name` strings (e.g., "expense", "food")
- **Safety:** Handles SQLite int→double casting, null description defaults

#### 4.2 — AppDatabase ✅
- **Date:** 2026-02-25
- **File:** `lib/data/database/app_database.dart`
- **Pattern:** Singleton with lazy initialization
- **Database:** `expense_tracker.db`, version 1
- **Table:** `transactions` with 7 columns (id PK, amount, type, category, description, date, created_at)
- **Indexes:** 3 indexes (date DESC, category, type+date composite)
- **Migration:** Placeholder with example pattern for future schema changes

#### 4.3 — TransactionDao ✅
- **Date:** 2026-02-25
- **File:** `lib/data/database/transaction_dao.dart`
- **Methods:** insert, queryAll, queryById, queryByDateRange, queryByCategory, queryMonthlySummary, update, delete, deleteAll
- **Conflict:** Uses `ConflictAlgorithm.replace` for upsert behavior
- **Ordering:** All queries return newest-first (ORDER BY date DESC)
- **Aggregation:** Monthly summary uses GROUP BY type with COALESCE

#### 4.4 — TransactionRepository ✅
- **Date:** 2026-02-25
- **File:** `lib/data/repositories/transaction_repository.dart`
- **Implements:** `ITransactionRepository` (all 9 methods)
- **Pattern:** Entity → Model.fromEntity() → model.toMap() → DAO → fromMap() → toEntity()
- **Monthly summary:** Calculates first/last day of month, initializes {income: 0.0, expense: 0.0}
- **DI:** Accepts optional DAO parameter for testing

#### 4.5 — WebTransactionRepository ✅
- **Date:** 2026-02-25
- **File:** `lib/data/repositories/web_transaction_repository.dart`
- **Purpose:** Browser-compatible repository using `shared_preferences` for persistence
- **Storage:** JSON-serialized transactions in browser localStorage
- **Lazy init:** Loads from storage on first access, saves on every mutation
- **Implements:** `ITransactionRepository` (all 9 methods)

#### 4.6 — Data Layer Tests ✅
- **Date:** 2026-02-25
- **File:** `test/data/models/transaction_model_test.dart`
- **Total Tests:** 15 passing
- **Coverage:**
  - fromEntity (3): field mapping, income type, empty description
  - toMap (3): column names, ISO 8601 dates, enum strings
  - fromMap (3): field parsing, null description, int→double amount
  - toEntity (4): valid conversion, all categories, all types, corrupt data detection
  - Round-trip (2): full Entity→Model→Map→Model→Entity fidelity, all categories

#### Verification
- `flutter analyze` → No issues found ✅
- `flutter test test/data/ test/domain/` → 58/58 passed ✅

---

### Phase 5: Presentation Layer (Complete ✅)

#### 5.1 — Dashboard Screen ✅
- **Date:** 2026-02-25
- **File:** `lib/presentation/screens/dashboard/dashboard_screen.dart`
- **Features:** Glanceable balance card, monthly summary, top 5 recent transactions, pull-to-refresh, navigation to history and add.
- **Debt awareness:** FAB color changes to red when balance < 0.
- **State handling:** Loading indicator, error view with retry, empty state widget.

#### 5.2 — Add Transaction Screen ✅
- **Date:** 2026-02-25
- **File:** `lib/presentation/screens/add_transaction/add_transaction_screen.dart`
- **Features:** Auto-focus amount, type toggle (auto-updates category), category chip grid, date picker, validation.
- **Optimizations:** <5 second entry flow, keyboard optimized.

#### 5.3 — History Screen ✅
- **Date:** 2026-02-25
- **File:** `lib/presentation/screens/history/history_screen.dart`
- **Features:** Full scrollable history, swipe-to-delete with undo snackbar.
- **Clear All:** Trash icon in AppBar with confirmation dialog to wipe all transactions.

#### 5.4 — Insights Screen ✅
- **Date:** 2026-02-25 (enhanced 2026-02-26)
- **File:** `lib/presentation/screens/insights/insights_screen.dart`
- **Charts (3):**
  1. **Donut Chart** — Category spending breakdown with "Total Spent" center label
  2. **Income vs Expense Bar Chart** — Side-by-side comparison with semantic coloring
  3. **Daily Spending Bar Chart** — Day-by-day expense trend for the current month
- **Sorting:** Categories ranked highest-to-lowest spending.
- **Card layout:** Legend grouped in elevated surface containers.

#### 5.5 — Transaction Provider ✅
- **Date:** 2026-02-25
- **File:** `lib/presentation/providers/transaction_provider.dart`
- **Responsibilities:** In-memory transaction list, loading/error states, cross-layer coordination (calls repository).
- **Computed logic:** Total balance, monthly income/expense, monthly savings, category breakdown, daily expense breakdown.
- **Actions:** load, add, delete, deleteAll (clear history) transactions.

#### 5.6 — Navigation ✅
- **Date:** 2026-02-25
- **File:** `lib/presentation/navigation/app_router.dart`
- **Routes:** `/` (Dashboard), `/add` (Modal-style slide entry), `/history` (Full list), `/insights` (Analytics).
- **Library:** `go_router`.

#### 5.7 — Core & Shared Components ✅
- **Theme:** Material 3 dark theme (`app_theme.dart`).
- **Colors:** Deep teal palette with semantic coding (`app_colors.dart`).
- **Extensions:** Category icons/colors mapped in presentation (`category_type_extensions.dart`).
- **Utils:** INR currency and date formatting helpers.
- **Widgets:** `BalanceCard` (debt-aware gradient), `TransactionListItem`, `EmptyState`.

#### 5.8 — Project Fixes ✅
- **Lint:** Fixed missing braces in flow control.
- **Async:** Fixed `use_build_context_synchronously` in `initState` microtask via mounted checks.
- **Tests:** Updated default `widget_test.dart` to a real `App` smoke test with fake repository.

#### Verification
- `flutter analyze` → No issues found ✅
- `flutter test` → 59/59 passed (including 1 widget test) ✅

---

### Phase 6: Polish & Hardening (Complete ✅)

#### 6.1 — Debt Warning UI ✅
- **Date:** 2026-02-25
- **What:** Balance card gradient shifts from teal → red when balance < 0
- **Scope:** BalanceCard shadow, FAB button color both react to debt state

#### 6.2 — Clear History ✅
- **Date:** 2026-02-25
- **What:** Added `deleteAll()` across the entire stack (Interface → DAO → Repository → Provider → UI)
- **UX:** Trash icon in History AppBar → Confirmation dialog → Instant wipe

#### 6.3 — Web Persistence ✅
- **Date:** 2026-02-25
- **What:** Replaced in-memory web repository with SharedPreferences-backed storage
- **Effect:** Transactions survive browser tab close/refresh

#### 6.4 — Portrait Lock ✅
- **Date:** 2026-02-26
- **What:** `SystemChrome.setPreferredOrientations` locks to portraitUp/portraitDown
- **Scope:** Applied globally in `main.dart` before `runApp`

#### 6.5 — minSdk Pinned ✅
- **Date:** 2026-02-26
- **What:** Set `minSdk = 21` explicitly in `android/app/build.gradle.kts`
- **Effect:** Guarantees compatibility with Android 5.0+ (99.5% of active devices)

---

### Phase 7: Android APK Build (Complete ✅)

#### 7.1 — Android SDK Setup ✅
- **Date:** 2026-02-26
- **What:** Android Studio installed at `G:\Software\Android Studio`, SDK at `G:\Software\Android SDK`
- **Config:** `flutter config --android-sdk "G:\Software\Android SDK"`

#### 7.2 — Build Issues Resolved ✅
- **Date:** 2026-02-26
- **Issues fixed:**
  1. **CMake not found** — SDK path contained a space; resolved by adding `cmake.dir` to `gradle.properties`
  2. **Kotlin incremental cache failure** — Space in project path broke Kotlin daemon; resolved by setting `kotlin.incremental=false`
- **File:** `android/gradle.properties`

#### 7.3 — Release APK Generated ✅
- **Date:** 2026-02-26
- **Command:** `flutter build apk --release`
- **Output:** `build/app/outputs/flutter-apk/app-release.apk`
- **Size:** 54.0 MB
- **Signing:** Debug key (suitable for personal use and portfolio demos)
- **Font tree-shaking:** CupertinoIcons 99.7% reduction, MaterialIcons 99.7% reduction

---

## Final Test Results

| Suite | Tests | Status |
|-------|-------|--------|
| Domain (entity, enums) | 44 | ✅ All passed |
| Data (model mapping) | 15 | ✅ All passed |
| Widget (app smoke test) | 1 | ✅ Passed |
| **Total** | **60** | **✅ All passed** |

---

## Feature Summary

| Feature | Status | Description |
|---------|--------|-------------|
| Add Transaction | ✅ | <5s entry flow with amount, type, category, date |
| Transaction History | ✅ | Full scrollable list with swipe-to-delete + undo |
| Clear All History | ✅ | Trash icon with confirmation dialog |
| Dashboard | ✅ | Glanceable balance, monthly summary, recent transactions |
| Debt Warning | ✅ | Red gradient on balance card + FAB when balance < 0 |
| Insights — Donut Chart | ✅ | Category spending breakdown with total in center |
| Insights — Income vs Expense | ✅ | Side-by-side bar comparison |
| Insights — Daily Spending | ✅ | Day-by-day bar trend for current month |
| Data Persistence (Mobile) | ✅ | SQLite offline-first database |
| Data Persistence (Web) | ✅ | SharedPreferences browser localStorage |
| Portrait Lock | ✅ | App locked to vertical orientation |
| Android APK | ✅ | Release build generated (54 MB) |
| Income Accounts | ✅ | Select Source (Salary, Bank, Cash, etc.) for Income |
| Budget Limits | ✅ | Overall monthly budget limits with progress bars |
| App Lock | ✅ | Biometric authentication (fingerprint/PIN) upon launch |
| Excel Export | ✅ | Export data dynamically scoped by DateTime via Share Intent |
| Custom Categories | ✅ | App-wide custom creation with dynamic fallbacks |
| Default Accounts | ✅ | Multi-account logic with balances and defaults |
| Recurring Transactions | ✅ | Auto-generated schedules with daily/weekly/monthly/yearly frequency |
| Search & Filter History | ✅ | Text search, type/category/date filters, 4 sort modes, date-grouped list |
| Edit Transactions | ✅ | Tap any transaction card to open the pre-filled add form |
| Monthly Trend Charts | ✅ | 6-month historical spending and income comparison |

---

### Phase 8: Financial Planning (Complete ✅)

#### 8.1 — Income Accounts ✅
- **Date:** 2026-02-26
- **What:** Users can now specify where their income comes from (Salary, Cash, Bank, Freelance, Business, Other).
- **Domain:** Created `AccountType` enum and added optional `accountType` to `TransactionEntity`.
- **UI:** Conditional account selector chip grid added to the Add Transaction screen specifically for the Income type.

#### 8.2 — Budget Limits ✅
- **Date:** 2026-02-26
- **What:** Users can set a monthly spending limit to control their budget.
- **Domain:** Created `BudgetEntity` and `IBudgetRepository`.
- **Data:** Implemented v2 schema migration adding the `budgets` table + `account` column on `transactions`.
- **State Mgmt:** Created `BudgetProvider` with computed properties for spent, remaining, warnings (80%), and over-budget (100%).
- **UI:** Global `/budgets` settings screen, visual progress bar added to Dashboard responding to current month's expenses.

---

### Phase 9: Security (Complete ✅)

#### 9.1 — App Lock ✅
- **Date:** 2026-02-26
- **What:** Biometric/PIN authentication locking the app natively.
- **Package:** `local_auth` ^3.x
- **Provider:** `AuthProvider` intercepts `AppLifecycleState.paused` locking the app automatically when backgrounded.
- **Router:** `GoRouter` conditional `refreshListenable` blocks access entirely until successfully navigating the `LockScreen`.
- **Settings:** App Lock can be toggled on/off in the new `/settings` view, persisting state via `SharedPreferences`.

---

### Phase 10: CashWand Rebrand & About (Complete ✅)

#### 10.1 — Rebranding ✅
- **Date:** 2026-02-27
- **What:** Rebranded from "Mobile Expense & Income Tracker" to "CashWand".
- **Brand Personality:** Friendly, Light, Supportive, Clear.

#### 10.2 — About Screen ✅
- **Date:** 2026-02-27
- **What:** Added an `/about` screen accessible from Settings.
- **Content:** App name, description, and developer credit (Lakshya Agarwal).

---

### Phase 11: Security Enhancements (Complete ✅)

#### 11.1 — Custom PIN Lock ✅
- **Date:** 2026-02-27
- **What:** Implemented a custom 4-digit PIN fallback and alternative to biometrics.
- **Components:** Built a reusable `PinPad` widget with haptic feedback and error shaking animations.
- **Security:** PINs are one-way hashed using SHA-256 (`crypto` package) before being stored in `SharedPreferences`.
- **Flow:** Users can set a PIN, test it on the `LockScreen`, and manage it from the `SettingsScreen`.

---

### Phase 12: Multi-Profile System (Complete ✅)

#### 12.1 — Profile Domain & DB Isolation ✅
- **Date:** 2026-02-27
- **What:** Added ability to manage multiple independent financial spaces (e.g., Personal, Business, Household).
- **Domain:** Created `ProfileEntity` and `IProfileRepository`.
- **Data Migration:** Migrated database to v3, adding a `profiles` table and assigning all existing transactions to a default 'Personal' profile (`profile_id` indexing).
- **Data Isolation:** Updated `TransactionRepository` and DAO to strictly scope all reads/writes/deletes by `activeProfileId`.

#### 12.2 — Profile State Management ✅
- **Date:** 2026-02-27
- **Provider:** Created `ProfileProvider` to handle profile lifecycle (create, delete, rename, switch) and persistence via `SharedPreferences`.
- **Reactivity:** Used `ChangeNotifierProxyProvider` in `main.dart` so `TransactionProvider` instantly reloads scoped data whenever `ProfileProvider` changes the active profile.

#### 12.3 — Profile UI ✅
- **Date:** 2026-02-27
- **Switcher:** Replaced static Dashboard title with a `ProfileSwitcher` dropdown + modal bottom sheet.
- **Management:** Built `ProfileManagerScreen` for CRUD operations on financial spaces, accessible via Settings or the Switcher sheet.
- **Safety:** Prevented deletion of the final profile. Automatic fallback to another profile if the active one is deleted.

---

### Phase 13: Custom Categories & Accounts (Backend MVP) (Complete ✅)

#### 13.1 — Domain & Extending Entities ✅
- **Date:** 2026-02-28
- **What:** Replaced static Enums (`CategoryType`, `AccountType`) with `CategoryEntity` and `AccountEntity` supporting String `id`.
- **Refactor:** Migrated `TransactionEntity` and `BudgetEntity` to use string IDs for related categories and accounts.
- **Domain:** Created `ICategoryRepository` and `IAccountRepository`.

#### 13.2 — SQLite Persistance ✅
- **Date:** 2026-02-28
- **DB v4:** Created `CategoryDao` and `AccountDao`, and integrated with `AppDatabase`.
- **Transactions:** Handled safely falling back to 'Other' category and default accounts upon deletion of categories/accounts.

#### 13.3 — Providers & State ✅
- **Date:** 2026-02-28
- **What:** Introduced `CategoryProvider` and `AccountProvider`, making category and account lookups dynamic. 
- **Dependency Map:** `TransactionProvider` now automatically pulls UI metadata like Icons and Colors dynamically via `CategoryProvider` matching `categoryId`.

#### 13.4 — Web Repositories ✅
- **Date:** 2026-02-28
- **What:** Built `WebCategoryRepository` and `WebAccountRepository` for `shared_preferences` web support.

#### 13.5 — App Integration & Testing ✅
- **Date:** 2026-02-28
- **UI Migrated:** Adjusted `AddTransactionScreen`, `InsightsScreen` and `TransactionListItem` to resolve items with Providers.
- **Verification:** 100% of analyzer errors resolved, unit/widget tests verified green!

---

### Phase 14: Category & Account Customization (UI API) (Complete ✅)

#### 14.1 — Category Management UI ✅
- **Date:** 2026-02-28
- **What:** Completed `/category-manager` screen connected to `CategoryProvider`.
- **User actions:** Easily Add, Edit and Delete logic for non-system Categories implemented inside modal. Custom icon and colors choices.
- **Access:** Direct routing established from `SettingsScreen`.

#### 14.2 — Account Management UI ✅
- **Date:** 2026-02-28
- **What:** Completed `/account-manager` view using `AccountProvider`.
- **User actions:** Create, edit, pick icon and securely manage default accounting assignments.
- **Safety:** Automatically blocks orphaned transactions through database fallback assignments and handles cascade default picking securely.

