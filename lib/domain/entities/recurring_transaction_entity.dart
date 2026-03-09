import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/domain/enums/recurrence_frequency.dart';

/// Domain entity for a recurring transaction rule.
///
/// This is NOT a transaction itself — it's a *template* that generates
/// real [TransactionEntity] instances on each due date.
class RecurringTransactionEntity {
  final String id;
  final String profileId;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? accountId;
  final String description;
  final RecurrenceFrequency frequency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  RecurringTransactionEntity({
    required this.id,
    required this.profileId,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.accountId,
    this.description = '',
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.endDate,
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now() {
    _validate();
  }

  void _validate() {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'Must be > 0');
    }
    if (amount > 10000000) {
      throw ArgumentError.value(amount, 'amount', 'Exceeds max limit');
    }
    if (description.length > 100) {
      throw ArgumentError.value(description, 'description', 'Max 100 chars');
    }
    if (endDate != null && endDate!.isBefore(startDate)) {
      throw ArgumentError('End date cannot be before start date');
    }
  }

  /// Calculate the next due date after the current one.
  DateTime computeNextDue() {
    switch (frequency) {
      case RecurrenceFrequency.daily:
        return nextDueDate.add(const Duration(days: 1));
      case RecurrenceFrequency.weekly:
        return nextDueDate.add(const Duration(days: 7));
      case RecurrenceFrequency.monthly:
        var next = DateTime(
          nextDueDate.year,
          nextDueDate.month + 1,
          nextDueDate.day,
        );
        // Handle month overflow (e.g., Jan 31 -> Feb 28)
        while (next.month > (nextDueDate.month % 12) + 1 && next.month != 1) {
          next = DateTime(next.year, next.month, next.day - 1);
        }
        return next;
      case RecurrenceFrequency.yearly:
        return DateTime(
          nextDueDate.year + 1,
          nextDueDate.month,
          nextDueDate.day,
        );
    }
  }

  /// Check if this recurring item is currently due (nextDueDate <= today).
  bool get isDue {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueDate = DateTime(
      nextDueDate.year,
      nextDueDate.month,
      nextDueDate.day,
    );
    return isActive && !dueDate.isAfter(todayDate);
  }

  RecurringTransactionEntity copyWith({
    String? id,
    String? profileId,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    String? description,
    RecurrenceFrequency? frequency,
    DateTime? startDate,
    DateTime? nextDueDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringTransactionEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
