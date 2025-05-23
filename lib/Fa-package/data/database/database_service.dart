import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Ensure SQLite is initialized for FFI (needed for Windows)
    sqfliteFfiInit();

    // Get the database path
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'financial_accounting.db');

    // Open the database with FFI factory
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create account types table
    await db.execute('''
      CREATE TABLE account_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL
      )
    ''');

    // Create accounts table with tree structure support
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_number TEXT NOT NULL,
        name TEXT NOT NULL,
        type_id INTEGER NOT NULL,
        parent_id INTEGER,
        level INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (type_id) REFERENCES account_types (id),
        FOREIGN KEY (parent_id) REFERENCES accounts (id)
      )
    ''');

    // Create journals table
    await db.execute('''
      CREATE TABLE journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reference_number TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        is_posted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create journal entries table
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        journal_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        description TEXT,
        debit REAL NOT NULL DEFAULT 0,
        credit REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (journal_id) REFERENCES journals (id),
        FOREIGN KEY (account_id) REFERENCES accounts (id)
      )
    ''');

    // Create ledger table
    await db.execute('''
      CREATE TABLE ledger (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account_id INTEGER NOT NULL,
        journal_id INTEGER NOT NULL,
        entry_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        debit REAL NOT NULL DEFAULT 0,
        credit REAL NOT NULL DEFAULT 0,
        balance REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES accounts (id),
        FOREIGN KEY (journal_id) REFERENCES journals (id),
        FOREIGN KEY (entry_id) REFERENCES journal_entries (id)
      )
    ''');

    // Create fiscal_periods table
    await db.execute('''
      CREATE TABLE fiscal_periods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_closed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Insert initial account types
    await db.insert('account_types', {'name': 'Asset', 'code': 'A'});
    await db.insert('account_types', {'name': 'Liability', 'code': 'L'});
    await db.insert('account_types', {'name': 'Equity', 'code': 'E'});
    await db.insert('account_types', {'name': 'Revenue', 'code': 'R'});
    await db.insert('account_types', {'name': 'Expense', 'code': 'X'});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations when schema changes
    if (oldVersion < newVersion) {
      // Add upgrade logic here
    }
  }

  Future<void> clearAllData() async {
    final db = await database;

    // Use transaction to ensure all operations complete or none do
    await db.transaction((txn) async {
      // Delete data from tables in reverse order of dependencies
      await txn.delete('ledger');
      await txn.delete('journal_entries');
      await txn.delete('journals');
      await txn.delete('accounts');
      await txn.delete('account_types');
      await txn.delete('fiscal_periods');

      // Reset auto-increment counters
      await txn.execute('DELETE FROM sqlite_sequence');

      // Re-insert initial account types
      await txn.insert('account_types', {'name': 'Asset', 'code': 'A'});
      await txn.insert('account_types', {'name': 'Liability', 'code': 'L'});
      await txn.insert('account_types', {'name': 'Equity', 'code': 'E'});
      await txn.insert('account_types', {'name': 'Revenue', 'code': 'R'});
      await txn.insert('account_types', {'name': 'Expense', 'code': 'X'});
    });
  }
}
