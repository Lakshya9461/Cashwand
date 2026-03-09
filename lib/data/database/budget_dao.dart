import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/models/budget_model.dart';

/// Raw SQL operations for the budgets table.
class BudgetDao {
  final AppDatabase _appDb;

  BudgetDao({AppDatabase? appDb}) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  /// Insert or replace a budget (upsert via UNIQUE constraint on category+year+month).
  Future<void> upsert(BudgetModel model) async {
    final db = await _db;
    await db.insert(
      'budgets',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all budgets for a specific month.
  Future<List<BudgetModel>> queryForMonth(int year, int month) async {
    final db = await _db;
    final rows = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
    return rows.map(BudgetModel.fromMap).toList();
  }

  /// Get the overall budget (category IS NULL) for a month.
  Future<BudgetModel?> queryOverallBudget(int year, int month) async {
    final db = await _db;
    final rows = await db.query(
      'budgets',
      where: 'category IS NULL AND year = ? AND month = ?',
      whereArgs: [year, month],
    );
    return rows.isEmpty ? null : BudgetModel.fromMap(rows.first);
  }

  /// Get a category budget for a month.
  Future<BudgetModel?> queryCategoryBudget(
    String category,
    int year,
    int month,
  ) async {
    final db = await _db;
    final rows = await db.query(
      'budgets',
      where: 'category = ? AND year = ? AND month = ?',
      whereArgs: [category, year, month],
    );
    return rows.isEmpty ? null : BudgetModel.fromMap(rows.first);
  }

  /// Delete a budget by id.
  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  /// Delete all budgets.
  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('budgets');
  }
}
