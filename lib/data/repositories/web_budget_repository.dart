import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/data/models/budget_model.dart';
import 'package:expense_tracker/domain/entities/budget_entity.dart';

import 'package:expense_tracker/domain/repositories/i_budget_repository.dart';

/// SharedPreferences-backed budget repository for web previews.
class WebBudgetRepository implements IBudgetRepository {
  List<BudgetEntity> _budgets = [];
  bool _initialized = false;
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    if (_activeProfileId != profileId) {
      _activeProfileId = profileId;
      _initialized = false;
    }
  }

  String get _prefsKey => 'web_budgets_$_activeProfileId';

  Future<void> _initIfNeeded() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_prefsKey);
    if (data != null) {
      try {
        final List<dynamic> decoded = jsonDecode(data);
        _budgets = decoded.map((map) {
          return BudgetModel.fromMap(map as Map<String, dynamic>).toEntity();
        }).toList();
      } catch (_) {
        _budgets = [];
      }
    } else {
      _budgets = [];
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _budgets
        .map((b) => BudgetModel.fromEntity(b).toMap())
        .toList();
    await prefs.setString(_prefsKey, jsonEncode(encoded));
  }

  @override
  Future<void> upsert(BudgetEntity budget) async {
    await _initIfNeeded();
    // Remove existing budget for same category+year+month
    _budgets.removeWhere(
      (b) =>
          b.categoryId == budget.categoryId &&
          b.year == budget.year &&
          b.month == budget.month,
    );
    _budgets.add(budget);
    await _save();
  }

  @override
  Future<List<BudgetEntity>> getForMonth(int year, int month) async {
    await _initIfNeeded();
    return _budgets.where((b) => b.year == year && b.month == month).toList();
  }

  @override
  Future<BudgetEntity?> getOverallBudget(int year, int month) async {
    await _initIfNeeded();
    try {
      return _budgets.firstWhere(
        (b) => b.isOverall && b.year == year && b.month == month,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BudgetEntity?> getCategoryBudget(
    String categoryId,
    int year,
    int month,
  ) async {
    await _initIfNeeded();
    try {
      return _budgets.firstWhere(
        (b) => b.categoryId == categoryId && b.year == year && b.month == month,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> delete(String id) async {
    await _initIfNeeded();
    _budgets.removeWhere((b) => b.id == id);
    await _save();
  }

  @override
  Future<void> deleteAll() async {
    await _initIfNeeded();
    _budgets.clear();
    await _save();
  }
}
