import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/data/database/app_database.dart';

/// Data Access Object for the transactions table.
///
/// All query methods accept an optional [profileId] to filter
/// transactions by the active profile. If null, returns all.
class TransactionDao {
  final AppDatabase _appDatabase;

  TransactionDao({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db;
    await db.insert(
      'transactions',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> queryAll({String? profileId}) async {
    final db = await _db;
    if (profileId != null) {
      return await db.query(
        'transactions',
        where: 'profile_id = ?',
        whereArgs: [profileId],
        orderBy: 'date DESC',
      );
    }
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> queryById(String id) async {
    final db = await _db;
    final results = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<List<Map<String, dynamic>>> queryByDateRange(
    String startDate,
    String endDate, {
    String? profileId,
  }) async {
    final db = await _db;
    if (profileId != null) {
      return await db.query(
        'transactions',
        where: 'date >= ? AND date <= ? AND profile_id = ?',
        whereArgs: [startDate, endDate, profileId],
        orderBy: 'date DESC',
      );
    }
    return await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryByCategory(
    String category, {
    String? profileId,
  }) async {
    final db = await _db;
    if (profileId != null) {
      return await db.query(
        'transactions',
        where: 'category = ? AND profile_id = ?',
        whereArgs: [category, profileId],
        orderBy: 'date DESC',
      );
    }
    return await db.query(
      'transactions',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> queryMonthlySummary(
    String startDate,
    String endDate, {
    String? profileId,
  }) async {
    final db = await _db;
    if (profileId != null) {
      return await db.rawQuery(
        '''
        SELECT type, COALESCE(SUM(amount), 0.0) as total
        FROM transactions
        WHERE date >= ? AND date <= ? AND profile_id = ?
        GROUP BY type
        ''',
        [startDate, endDate, profileId],
      );
    }
    return await db.rawQuery(
      '''
      SELECT type, COALESCE(SUM(amount), 0.0) as total
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY type
      ''',
      [startDate, endDate],
    );
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<int> update(Map<String, dynamic> row) async {
    final db = await _db;
    return await db.update(
      'transactions',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAll({String? profileId}) async {
    final db = await _db;
    if (profileId != null) {
      return await db.delete(
        'transactions',
        where: 'profile_id = ?',
        whereArgs: [profileId],
      );
    }
    return await db.delete('transactions');
  }
}
