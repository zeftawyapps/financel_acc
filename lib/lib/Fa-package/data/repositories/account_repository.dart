import '../database/database_service.dart';
import '../models/account.dart';

class AccountRepository {
  final DatabaseService _databaseService;

  AccountRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  Future<List<AccountType>> getAllAccountTypes() async {
    final db = await _databaseService.database;
    final result = await db.query('account_types');
    return result.map((map) => AccountType.fromMap(map)).toList();
  }

  Future<AccountType?> getAccountTypeById(int id) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'account_types',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return AccountType.fromMap(result.first);
  }

  Future<int> createAccount(Account account) async {
    final db = await _databaseService.database;
    return await db.insert('accounts', account.toMap());
  }

  Future<int> updateAccount(Account account) async {
    final db = await _databaseService.database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await _databaseService.database;
    return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
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

  Future<List<Account>> getAccountsTree() async {
    // Get all accounts
    final allAccounts = await getAllAccounts();

    // Create a map for quick lookup
    final accountsMap = {for (var account in allAccounts) account.id: account};

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

  // Get account balance
  Future<double> getAccountBalance(int accountId) async {
    final db = await _databaseService.database;

    // Get the latest ledger entry for this account
    final result = await db.query(
      'ledger',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      return 0.0;
    }

    return result.first['balance'] as double;
  }
}
