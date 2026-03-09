import 'package:expense_tracker/domain/enums/transaction_type.dart';

/// Core domain entity representing a single financial transaction.
///
/// This class is:
/// - **Immutable**: All fields are `final`. Use [copyWith] for modifications.
/// - **Self-validating**: Invalid data throws [ArgumentError] at construction.
/// - **Pure Dart**: No Flutter, no serialization, no persistence logic.
///
/// ## Example
/// ```dart
/// final expense = TransactionEntity(
///   id: '550e8400-e29b-41d4-a716-446655440000',
///   amount: 250.0,
///   type: TransactionType.expense,
///   categoryId: 'food-uuid',
///   description: 'Lunch at cafeteria',
///   date: DateTime(2026, 2, 25),
/// );
///
/// expense.signedAmount; // -250.0
/// ```
class TransactionEntity {
  /// Unique identifier (UUID v4).
  final String id;

  /// Transaction amount in INR. Always stored as a positive value.
  /// Use [signedAmount] to get the value with income/expense sign applied.
  final double amount;

  /// Whether this is an income or expense entry.
  final TransactionType type;

  /// ID of the spending or income category.
  final String categoryId;

  /// Optional income source account ID. Only meaningful for income transactions.
  final String? accountId;

  /// Optional user-provided note (max 100 characters).
  final String description;

  /// The date when this transaction occurred (user-selected).
  final DateTime date;

  /// Timestamp of when this record was created (auto-set).
  final DateTime createdAt;

  /// Creates a validated [TransactionEntity].
  ///
  /// Throws [ArgumentError] if:
  /// - [amount] is zero or negative
  /// - [amount] exceeds 10,000,000
  /// - [description] exceeds 100 characters
  /// - [date] is in the future
  TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.accountId,
    this.description = '',
    required this.date,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    _validate();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  void _validate() {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than zero',
      );
    }

    if (amount > 10000000) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount exceeds maximum limit of ₹1,00,00,000',
      );
    }

    if (description.length > 100) {
      throw ArgumentError.value(
        description,
        'description',
        'Description must be 100 characters or less',
      );
    }

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (date.isAfter(tomorrow)) {
      throw ArgumentError.value(
        date,
        'date',
        'Transaction date cannot be in the future',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Returns the amount with the correct sign applied.
  /// Positive for income, negative for expense.
  double get signedAmount => amount * type.sign;

  /// Whether this transaction is an income entry.
  bool get isIncome => type == TransactionType.income;

  /// Whether this transaction is an expense entry.
  bool get isExpense => type == TransactionType.expense;

  // ---------------------------------------------------------------------------
  // Immutability — copyWith
  // ---------------------------------------------------------------------------

  /// Creates a copy of this entity with the given fields replaced.
  ///
  /// The new instance is fully validated, so invalid modifications
  /// will throw [ArgumentError] just like the constructor.
  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    bool clearAccountId = false,
    String? description,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: clearAccountId ? null : (accountId ?? this.accountId),
      description: description ?? this.description,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Value Equality
  // ---------------------------------------------------------------------------

  /// Two entities are equal if they share the same [id].
  ///
  /// This is an identity-based equality: the `id` field is the unique
  /// identifier, so two entities with the same id represent the same
  /// real-world transaction regardless of field differences.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ---------------------------------------------------------------------------
  // Debug
  // ---------------------------------------------------------------------------

  @override
  String toString() {
    return 'TransactionEntity('
        'id: $id, '
        'amount: $amount, '
        'type: ${type.label}, '
        'categoryId: $categoryId, '
        'description: "$description", '
        'date: $date'
        ')';
  }
}
