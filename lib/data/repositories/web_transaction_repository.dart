import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';

/// A simple repository for Web previews that persists to SharedPreferences.
/// This allows the app to save data in the browser without SQLite worker complications.
class WebTransactionRepository implements ITransactionRepository {
  List<TransactionEntity> _transactions = [];
  bool _initialized = false;
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    if (_activeProfileId != profileId) {
      _activeProfileId = profileId;
      _initialized = false; // Force reload for new profile
    }
  }

  String get _prefsKey => 'web_transactions_$_activeProfileId';

  Future<void> _initIfNeeded() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_prefsKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _transactions = decoded.map((map) {
          final model = TransactionModel.fromMap(map as Map<String, dynamic>);
          return model.toEntity();
        }).toList();
      } catch (e) {
        // Fallback on corrupt data
        _transactions = [];
      }
    } else {
      _transactions = [];
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encoded = _transactions
        .map((t) => TransactionModel.fromEntity(t).toMap())
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(encoded));
  }

  @override
  Future<void> insert(TransactionEntity transaction) async {
    await _initIfNeeded();
    _transactions.add(transaction);
    await _save();
  }

  @override
  Future<void> delete(String id) async {
    await _initIfNeeded();
    _transactions.removeWhere((t) => t.id == id);
    await _save();
  }

  @override
  Future<void> deleteAll() async {
    await _initIfNeeded();
    _transactions.clear();
    await _save();
  }

  @override
  Future<List<TransactionEntity>> getAll() async {
    await _initIfNeeded();
    // Return newest first as per interface contract
    final sorted = List<TransactionEntity>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<TransactionEntity?> getById(String id) async {
    await _initIfNeeded();
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TransactionEntity>> getByCategory(String categoryId) async {
    await _initIfNeeded();
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  @override
  Future<List<TransactionEntity>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await _initIfNeeded();
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          t.date.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<void> update(TransactionEntity transaction) async {
    await _initIfNeeded();
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
      await _save();
    }
  }

  @override
  Future<Map<String, double>> getMonthlySummary(int year, int month) async {
    await _initIfNeeded();
    double income = 0;
    double expense = 0;

    for (var t in _transactions) {
      if (t.date.year == year && t.date.month == month) {
        if (t.type.name == 'income') {
          income += t.amount;
        } else {
          expense += t.amount;
        }
      }
    }

    return {'income': income, 'expense': expense};
  }
}
