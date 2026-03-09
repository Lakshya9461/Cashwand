import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/data/models/recurring_transaction_model.dart';
import 'package:expense_tracker/domain/entities/recurring_transaction_entity.dart';
import 'package:expense_tracker/domain/repositories/i_recurring_transaction_repository.dart';

class WebRecurringTransactionRepository
    implements IRecurringTransactionRepository {
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  String get _prefsKey => 'recurring_transactions_$_activeProfileId';

  Future<List<RecurringTransactionModel>> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_prefsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map(
            (map) =>
                RecurringTransactionModel.fromMap(map as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToPrefs(List<RecurringTransactionModel> models) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(models.map((m) => m.toMap()).toList());
    await prefs.setString(_prefsKey, jsonString);
  }

  @override
  Future<void> insert(RecurringTransactionEntity item) async {
    final models = await _loadFromPrefs();
    models.add(RecurringTransactionModel.fromEntity(item));
    await _saveToPrefs(models);
  }

  @override
  Future<void> update(RecurringTransactionEntity item) async {
    final models = await _loadFromPrefs();
    final index = models.indexWhere((m) => m.id == item.id);
    if (index >= 0) {
      models[index] = RecurringTransactionModel.fromEntity(item);
    }
    await _saveToPrefs(models);
  }

  @override
  Future<void> delete(String id) async {
    final models = await _loadFromPrefs();
    models.removeWhere((m) => m.id == id);
    await _saveToPrefs(models);
  }

  @override
  Future<List<RecurringTransactionEntity>> getByProfileId(
    String profileId,
  ) async {
    final models = await _loadFromPrefs();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RecurringTransactionEntity?> getById(String id) async {
    final models = await _loadFromPrefs();
    try {
      return models.firstWhere((m) => m.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }
}
