import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database singleton for CashWand.
class AppDatabase {
  static const String _databaseName = 'expense_tracker.db';
  static const int _databaseVersion = 6;

  // Singleton instance
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _database;

  /// Returns the database instance, creating it on first access.
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Creates all tables on first install.
  Future<void> _onCreate(Database db, int version) async {
    // Profiles table
    await db.execute('''
      CREATE TABLE profiles (
        id          TEXT PRIMARY KEY,
        name        TEXT    NOT NULL,
        is_default  INTEGER NOT NULL DEFAULT 0,
        created_at  TEXT    NOT NULL
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id          TEXT PRIMARY KEY,
        profile_id  TEXT NOT NULL,
        name        TEXT NOT NULL,
        icon        TEXT NOT NULL,
        color       TEXT NOT NULL,
        is_system   INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');

    // Accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id          TEXT PRIMARY KEY,
        profile_id  TEXT NOT NULL,
        name        TEXT NOT NULL,
        type        TEXT NOT NULL,
        icon        TEXT NOT NULL,
        is_default  INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
      )
    ''');

    // Transactions table (includes profile_id from the start)
    await db.execute('''
      CREATE TABLE transactions (
        id          TEXT PRIMARY KEY,
        amount      REAL    NOT NULL,
        type        TEXT    NOT NULL,
        category    TEXT    NOT NULL,
        account     TEXT,
        description TEXT    NOT NULL DEFAULT '',
        date        TEXT    NOT NULL,
        created_at  TEXT    NOT NULL,
        profile_id  TEXT    NOT NULL DEFAULT 'default',
        FOREIGN KEY (profile_id) REFERENCES profiles (id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_date ON transactions (date DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_category ON transactions (category)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_type_date ON transactions (type, date)
    ''');

    await db.execute('''
      CREATE INDEX idx_transactions_profile ON transactions (profile_id)
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id          TEXT PRIMARY KEY,
        amount      REAL    NOT NULL,
        category    TEXT,
        year        INTEGER NOT NULL,
        month       INTEGER NOT NULL,
        created_at  TEXT    NOT NULL,
        profile_id  TEXT    NOT NULL DEFAULT 'default',
        UNIQUE(profile_id, category, year, month)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // v1 → v2: Add account column to transactions
      await db.execute('ALTER TABLE transactions ADD COLUMN account TEXT');

      // v1 → v2: Create budgets table
      await db.execute('''
        CREATE TABLE budgets (
          id          TEXT PRIMARY KEY,
          amount      REAL    NOT NULL,
          category    TEXT,
          year        INTEGER NOT NULL,
          month       INTEGER NOT NULL,
          created_at  TEXT    NOT NULL,
          profile_id  TEXT    NOT NULL DEFAULT 'default',
          UNIQUE(profile_id, category, year, month)
        )
      ''');
    }

    if (oldVersion < 3) {
      // v2 → v3: Create profiles table
      await db.execute('''
        CREATE TABLE profiles (
          id          TEXT PRIMARY KEY,
          name        TEXT    NOT NULL,
          is_default  INTEGER NOT NULL DEFAULT 0,
          created_at  TEXT    NOT NULL
        )
      ''');

      // Insert a default "Personal" profile for existing users
      await db.execute('''
        INSERT INTO profiles (id, name, is_default, created_at)
        VALUES ('default', 'Personal', 1, '${DateTime.now().toIso8601String()}')
      ''');

      // Add profile_id column to transactions, defaulting existing rows to 'default'
      await db.execute(
        "ALTER TABLE transactions ADD COLUMN profile_id TEXT NOT NULL DEFAULT 'default'",
      );

      // Index for profile-based queries
      await db.execute('''
        CREATE INDEX idx_transactions_profile ON transactions (profile_id)
      ''');
    }

    if (oldVersion < 5) {
      // v3/v4 → v5: Create categories table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id          TEXT PRIMARY KEY,
          profile_id  TEXT NOT NULL,
          name        TEXT NOT NULL,
          icon        TEXT NOT NULL,
          color       TEXT NOT NULL,
          is_system   INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
        )
      ''');

      // v3/v4 → v5: Create accounts table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
          id          TEXT PRIMARY KEY,
          profile_id  TEXT NOT NULL,
          name        TEXT NOT NULL,
          type        TEXT NOT NULL,
          icon        TEXT NOT NULL,
          is_default  INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 6) {
      // v5 → v6: Add profile_id to budgets table
      // SQLite doesn't let you add a UNIQUE constraint with ALTER TABLE easily without recreating the table.
      // We will recreate the budgets table with the new constraints, copying over the existing data.
      await db.execute('''
        CREATE TABLE budgets_new (
          id          TEXT PRIMARY KEY,
          amount      REAL    NOT NULL,
          category    TEXT,
          year        INTEGER NOT NULL,
          month       INTEGER NOT NULL,
          created_at  TEXT    NOT NULL,
          profile_id  TEXT    NOT NULL DEFAULT 'default',
          UNIQUE(profile_id, category, year, month)
        )
      ''');

      // Check if budgets table exists (it might not if they started on v4 or v5 but never created budgets)
      var res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='budgets'",
      );
      if (res.isNotEmpty) {
        await db.execute('''
          INSERT INTO budgets_new (id, amount, category, year, month, created_at)
          SELECT id, amount, category, year, month, created_at FROM budgets
        ''');
        await db.execute('DROP TABLE budgets');
      }

      await db.execute('ALTER TABLE budgets_new RENAME TO budgets');
    }
  }

  /// Closes the database connection.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
