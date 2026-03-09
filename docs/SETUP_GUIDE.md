# 🚀 Flutter Project Setup Guide

## Mobile Expense & Income Tracker

**Goal:** A ready-to-code Flutter environment with clean architecture, all dependencies, and a runnable app.

---

## Step 0: Prerequisites

Before creating the Flutter project, ensure these are installed:

### 0.1 — Install Flutter SDK

1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows/mobile
2. Extract to a permanent location (e.g., `C:\flutter`)
3. Add Flutter to your system PATH:
   ```powershell
   # Add to system environment variables:
   # Variable: PATH
   # Value: C:\flutter\bin
   ```
4. Restart your terminal, then verify:
   ```powershell
   flutter --version
   ```

### 0.2 — Install Android Studio

1. Download from: https://developer.android.com/studio
2. During setup, install:
   - Android SDK
   - Android SDK Command-line Tools
   - Android Emulator
3. Open Android Studio → SDK Manager → install **Android SDK 34** (or latest)
4. Create an Android Virtual Device (AVD):
   - Device: Pixel 7 (or similar)
   - System Image: API 34 (x86_64)

### 0.3 — Verify Environment

```powershell
flutter doctor
```

Fix any issues flagged. The critical checks are:
- ✅ Flutter (channel stable)
- ✅ Android toolchain
- ✅ Android Studio
- ✅ Connected device or emulator

---

## Step 1: Create the Flutter Project

```powershell
# Navigate to project directory
cd "g:\pet projects\finance app"

# Create the Flutter project
flutter create --org com.expensetracker --project-name expense_tracker --platforms android,ios .
```

**Flags explained:**
- `--org com.expensetracker` → Sets the reverse domain for the app package
- `--project-name expense_tracker` → App name (snake_case required)
- `--platforms android,ios` → Only generate mobile platforms (skip web/desktop)
- `.` → Create in current directory

---

## Step 2: Recommended Folder Structure

After creation, restructure `lib/` to follow **clean architecture**:

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
│
├── core/                              # Shared utilities & constants
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette
│   │   ├── app_text_styles.dart       # Typography
│   │   └── app_constants.dart         # Numeric constants, enums
│   ├── theme/
│   │   └── app_theme.dart             # ThemeData configuration
│   ├── utils/
│   │   ├── date_formatter.dart        # Date utility functions
│   │   └── currency_formatter.dart    # ₹ formatting helper
│   └── extensions/
│       └── context_extensions.dart    # BuildContext extensions
│
├── data/                              # Data layer
│   ├── models/
│   │   └── transaction_model.dart     # Transaction data model
│   ├── database/
│   │   ├── app_database.dart          # SQLite database setup
│   │   └── transaction_dao.dart       # Data access object (CRUD)
│   └── repositories/
│       └── transaction_repository.dart # Repository implementation
│
├── domain/                            # Business logic layer
│   ├── entities/
│   │   └── transaction_entity.dart    # Domain entity (pure Dart)
│   ├── enums/
│   │   ├── transaction_type.dart      # income | expense
│   │   └── category_type.dart         # food, transport, etc.
│   └── repositories/
│       └── i_transaction_repository.dart # Repository interface
│
├── presentation/                      # UI layer
│   ├── screens/
│   │   ├── dashboard/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── widgets/
│   │   │       ├── balance_card.dart
│   │   │       ├── summary_row.dart
│   │   │       └── recent_transactions.dart
│   │   ├── add_transaction/
│   │   │   ├── add_transaction_screen.dart
│   │   │   └── widgets/
│   │   │       ├── amount_input.dart
│   │   │       └── category_selector.dart
│   │   ├── history/
│   │   │   ├── history_screen.dart
│   │   │   └── widgets/
│   │   │       ├── transaction_tile.dart
│   │   │       └── filter_bar.dart
│   │   └── insights/
│   │       ├── insights_screen.dart
│   │       └── widgets/
│   │           └── category_chart.dart
│   ├── providers/                     # State management
│   │   └── transaction_provider.dart
│   └── navigation/
│       └── app_router.dart            # Navigation setup
│
└── shared/                            # Shared widgets
    └── widgets/
        ├── app_bottom_nav.dart        # Bottom navigation bar
        └── empty_state.dart           # Empty state placeholder
```

### Create the folder structure:

```powershell
# Run from project root: g:\pet projects\finance app

# Core
mkdir -p lib/core/constants, lib/core/theme, lib/core/utils, lib/core/extensions

