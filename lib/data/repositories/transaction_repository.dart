import 'package:expense_tracker/data/database/transaction_dao.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';

import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';

/// Concrete implementation of [ITransactionRepository] using SQLite.
///
/// Now profile-aware: all operations are scoped to [activeProfileId].
class TransactionRepository implements ITransactionRepository {
  final TransactionDao _dao;
  String _activeProfileId;

  TransactionRepository({
    TransactionDao? dao,
    String activeProfileId = 'default',
  }) : _dao = dao ?? TransactionDao(),
       _activeProfileId = activeProfileId;

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<void> insert(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(
      transaction,
      profileId: _activeProfileId,
    );
    await _dao.insert(model.toMap());
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> getAll() async {
    final rows = await _dao.queryAll(profileId: _activeProfileId);
    return rows.map((row) => TransactionModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<TransactionEntity?> getById(String id) async {
    final row = await _dao.queryById(id);
    if (row == null) return null;
    return TransactionModel.fromMap(row).toEntity();
  }

  @override
  Future<List<TransactionEntity>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final rows = await _dao.queryByDateRange(
      start.toIso8601String(),
      end.toIso8601String(),
      profileId: _activeProfileId,
    );
    return rows.map((row) => TransactionModel.fromMap(row).toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getByCategory(String categoryId) async {
    final rows = await _dao.queryByCategory(
      categoryId,
      profileId: _activeProfileId,
    );
    return rows.map((row) => TransactionModel.fromMap(row).toEntity()).toList();
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<void> update(TransactionEntity transaction) async {
    final model = TransactionModel.fromEntity(
      transaction,
      profileId: _activeProfileId,
    );
    await _dao.update(model.toMap());
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await _dao.deleteAll(profileId: _activeProfileId);
  }

  // ---------------------------------------------------------------------------
  // Aggregation
  // ---------------------------------------------------------------------------

  @override
  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final rows = await _dao.queryMonthlySummary(
      startDate,
      endDate,
      profileId: _activeProfileId,
    );

    final summary = <String, double>{'income': 0.0, 'expense': 0.0};
    for (final row in rows) {
      final type = row['type'] as String;
      final total = (row['total'] as num).toDouble();
      if (summary.containsKey(type)) {
        summary[type] = total;
      }
    }
    return summary;
  }
}
