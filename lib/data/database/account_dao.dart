import 'package:sqflite/sqflite.dart';
import 'package:expense_tracker/data/database/app_database.dart';
import 'package:expense_tracker/data/models/account_model.dart';

class AccountDao {
  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<void> insert(AccountModel model) async {
    final db = await _db;

    if (model.isDefault == 1) {
      await _clearDefault(model.profileId);
    }

    await db.insert(
      'accounts',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(AccountModel model) async {
    final db = await _db;

    if (model.isDefault == 1) {
      await _clearDefault(model.profileId);
    }

    await db.update(
      'accounts',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> _clearDefault(String profileId) async {
    final db = await _db;
    await db.rawUpdate(
      'UPDATE accounts SET is_default = 0 WHERE profile_id = ?',
      [profileId],
    );
  }

  Future<void> setDefaultAccount(String id, String profileId) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.rawUpdate(
        'UPDATE accounts SET is_default = 0 WHERE profile_id = ?',
        [profileId],
      );
      await txn.rawUpdate('UPDATE accounts SET is_default = 1 WHERE id = ?', [
        id,
      ]);
    });
  }

  Future<void> delete(String id, String profileId) async {
    final db = await _db;

    await db.transaction((txn) async {
      // Find default account (must not be the one being deleted)
      final defaultAccounts = await txn.query(
        'accounts',
        where: 'profile_id = ? AND is_default = 1 AND id != ?',
        whereArgs: [profileId, id],
      );

      String fallbackId = '';
      if (defaultAccounts.isNotEmpty) {
        fallbackId = defaultAccounts.first['id'] as String;
      } else {
        // Just find any other account
        final anyAccounts = await txn.query(
          'accounts',
          where: 'profile_id = ? AND id != ?',
          whereArgs: [profileId, id],
        );
        if (anyAccounts.isNotEmpty) {
          fallbackId = anyAccounts.first['id'] as String;
        }
      }

      if (fallbackId.isNotEmpty) {
        await txn.rawUpdate(
          'UPDATE transactions SET account = ? WHERE account = ? AND profile_id = ?',
          [fallbackId, id, profileId],
        );
      }

      // Check if trying to delete the very last account
      final allAccountsCount = Sqflite.firstIntValue(
        await txn.rawQuery(
          'SELECT COUNT(*) FROM accounts WHERE profile_id = ?',
          [profileId],
        ),
      );

      if (allAccountsCount != null && allAccountsCount > 1) {
        await txn.delete('accounts', where: 'id = ?', whereArgs: [id]);
        // If the deleted account was default, set another to default
        if (fallbackId.isNotEmpty && defaultAccounts.isEmpty) {
          await txn.rawUpdate(
            'UPDATE accounts SET is_default = 1 WHERE id = ?',
            [fallbackId],
          );
        }
      } else {
        // Can't delete last account
        throw ArgumentError("Cannot delete the last account in a profile");
      }
    });
  }

  Future<List<AccountModel>> getByProfileId(String profileId) async {
    final db = await _db;
    final maps = await db.query(
      'accounts',
      where: 'profile_id = ?',
      whereArgs: [profileId],
    );

    return maps.map((map) => AccountModel.fromMap(map)).toList();
  }

  Future<AccountModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query('accounts', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return AccountModel.fromMap(maps.first);
  }

  Future<Map<String, double>> getAccountBalances(String profileId) async {
    final db = await _db;

    // Sign is applied within query (if 'income' it's + amount, if 'expense' it's - amount)
    final results = await db.rawQuery(
      '''
      SELECT account, 
             SUM(CASE WHEN type = 'income' THEN amount ELSE -amount END) as balance 
      FROM transactions 
      WHERE profile_id = ? AND account IS NOT NULL
      GROUP BY account
    ''',
      [profileId],
    );

    final Map<String, double> balances = {};
    for (var row in results) {
      if (row['account'] != null && row['balance'] != null) {
        balances[row['account'] as String] = (row['balance'] as num).toDouble();
      }
    }

    return balances;
  }
}
