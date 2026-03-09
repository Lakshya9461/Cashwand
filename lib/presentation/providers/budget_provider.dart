import 'package:flutter/foundation.dart';
import 'package:expense_tracker/domain/entities/budget_entity.dart';

import 'package:expense_tracker/domain/repositories/i_budget_repository.dart';

/// Represents the spending status of a budget.
class BudgetStatus {
  final BudgetEntity budget;
  final double spent;

  BudgetStatus({required this.budget, required this.spent});

  double get limit => budget.amount;
  double get remaining => (limit - spent).clamp(0, double.infinity);
  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 2.0) : 0;
  bool get isWarning => percentage >= 0.8 && percentage < 1.0;
  bool get isOverBudget => percentage >= 1.0;
  bool get isHealthy => percentage < 0.8;

  String get label => budget.categoryId ?? 'Monthly Budget';
}

/// State manager for budget data.
class BudgetProvider extends ChangeNotifier {
  final IBudgetRepository _repository;

  BudgetProvider(this._repository);

  List<BudgetEntity> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<BudgetEntity> get budgets => List.unmodifiable(_budgets);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasBudgets => _budgets.isNotEmpty;

  /// Overall monthly budget, if set.
  BudgetEntity? get overallBudget {
    try {
      return _budgets.firstWhere((b) => b.isOverall);
    } catch (_) {
      return null;
    }
  }

  /// Category budgets only.
  List<BudgetEntity> get categoryBudgets =>
      _budgets.where((b) => b.isCategoryBudget).toList();

  /// Computes budget status for a given budget using actual spending data.
  BudgetStatus computeStatus(BudgetEntity budget, double spent) {
    return BudgetStatus(budget: budget, spent: spent);
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Loads budgets for the current month.
  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      _budgets = await _repository.getForMonth(now.year, now.month);
    } catch (e) {
      _error = 'Failed to load budgets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saves or updates a budget.
  Future<void> saveBudget(BudgetEntity budget) async {
    try {
      await _repository.upsert(budget);
      final now = DateTime.now();
      _budgets = await _repository.getForMonth(now.year, now.month);
      _error = null;
    } catch (e) {
      _error = 'Failed to save budget: $e';
    }
    notifyListeners();
  }

  /// Deletes a budget.
  Future<void> deleteBudget(String id) async {
    try {
      await _repository.delete(id);
      _budgets.removeWhere((b) => b.id == id);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete budget: $e';
    }
    notifyListeners();
  }

  /// Returns the budget for a specific category in the current month.
  BudgetEntity? getBudgetForCategory(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }
}
