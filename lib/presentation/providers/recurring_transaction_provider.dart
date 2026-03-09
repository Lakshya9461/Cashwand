import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/domain/entities/recurring_transaction_entity.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/repositories/i_recurring_transaction_repository.dart';
import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';

/// Manages recurring transaction rules and auto-generates
/// actual transactions when they come due.
class RecurringTransactionProvider extends ChangeNotifier {
  final IRecurringTransactionRepository _recurringRepo;
  final ITransactionRepository _transactionRepo;

  RecurringTransactionProvider(this._recurringRepo, this._transactionRepo);

  List<RecurringTransactionEntity> _items = [];
  bool _isLoading = false;
  String? _error;
  int _lastProcessedCount = 0;

  List<RecurringTransactionEntity> get items => List.unmodifiable(_items);
  List<RecurringTransactionEntity> get activeItems =>
      _items.where((i) => i.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get lastProcessedCount => _lastProcessedCount;

  Future<void> loadItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _recurringRepo.getByProfileId(
        _recurringRepo.activeProfileId,
      );
    } catch (e) {
      _error = 'Failed to load recurring items: $e';
      debugPrint('Recurring load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Process all due recurring transactions and generate real entries.
  /// Call this on app startup or profile switch.
  Future<int> processDueTransactions() async {
    int generated = 0;

    for (final item in _items) {
      if (!item.isActive) continue;

      // Check end date
      if (item.endDate != null && item.nextDueDate.isAfter(item.endDate!)) {
        // Deactivate expired rules
        final updated = item.copyWith(isActive: false);
        await _recurringRepo.update(updated);
        continue;
      }

      // Generate transactions for all missed due dates (handles gaps)
      var current = item;
      while (current.isDue) {
        // Create the actual transaction
        final transaction = TransactionEntity(
          id: const Uuid().v4(),
          amount: current.amount,
          type: current.type,
          categoryId: current.categoryId,
          accountId: current.accountId,
          description: current.description.isNotEmpty
              ? '${current.description} (auto)'
              : 'Recurring (auto)',
          date: current.nextDueDate,
        );

        await _transactionRepo.insert(transaction);
        generated++;

        // Advance the next due date
        final nextDue = current.computeNextDue();
        current = current.copyWith(nextDueDate: nextDue);
        await _recurringRepo.update(current);
      }
    }

    if (generated > 0) {
      _lastProcessedCount = generated;
      await loadItems(); // Refresh the list
    }

    return generated;
  }

  Future<void> addItem(RecurringTransactionEntity item) async {
    try {
      await _recurringRepo.insert(item);
      await loadItems();
    } catch (e) {
      _error = 'Failed to add recurring item: $e';
      notifyListeners();
    }
  }

  Future<void> updateItem(RecurringTransactionEntity item) async {
    try {
      await _recurringRepo.update(item);
      await loadItems();
    } catch (e) {
      _error = 'Failed to update: $e';
      notifyListeners();
    }
  }

  Future<void> toggleActive(String id, bool active) async {
    try {
      final item = _items.firstWhere((i) => i.id == id);
      final updated = item.copyWith(isActive: active);
      await _recurringRepo.update(updated);
      await loadItems();
    } catch (e) {
      _error = 'Failed to toggle: $e';
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _recurringRepo.delete(id);
      await loadItems();
    } catch (e) {
      _error = 'Failed to delete: $e';
      notifyListeners();
    }
  }
}
