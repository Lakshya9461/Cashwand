# 🏛️ Domain Layer Rules

## Clean Architecture Contract for Expense Tracker

This document defines the rules that keep the domain layer pure, testable, and independent. Every contributor (including future-you) must follow these rules when touching `lib/domain/`.

---

## Rule 1: The Domain Depends on NOTHING

The domain layer sits at the center of the architecture. It has **zero imports** from any other layer or external package.

### ✅ Allowed imports in `lib/domain/`

```dart
import 'package:expense_tracker/domain/...';  // Other domain files only
import 'dart:core';                             // Implicitly available
import 'dart:math';                             // Standard Dart libraries
import 'dart:collection';                       // Standard Dart libraries
```

### ❌ Forbidden imports in `lib/domain/`

```dart
// NEVER import these in domain files:
import 'package:flutter/material.dart';          // Flutter UI framework
import 'package:sqflite/sqflite.dart';           // Database implementation
import 'package:provider/provider.dart';         // State management
import 'package:go_router/go_router.dart';       // Navigation
import 'package:fl_chart/fl_chart.dart';         // Charts
import 'dart:io';                                // Platform-specific I/O
import 'package:expense_tracker/data/...';       // Data layer
import 'package:expense_tracker/presentation/...'; // Presentation layer
```

**Why?** If the domain imports from data or presentation, you can't test business logic without a database or a running Flutter app. The domain must work with `dart test` alone — no emulator, no database, no UI.

---

## Rule 2: Dependency Direction

Dependencies flow **inward** — outer layers depend on inner layers, never the reverse.

```
┌──────────────────────────────────────────────────────────┐
│                    PRESENTATION                          │
│              (screens, providers, widgets)                │
│                                                          │
│    Imports from: domain ✅, data ❌ (via interface only)  │
└────────────────────────┬─────────────────────────────────┘
                         │ depends on
                         ▼
┌──────────────────────────────────────────────────────────┐
│                      DOMAIN                              │
│              (entities, enums, interfaces)                │
│                                                          │
│    Imports from: NOTHING ✅                               │
└──────────────────────────────────────────────────────────┘
                         ▲
                         │ implements
                         │
┌──────────────────────────────────────────────────────────┐
│                       DATA                               │
│            (models, database, repositories)               │
│                                                          │
│    Imports from: domain ✅                                │
└──────────────────────────────────────────────────────────┘
```

**Key insight:** The presentation layer never directly imports `lib/data/`. It talks to the data layer *through* the domain's `ITransactionRepository` interface. The concrete implementation is injected via Provider at app startup.

---

## Rule 3: How Data Models Map to Entities

The **data layer** owns the conversion between storage format and domain objects. The domain never knows how it's stored.

### Conversion Flow

```
SQLite Row (Map<String, dynamic>)
    ↓ TransactionModel.fromMap()
TransactionModel
    ↓ TransactionModel.toEntity()
TransactionEntity  ← domain layer receives this
```

```
TransactionEntity  ← domain layer produces this
    ↓ TransactionModel.fromEntity()
TransactionModel
    ↓ TransactionModel.toMap()
SQLite Row (Map<String, dynamic>)
```

### Responsibilities

| Class | Layer | Knows about | Responsible for |
|-------|-------|-------------|-----------------|
| `TransactionEntity` | Domain | Business rules only | Validation, computed properties, equality |
| `TransactionModel` | Data | Entity + SQLite format | `toMap()`, `fromMap()`, `toEntity()`, `fromEntity()` |
| `TransactionDao` | Data | SQLite queries | Raw SQL operations |
| `TransactionRepository` | Data | Model + Dao + Entity | Orchestrates Dao ↔ Model ↔ Entity conversion |

### Example: What the Repository Does

```dart
// In lib/data/repositories/transaction_repository.dart
class TransactionRepository implements ITransactionRepository {
  final TransactionDao _dao;

  TransactionRepository(this._dao);

  @override
  Future<List<TransactionEntity>> getAll() async {
    final rows = await _dao.queryAll();             // Raw Map<String, dynamic>
    return rows
        .map((row) => TransactionModel.fromMap(row)) // Map → Model
        .map((model) => model.toEntity())             // Model → Entity
        .toList();
  }

  @override
  Future<void> insert(TransactionEntity entity) async {
    final model = TransactionModel.fromEntity(entity); // Entity → Model
    await _dao.insert(model.toMap());                   // Model → Map → SQLite
  }
}
```

