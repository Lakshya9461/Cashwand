import 'package:expense_tracker/domain/entities/recurring_transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/domain/enums/recurrence_frequency.dart';

class RecurringTransactionModel {
  final String id;
  final String profileId;
  final double amount;
  final String type;
  final String categoryId;
  final String? accountId;
  final String description;
  final String frequency;
  final String startDate;
  final String nextDueDate;
  final String? endDate;
  final int isActive;
  final String createdAt;

  const RecurringTransactionModel({
    required this.id,
    required this.profileId,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.accountId,
    required this.description,
    required this.frequency,
    required this.startDate,
    required this.nextDueDate,
    this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'amount': amount,
      'type': type,
      'category_id': categoryId,
      'account_id': accountId,
      'description': description,
      'frequency': frequency,
      'start_date': startDate,
      'next_due_date': nextDueDate,
      'end_date': endDate,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }

  factory RecurringTransactionModel.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionModel(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category_id'] as String,
      accountId: map['account_id'] as String?,
      description: (map['description'] as String?) ?? '',
      frequency: map['frequency'] as String,
      startDate: map['start_date'] as String,
      nextDueDate: map['next_due_date'] as String,
      endDate: map['end_date'] as String?,
      isActive: map['is_active'] as int,
      createdAt: map['created_at'] as String,
    );
  }

  RecurringTransactionEntity toEntity() {
    return RecurringTransactionEntity(
      id: id,
      profileId: profileId,
      amount: amount,
      type: TransactionType.values.firstWhere((t) => t.name == type),
      categoryId: categoryId,
      accountId: accountId,
      description: description,
      frequency: RecurrenceFrequency.values.firstWhere(
        (f) => f.name == frequency,
      ),
      startDate: DateTime.parse(startDate),
      nextDueDate: DateTime.parse(nextDueDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      isActive: isActive == 1,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory RecurringTransactionModel.fromEntity(
    RecurringTransactionEntity entity,
  ) {
    return RecurringTransactionModel(
      id: entity.id,
      profileId: entity.profileId,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      description: entity.description,
      frequency: entity.frequency.name,
      startDate: entity.startDate.toIso8601String(),
      nextDueDate: entity.nextDueDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      isActive: entity.isActive ? 1 : 0,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
