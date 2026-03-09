import 'package:expense_tracker/domain/entities/budget_entity.dart';

/// Data transfer object for SQLite persistence of budgets.
class BudgetModel {
  final String id;
  final double amount;
  final String? categoryId;
  final int year;
  final int month;
  final String createdAt;
  final String profileId;

  const BudgetModel({
    required this.id,
    required this.amount,
    this.categoryId,
    required this.year,
    required this.month,
    required this.createdAt,
    this.profileId = 'default',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': categoryId,
      'year': year,
      'month': month,
      'created_at': createdAt,
      'profile_id': profileId,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['category'] as String?,
      year: map['year'] as int,
      month: map['month'] as int,
      createdAt: map['created_at'] as String,
      profileId: (map['profile_id'] as String?) ?? 'default',
    );
  }

  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      amount: amount,
      categoryId: categoryId,
      year: year,
      month: month,
      createdAt: DateTime.parse(createdAt),
    );
  }

  factory BudgetModel.fromEntity(
    BudgetEntity entity, {
    String profileId = 'default',
  }) {
    return BudgetModel(
      id: entity.id,
      amount: entity.amount,
      categoryId: entity.categoryId,
      year: entity.year,
      month: entity.month,
      createdAt: entity.createdAt.toIso8601String(),
      profileId: profileId,
    );
  }
}
