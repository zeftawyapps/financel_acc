import '../database/database_service.dart'; // Import for database access
import '../models/account.dart'; // Import for Account and AccountType model classes

/// Repository class that handles all account-related database operations
/// Uses the Repository pattern to abstract database interactions
class AccountRepository {
  /// Database service instance for executing queries
  final DatabaseService _databaseService;

  /// Constructor with dependency injection
  /// @param databaseService - Required service to handle database connections
  AccountRepository({required DatabaseService databaseService})
    : _databaseService =
          databaseService; // Initializer list assigns parameter to field

  /// Retrieves all account types from the database
  /// @return Future<List<AccountType>> - Promise that resolves to all account types
  Future<List<AccountType>> getAllAccountTypes() async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query('account_types'); // Query all account types
    return result
        .map((map) => AccountType.fromMap(map))
        .toList(); // Convert rows to objects and return as List
  }

  /// Retrieves a specific account type by ID
  /// @param id - The ID of the account type to find
  /// @return Future<AccountType?> - Nullable AccountType (null if not found)
  Future<AccountType?> getAccountTypeById(int id) async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query(
      'account_types',
      where: 'id = ?', // SQL WHERE clause with parameter placeholder
      whereArgs: [id], // Parameter value (prevents SQL injection)
    );

    if (result.isEmpty) {
      return null; // Return null if no matching record found
    }

    return AccountType.fromMap(
      result.first,
    ); // Convert first row to AccountType object
  }

  /// Creates a new account record in the database
  /// @param account - The account object to be inserted
  /// @return Future<int> - ID of the newly created account
  Future<int> createAccount(Account account) async {
    final db = await _databaseService.database; // Get database connection
    return await db.insert(
      'accounts',
      account.toMap(),
    ); // Insert account and return new ID
  }

  /// Updates an existing account record in the database
  /// @param account - The account object with updated values
  /// @return Future<int> - Number of affected rows (usually 1)
  Future<int> updateAccount(Account account) async {
    final db = await _databaseService.database; // Get database connection
    return await db.update(
      'accounts',
      account.toMap(), // Convert account to map for database
      where: 'id = ?', // SQL WHERE clause with parameter placeholder
      whereArgs: [account.id], // Parameter value (prevents SQL injection)
    );
  }

  /// Deletes an account record from the database
  /// @param id - ID of the account to delete
  /// @return Future<int> - Number of affected rows (usually 1)
  Future<int> deleteAccount(int id) async {
    final db = await _databaseService.database; // Get database connection
    return await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: [id],
    ); // Delete account with given ID
  }

  Future<Account?> getAccountById(int id) async {
    final db = await _databaseService.database;
    final result = await db.query('accounts', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    final account = Account.fromMap(result.first);
    final accountType = await getAccountTypeById(account.typeId);

    return account.copyWith(accountType: accountType);
  }

  Future<Account?> getAccountByNumber(String accountNumber) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'accounts',
      where: 'account_number = ?',
      whereArgs: [accountNumber],
    );

    if (result.isEmpty) {
      return null;
    }

    return Account.fromMap(result.first);
  }

  Future<List<Account>> getAllAccounts() async {
    final db = await _databaseService.database;
    final result = await db.query('accounts', orderBy: 'account_number');

    // Get all account types for efficient mapping
    final accountTypes = await getAllAccountTypes();
    final accountTypesMap = {for (var type in accountTypes) type.id: type};

    return result.map((map) {
      final account = Account.fromMap(map);
      return account.copyWith(accountType: accountTypesMap[account.typeId]);
    }).toList();
  }

  Future<List<Account>> getAccountsByType(int typeId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'accounts',
      where: 'type_id = ?',
      whereArgs: [typeId],
      orderBy: 'account_number',
    );

    final accountType = await getAccountTypeById(typeId);

    return result.map((map) {
      final account = Account.fromMap(map);
      return account.copyWith(accountType: accountType);
    }).toList();
  }

  Future<List<Account>> getAccountsByParent(int? parentId) async {
    final db = await _databaseService.database;

    String whereClause =
        parentId == null ? 'parent_id IS NULL' : 'parent_id = ?';
    List<dynamic> whereArgs = parentId == null ? [] : [parentId];

    final result = await db.query(
      'accounts',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'account_number',
    );

    // Get all account types for efficient mapping
    final accountTypes = await getAllAccountTypes();
    final accountTypesMap = {for (var type in accountTypes) type.id: type};

    return result.map((map) {
      final account = Account.fromMap(map);
      return account.copyWith(accountType: accountTypesMap[account.typeId]);
    }).toList();
  }

  /// Builds a hierarchical tree structure of all accounts
  /// @return Future<List<Account>> - Tree structure with parent-child relationships
  Future<List<Account>> getAccountsTree() async {
    // Get all accounts with their types populated
    final allAccounts = await getAllAccounts();

    // Get root accounts (accounts with no parent)
    final rootAccounts =
        allAccounts.where((account) => account.parentId == null).toList();

    // Build the tree structure recursively
    List<Account> buildTree(List<Account> accounts) {
      return accounts.map((account) {
        final children =
            allAccounts.where((a) => a.parentId == account.id).toList();

        if (children.isEmpty) {
          return account;
        }

        return account.copyWith(children: buildTree(children));
      }).toList();
    }

    return buildTree(rootAccounts);
  }

  /// Gets the current balance for a specific account
  /// @param accountId - ID of the account to check balance for
  /// @return Future<double> - Current balance of the account
  Future<double> getAccountBalance(int accountId) async {
    final db = await _databaseService.database; // Get database connection

    // Get the latest ledger entry for this account
    final result = await db.query(
      'ledger',
      where: 'account_id = ?', // Filter by account ID
      whereArgs: [accountId], // Parameter value
      orderBy: 'id DESC', // Get most recent entry first
      limit: 1, // Only need the latest entry
    );

    if (result.isEmpty) {
      return 0.0; // Return zero balance if no ledger entries exist
    }

    return result.first['balance'] as double; // Return the current balance
  }
}
