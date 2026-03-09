import 'package:flutter/foundation.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';

/// Central state manager for transaction data.
///
/// The Provider layer is the only place that:
/// - Holds in-memory state (transactions list)
/// - Calls repository methods
/// - Computes derived values (balance, totals)
/// - Notifies the UI of changes
///
/// Business logic stays here (not in widgets) so it's testable
/// and reusable across multiple screens.
class TransactionProvider extends ChangeNotifier {
  final ITransactionRepository _repository;

  TransactionProvider(this._repository);

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionEntity> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Total balance across all transactions.
  double get currentBalance {
    return _transactions.fold(0.0, (sum, t) => sum + t.signedAmount);
  }

  /// Total income for the current month.
  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Total expenses for the current month.
  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Net savings this month (income - expense).
  double get monthlySavings => monthlyIncome - monthlyExpense;

  /// Most recent 5 transactions for the dashboard.
  List<TransactionEntity> get recentTransactions {
    return _transactions.take(5).toList();
  }

  /// Spending grouped by category for the current month.
  Map<String, double> get categoryBreakdown {
    final now = DateTime.now();
    final breakdown = <String, double>{};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        breakdown[t.categoryId] = (breakdown[t.categoryId] ?? 0) + t.amount;
      }
    }
    return breakdown;
  }

  /// Spending grouped by day for the current month.
  /// Keys are day of the month (1-31), values are total daily expense.
  Map<int, double> get dailyExpenseBreakdown {
    final now = DateTime.now();
    final breakdown = <int, double>{};
    for (final t in _transactions) {
      if (t.type == TransactionType.expense &&
          t.date.year == now.year &&
          t.date.month == now.month) {
        breakdown[t.date.day] = (breakdown[t.date.day] ?? 0) + t.amount;
      }
    }
    return breakdown;
  }

  /// 6-month trend data: month key (e.g. "2026-03") -> map of 'income', 'expense'
  Map<String, Map<String, double>> get last6MonthsTrend {
    final now = DateTime.now();
    final result = <String, Map<String, double>>{};

    // Initialize the last 6 months with zeros
    for (int i = 5; i >= 0; i--) {
      // Dart DateTime month wraps around correctly if you pass e.g. 0 or negative
      final d = DateTime(now.year, now.month - i, 1);
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
      result[key] = {'income': 0.0, 'expense': 0.0};
    }

    // Now accumulate
    for (final t in _transactions) {
      final key = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}';
      if (result.containsKey(key)) {
        if (t.type == TransactionType.income) {
          result[key]!['income'] = (result[key]!['income'] ?? 0) + t.amount;
        } else if (t.type == TransactionType.expense) {
          result[key]!['expense'] = (result[key]!['expense'] ?? 0) + t.amount;
        }
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Loads all transactions from the repository.
  /// Called once at app startup.
  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _repository.getAll();
    } catch (e) {
      _error = 'Failed to load transactions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adds a new transaction and refreshes state.
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      await _repository.insert(transaction);
      _transactions = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = 'Failed to save transaction: $e';
    }
    notifyListeners();
  }

  /// Updates an existing transaction and refreshes state.
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await _repository.update(transaction);
      _transactions = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = 'Failed to update transaction: $e';
    }
    notifyListeners();
  }

  /// Deletes a transaction by id and refreshes state.
  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.delete(id);
      _transactions = await _repository.getAll();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete transaction: $e';
    }
    notifyListeners();
  }

  /// Deletes all transactions and refreshes state.
  Future<void> clearAllTransactions() async {
    try {
      await _repository.deleteAll();
      _transactions.clear();
      _error = null;
    } catch (e) {
      _error = 'Failed to clear history: $e';
    }
    notifyListeners();
  }

  /// Clears any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Fetches transactions for a specific date range directly from the repository.
  /// Used for ad-hoc exports without affecting the main UI state.
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await _repository.getByDateRange(start, end);
  }
}