# Data
mkdir -p lib/data/models, lib/data/database, lib/data/repositories

# Domain
mkdir -p lib/domain/entities, lib/domain/enums, lib/domain/repositories

# Presentation
mkdir -p lib/presentation/screens/dashboard/widgets
mkdir -p lib/presentation/screens/add_transaction/widgets
mkdir -p lib/presentation/screens/history/widgets
mkdir -p lib/presentation/screens/insights/widgets
mkdir -p lib/presentation/providers
mkdir -p lib/presentation/navigation

# Shared
mkdir -p lib/shared/widgets
```

> **PowerShell note:** If `mkdir -p` doesn't work, use:
> ```powershell
> New-Item -ItemType Directory -Force -Path "lib/core/constants"
> ```
> ...for each path.

---

## Step 3: Required Dependencies (Minimal)

Edit `pubspec.yaml` — replace the `dependencies` and `dev_dependencies` sections:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (lightweight, simple)
  provider: ^6.1.2

  # Local Database (offline-first)
  sqflite: ^2.3.3+2
  path: ^1.9.0

  # UI & Charts
  fl_chart: ^0.69.2              # Pie charts for category breakdown
  intl: ^0.19.0                  # Date & currency formatting

  # Navigation
  go_router: ^14.8.1             # Declarative routing

  # Utility
  uuid: ^4.5.1                   # Unique IDs for transactions

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting (recommended)
  flutter_lints: ^5.0.0

  # Testing utilities
  mockito: ^5.4.4
  build_runner: ^2.4.13
```

### Install dependencies:

```powershell
flutter pub get
```

### Why these packages?

| Package | Purpose | Why not alternatives? |
|---------|---------|----------------------|
| `provider` | State management | Simplest option, official recommendation, perfect for MVP |
| `sqflite` | SQLite database | Battle-tested, offline-first, perfect for local storage |
| `fl_chart` | Charts | Lightweight, beautiful, customizable pie/bar charts |
| `go_router` | Navigation | Declarative, type-safe, scales well |
| `intl` | Formatting | Official Dart i18n package for dates & currency |
| `uuid` | Unique IDs | Reliable transaction identification |

---

## Step 4: Verify Project Runs

### Option A: Run on Android Emulator

```powershell
# 1. List available emulators
flutter emulators

# 2. Launch an emulator
flutter emulators --launch <emulator_id>
# Example: flutter emulators --launch Pixel_7_API_34

# 3. Verify device is connected
flutter devices

# 4. Run the app
flutter run
```

### Option B: Run on Physical Android Device

1. **Enable Developer Options** on your phone:
   - Settings → About Phone → Tap "Build Number" 7 times
2. **Enable USB Debugging**:
   - Settings → Developer Options → USB Debugging → ON
3. Connect phone via USB cable
4. Accept the debugging prompt on your phone
5. Run:
   ```powershell
   flutter devices           # Should show your phone
   flutter run               # Runs on the connected device
   ```

### Option C: Run on Chrome (for quick UI testing)

```powershell
flutter run -d chrome
```

> ⚠️ SQLite won't work in Chrome — use this only for layout testing.

---

## Step 5: Verify Everything Works

After running `flutter run`, you should see the default Flutter counter app. If it loads successfully, your environment is ready.

### Quick health check:

```powershell
# Full environment check
flutter doctor -v

# Run tests (should pass with default test)
flutter test

# Analyze code quality
flutter analyze
```

---

## Summary Checklist

- [ ] Flutter SDK installed and on PATH
- [ ] Android Studio installed with SDK 34
- [ ] Android emulator created (or physical device connected)
- [ ] `flutter doctor` shows no critical issues
- [ ] Project created with `flutter create`
- [ ] Folder structure created (`core/`, `data/`, `domain/`, `presentation/`)
- [ ] Dependencies added to `pubspec.yaml`
- [ ] `flutter pub get` succeeded
- [ ] `flutter run` launches the app successfully
- [ ] `flutter test` passes

---

## Next Steps

Once your environment is green:

1. **Set up the theme** → `lib/core/theme/app_theme.dart`
2. **Define the Transaction model** → `lib/domain/entities/transaction_entity.dart`
3. **Build the database layer** → `lib/data/database/app_database.dart`
4. **Create the dashboard UI** → `lib/presentation/screens/dashboard/`
5. **Wire up state management** → `lib/presentation/providers/`
