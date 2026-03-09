import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/models/category_model.dart';

class CategoryDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> insert(CategoryModel model) async {
    final db = await _db;
    await db.insert(
      'categories',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(CategoryModel model) async {
    final db = await _db;
    await db.update(
      'categories',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> delete(String id, String profileId) async {
    final db = await _db;

    // Check if 'other' category exists for the profile
    final otherCategory = await db.query(
      'categories',
      where: 'profile_id = ? AND is_system = 1 AND name = ?',
      whereArgs: [profileId, 'Other'],
    );

    if (otherCategory.isNotEmpty) {
      final otherId = otherCategory.first['id'] as String;
      // Reassign transactions
      await db.rawUpdate(
        'UPDATE transactions SET category = ? WHERE category = ? AND profile_id = ?',
        [otherId, id, profileId],
      );
    }

    await db.delete(
      'categories',
      where: 'id = ? AND is_system = 0', // CANNOT DELETE SYSTEM CATEGORIES
      whereArgs: [id],
    );
  }

  Future<List<CategoryModel>> getByProfileId(String profileId) async {
    final db = await _db;
    final maps = await db.query(
      'categories',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );

    return maps.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<CategoryModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('categories', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return CategoryModel.fromMap(maps.first);
  }
}
