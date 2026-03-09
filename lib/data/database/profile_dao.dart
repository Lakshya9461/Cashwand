import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/data/database/app_database.dart';

/// Data Access Object for the profiles table.
class ProfileDao {
  final AppDatabase _appDatabase;

  ProfileDao({AppDatabase? appDatabase})
    : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<Database> get _db => _appDatabase.database;

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db;
    await db.insert(
      'profiles',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    final db = await _db;
    return await db.query('profiles', orderBy: 'created_at ASC');
  }

  Future<Map<String, dynamic>?> queryById(String id) async {
    final db = await _db;
    final results = await db.query(
      'profiles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isEmpty ? null : results.first;
  }

  Future<int> update(Map<String, dynamic> row) async {
    final db = await _db;
    return await db.update(
      'profiles',
      row,
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }

  Future<int> delete(String id) async {
    final db = await _db;
    return await db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }
}
