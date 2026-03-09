/// Domain entity representing a spending budget limit.
///
/// Budgets can be:
/// - **Overall monthly**: [categoryId] is null → total spending limit for the month
/// - **Per-category**: [categoryId] is set → limit for a specific category
///
/// This class is:
/// - **Immutable**: All fields are `final`.
/// - **Self-validating**: Invalid data throws [ArgumentError] at construction.
/// - **Pure Dart**: No Flutter, no serialization, no persistence logic.
class BudgetEntity {
  /// Unique identifier (UUID v4).
  final String id;

  /// Budget limit amount in INR. Must be > 0.
  final double amount;

  /// Target category ID. Null means this is an overall monthly budget.
  final String? categoryId;

  /// Budget year (e.g., 2026).
  final int year;

  /// Budget month (1–12).
  final int month;

  /// Timestamp of when this budget was created/last updated.
  final DateTime createdAt;

  /// Creates a validated [BudgetEntity].
  ///
  /// Throws [ArgumentError] if:
  /// - [amount] is zero or negative
  /// - [amount] exceeds 10,000,000
  /// - [month] is not in range 1–12
  BudgetEntity({
    required this.id,
    required this.amount,
    this.categoryId,
    required this.year,
    required this.month,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Budget amount must be greater than zero',
      );
    }
    if (amount > 10000000) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Budget amount exceeds maximum limit of ₹1,00,00,000',
      );
    }
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12',
      );
    }
  }

  /// Whether this is an overall monthly budget (not category-specific).
  bool get isOverall => categoryId == null;

  /// Whether this is a per-category budget.
  bool get isCategoryBudget => categoryId != null;

  /// Creates a copy of this entity with the given fields replaced.
  BudgetEntity copyWith({
    String? id,
    double? amount,
    String? categoryId,
    bool clearCategoryId = false,
    int? year,
    int? month,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      year: year ?? this.year,
      month: month ?? this.month,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BudgetEntity('
        'id: $id, '
        'amount: $amount, '
        'categoryId: $categoryId, '
        'period: $year-$month'
        ')';
  }
}
