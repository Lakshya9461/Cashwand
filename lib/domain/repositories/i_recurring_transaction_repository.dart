import 'package:expense_tracker/domain/entities/recurring_transaction_entity.dart';

/// Repository interface for recurring transaction rules.
abstract class IRecurringTransactionRepository {
  String get activeProfileId;
  void setActiveProfile(String profileId);

  Future<void> insert(RecurringTransactionEntity item);
  Future<void> update(RecurringTransactionEntity item);
  Future<void> delete(String id);
  Future<List<RecurringTransactionEntity>> getByProfileId(String profileId);
  Future<RecurringTransactionEntity?> getById(String id);
}
