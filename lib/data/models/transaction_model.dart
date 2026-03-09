import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';

/// Data transfer object for SQLite persistence.
///
/// This class bridges the gap between [TransactionEntity] (pure domain)
/// and SQLite (raw `Map<String, dynamic>`). It handles serialization
/// decisions that the domain layer must never know about:
///
/// - **Dates** → stored as ISO 8601 strings (SQLite has no native date type)
/// - **Enums** → stored as their [name] string (e.g., "expense", "food")
/// - **Amount** → stored as REAL (double)
///
/// ## Why Models Differ from Entities
///
/// Entities enforce business rules (validation, immutability, equality).
/// Models handle storage format concerns (string encoding, null handling).
/// Keeping them separate means changing the database schema never forces
/// changes to business logic, and vice versa.
class TransactionModel {
  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String? accountId;
  final String description;
  final String date;
  final String createdAt;
  final String profileId;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.accountId,
    required this.description,
    required this.date,
    required this.createdAt,
    this.profileId = 'default',
  });

  // ---------------------------------------------------------------------------
  // SQLite Serialization
  // ---------------------------------------------------------------------------

  /// Converts this model to a Map suitable for SQLite `INSERT`/`UPDATE`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': categoryId,
      'account': accountId,
      'description': description,
      'date': date,
      'created_at': createdAt,
      'profile_id': profileId,
    };
  }

  /// Creates a model from a SQLite row (`Map<String, dynamic>`).
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      categoryId: map['category'] as String,
      accountId: map['account'] as String?,
      description: map['description'] as String? ?? '',
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
      profileId: (map['profile_id'] as String?) ?? 'default',
    );
  }

  // ---------------------------------------------------------------------------
  // Domain ↔ Data Conversion
  // ---------------------------------------------------------------------------

  /// Converts this data model into a domain [TransactionEntity].
  ///
  /// Enum values are resolved by name. If a stored enum name doesn't
  /// match any value, this will throw — indicating corrupt data.
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: TransactionType.values.byName(type),
      categoryId: categoryId,
      accountId: accountId,
      description: description,
      date: DateTime.parse(date),
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Creates a data model from a domain [TransactionEntity].
  ///
  /// Dates are serialized to ISO 8601 strings.
  /// Enums are serialized to their [name] property.
  factory TransactionModel.fromEntity(
    TransactionEntity entity, {
    String profileId = 'default',
  }) {
    return TransactionModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      description: entity.description,
      date: entity.date.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      profileId: profileId,
    );
  }
}
