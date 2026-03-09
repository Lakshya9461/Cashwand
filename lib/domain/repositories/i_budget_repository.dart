import 'package:expense_tracker/domain/entities/budget_entity.dart';

/// Contract for budget data operations.
///
/// Follows the same pattern as [ITransactionRepository]:
/// pure domain types in, pure domain types out.
abstract class IBudgetRepository {
  String get activeProfileId;
  void setActiveProfile(String profileId);

  /// Insert or update a budget. If a budget already exists for the
  /// same category+year+month combo, it replaces it.
  Future<void> upsert(BudgetEntity budget);

  /// Returns all budgets for a given month.
  Future<List<BudgetEntity>> getForMonth(int year, int month);

  /// Returns the overall monthly budget (category == null), if set.
  Future<BudgetEntity?> getOverallBudget(int year, int month);

  /// Returns the budget for a specific category in a month, if set.
  Future<BudgetEntity?> getCategoryBudget(
    String categoryId,
    int year,
    int month,
  );

  /// Deletes a budget by id.
  Future<void> delete(String id);

  /// Deletes all budgets.
  Future<void> deleteAll();
}
