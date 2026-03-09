import 'package:expense_tracker/data/database/budget_dao.dart';
import 'package:expense_tracker/data/models/budget_model.dart';
import 'package:expense_tracker/domain/entities/budget_entity.dart';

import 'package:expense_tracker/domain/repositories/i_budget_repository.dart';

/// SQLite-backed implementation of [IBudgetRepository].
class BudgetRepository implements IBudgetRepository {
  final BudgetDao _dao;
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  BudgetRepository({BudgetDao? dao}) : _dao = dao ?? BudgetDao();

  @override
  Future<void> upsert(BudgetEntity budget) async {
    final model = BudgetModel.fromEntity(budget, profileId: _activeProfileId);
    await _dao.upsert(model);
  }

  @override
  Future<List<BudgetEntity>> getForMonth(int year, int month) async {
    final models = await _dao.queryForMonth(year, month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BudgetEntity?> getOverallBudget(int year, int month) async {
    final model = await _dao.queryOverallBudget(year, month);
    return model?.toEntity();
  }

  @override
  Future<BudgetEntity?> getCategoryBudget(
    String categoryId,
    int year,
    int month,
  ) async {
    final model = await _dao.queryCategoryBudget(categoryId, year, month);
    return model?.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id);
  }

  @override
  Future<void> deleteAll() async {
    await _dao.deleteAll();
  }
}