The domain's `TransactionEntity` never touches `toMap()` or `fromMap()`. It doesn't know SQLite exists.

---

## Rule 4: Where Business Logic Lives

### ✅ Business logic belongs in the DOMAIN

| Logic | Location | Example |
|-------|----------|---------|
| Validation rules | `TransactionEntity` constructor | Amount must be > 0 |
| Computed values | `TransactionEntity` getters | `signedAmount = amount * type.sign` |
| Type behavior | Enum properties | `TransactionType.sign` returns +1 or -1 |
| Category labels | Enum properties | `CategoryType.label` returns display name |
| Repository contract | `ITransactionRepository` | Defines what operations exist |

### ❌ Business logic does NOT belong in data or presentation

| Logic | Wrong location | Why it's wrong |
|-------|---------------|----------------|
| "Amount must be > 0" | In the UI form widget | If you add a second entry point (e.g., CSV import), validation is bypassed |
| "Amount must be > 0" | In the SQLite dao | Business rule is buried in infrastructure code |
| `signedAmount` calculation | In the Provider | Business logic scattered across state management |
| Monthly summary logic | In a screen widget | Logic is untestable without spinning up Flutter |

---

## Rule 5: Good vs Bad Domain Responsibilities

### ✅ GOOD — Domain does this

```dart
// Entity validates itself
class TransactionEntity {
  TransactionEntity({required this.amount, ...}) {
    if (amount <= 0) throw ArgumentError('Amount must be > 0');
  }

  // Entity computes derived values
  double get signedAmount => amount * type.sign;
  bool get isExpense => type == TransactionType.expense;
}

// Enum carries behavior
enum TransactionType {
  income('Income', 1),
  expense('Expense', -1);
  // ...
}

// Interface defines the contract
abstract class ITransactionRepository {
  Future<void> insert(TransactionEntity transaction);
  Future<List<TransactionEntity>> getAll();
}
```

### ❌ BAD — Domain should NOT do this

```dart
// BAD: Domain knows about SQLite
class TransactionEntity {
  Map<String, dynamic> toMap() => {  // ❌ Serialization is data layer's job
    'id': id,
    'amount': amount,
  };
}

// BAD: Domain knows about Flutter
class TransactionEntity {
  Widget buildCard() => Card(child: ...);  // ❌ UI is presentation layer's job
}

// BAD: Domain knows about icons
enum CategoryType {
  food('Food', Icons.restaurant);  // ❌ Icons require Flutter import
  final IconData icon;              // ❌ Domain can't import material.dart
}

// BAD: Domain formats for display
class TransactionEntity {
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';  // ❌ Formatting is presentation
}

// BAD: Domain talks to database
class TransactionEntity {
  Future<void> save(Database db) async {  // ❌ Entity shouldn't know about persistence
    await db.insert('transactions', toMap());
  }
}

// BAD: Domain manages state
class TransactionEntity extends ChangeNotifier {  // ❌ ChangeNotifier is Flutter
  void updateAmount(double newAmount) {
    notifyListeners();  // ❌ State management is presentation layer
  }
}
```

---

## Rule 6: Testing Litmus Test

If you can test a domain file with this command and **nothing else**, it's clean:

```bash
dart test test/domain/transaction_entity_test.dart
```

No Flutter. No emulator. No database. No network. Just pure Dart.

If a domain file requires `flutter test` instead of `dart test`, something is wrong — it has a Flutter dependency that must be removed.

---

## Quick Reference Cheat Sheet

| Question | Answer |
|----------|--------|
| Where does validation live? | In the entity constructor |
| Where does serialization live? | In the data model (`toMap`/`fromMap`) |
| Where do icons live? | In presentation (extension on enum) |
| Where does formatting live? | In `core/utils/` (currency/date formatters) |
| Where does state management live? | In `presentation/providers/` |
| Where do SQL queries live? | In `data/database/` (DAO) |
| Can domain import Flutter? | **No, never** |
| Can domain import data layer? | **No, never** |
| Can data import domain? | Yes — to implement interfaces |
| Can presentation import domain? | Yes — to use entities and interfaces |
| Can presentation import data? | No — only through the injected interface |
