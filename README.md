# 🪄 CashWand

**Your money, tracked like magic.**

CashWand is a simple, lightweight, offline-first personal finance tracker built natively in Flutter. Designed to be a friendly, stress-free companion for your everyday money management, it empowers students and everyday users to take effortless control over their financial health.

## 🌟 Key Features

- **Effortless Tracking:** Easily log expenses and incomes with beautifully color-coded tags indicating exactly where your money comes from (e.g. Salary, Bank, Cash).
- **Offline First:** Fully local and private out of the box using a high-performance SQLite engine natively on your mobile device.
- **Budgeting Boundaries:** Assign overall or category-level monthly budgets dynamically and receive helpful warnings before you go over.
- **Biometric Security:** Native App Lock protects your data effortlessly via Fingerprint, FaceUnlock, or PIN (powered by OS settings).
- **Data Portability:** Quickly export formatted `.xlsx` (Excel) transaction reports and category summaries tailored precisely to your date range and securely share to external files.
- **Clean Architecture:** Strongly decoupled domain, presentation, and data layers optimizing code maintainability following TDD standards.

## 🚀 Getting Started

This application requires the Flutter SDK. Follow the [official installation instructions](https://docs.flutter.dev/get-started/install) if you don't have it set up.

```bash
# Clone the repository
git clone https://github.com/yourusername/cashwand.git

# Enter project directory
cd cashwand

# Install packages
flutter pub get

# Run the app 
flutter run
```

## 🎨 Brand Identity

CashWand was rebranded from "Expense Tracker" to focus on approachability rather than strict accounting norms.
- **Tone:** Encouraging, specific, supportive, clear.
- **Palette Elements:** Mint Teal, Warm Green (Income), Coral (Expense), and Dark Slate.

## 🛠 Tech Stack

- **UI Framework:** Flutter / Dart
- **State Management:** Provider
- **Storage:** `sqflite` (Android/iOS), `shared_preferences` (Web/Fallback)
- **Routing:** `go_router`
- **Charting Design:** `fl_chart`
- **System integrations:** `local_auth` & `share_plus`
