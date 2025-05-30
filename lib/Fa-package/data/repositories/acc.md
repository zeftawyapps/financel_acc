# Account Repository Documentation

This document provides a detailed explanation of the `account_repository.dart` file which is a core component of the Financial Accounting application. The repository handles all database operations related to accounts.

## Overview

The `AccountRepository` class serves as a data access layer for the application, providing methods to interact with the database for account-related operations. It uses the Repository pattern to abstract the data storage implementation details from the rest of the application.

## Class Structure

### Imports

```dart
import '../database/database_service.dart';
import '../models/account.dart';
```

- `database_service.dart`: Provides database connection and general database operations
- `account.dart`: Contains the Account and AccountType model classes used in this repository

### Constructor

```dart
final DatabaseService _databaseService;

AccountRepository({required DatabaseService databaseService})
  : _databaseService = databaseService;
```

- Uses dependency injection to receive a `DatabaseService` instance
- Stores the service in a private field `_databaseService` for database access throughout the class
- The initializer list syntax (`:`) assigns the parameter to the field during object construction

## Methods

### getAllAccountTypes()

```dart
Future<List<AccountType>> getAllAccountTypes() async {
  final db = await _databaseService.database;
  final result = await db.query('account_types');
  return result.map((map) => AccountType.fromMap(map)).toList();
}
```

- **Purpose**: Retrieves all account types from the database
- **Return Type**: `Future<List<AccountType>>` - A promise that resolves to a list of AccountType objects
- **Implementation**:
  1. Awaits the database connection from the database service
  2. Queries all records from the 'account_types' table
  3. Maps each row (as a Map) to an AccountType object using the fromMap factory method
  4. Converts the mapped results to a List and returns it

### getAccountTypeById(int id)

```dart
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
```

- **Purpose**: Finds a specific account type by its ID
- **Parameters**: `int id` - The ID of the account type to find
- **Return Type**: `Future<AccountType?>` - A nullable future that resolves to an AccountType or null if not found
- **Implementation**:
  1. Gets the database connection
  2. Queries the 'account_types' table with a WHERE clause to find a specific ID
  3. Uses parameterized query with '?' placeholder and whereArgs for SQL injection protection
  4. Checks if result is empty and returns null in that case
  5. Otherwise, converts the first row to an AccountType object and returns it

### createAccount(Account account)

```dart
Future<int> createAccount(Account account) async {
  final db = await _databaseService.database;
  return await db.insert('accounts', account.toMap());
}
```

- **Purpose**: Creates a new account record in the database
- **Parameters**: `Account account` - The account object to insert
- **Return Type**: `Future<int>` - The ID of the newly created account
- **Implementation**:
  1. Gets the database connection
  2. Converts the Account object to a Map using the toMap() method
  3. Inserts the map into the 'accounts' table
  4. Returns the ID of the newly inserted row

### updateAccount(Account account)

```dart
Future<int> updateAccount(Account account) async {
  final db = await _databaseService.database;
  return await db.update(
    'accounts',
    account.toMap(),
    where: 'id = ?',
    whereArgs: [account.id],
  );
}
```

- **Purpose**: Updates an existing account record
- **Parameters**: `Account account` - The account object with updated values (must include id)
- **Return Type**: `Future<int>` - Number of rows affected (typically 1 or 0)
- **Implementation**:
  1. Gets the database connection
  2. Uses the update method with:
     - Target table: 'accounts'
     - Data: account.toMap()
     - WHERE clause to target specific account ID
     - account.id in whereArgs array for parameterized query
  3. Returns the count of rows modified

### deleteAccount(int id)

```dart
Future<int> deleteAccount(int id) async {
  final db = await _databaseService.database;
  return await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
}
```

- **Purpose**: Deletes an account from the database
- **Parameters**: `int id` - ID of the account to delete
- **Return Type**: `Future<int>` - Number of rows deleted (typically 1 or 0)
- **Implementation**:
  1. Gets the database connection
  2. Calls delete method on the 'accounts' table
  3. Uses WHERE clause with parameterized query for the account ID
  4. Returns the count of rows deleted

### getAccountById(int id)

```dart
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
```

- **Purpose**: Retrieves a single account with its account type by ID
- **Parameters**: `int id` - ID of the account to retrieve
- **Return Type**: `Future<Account?>` - Nullable Account object
- **Implementation**:
  1. Gets the database connection
  2. Queries the 'accounts' table for a specific ID
  3. Returns null if no matching account found
  4. Otherwise:
     - Creates an Account object from the database row
     - Retrieves the associated AccountType using getAccountTypeById
     - Returns a new copy of the account with the accountType field populated

### getAccountByNumber(String accountNumber)

```dart
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
```

- **Purpose**: Finds an account by its account number
- **Parameters**: `String accountNumber` - The account number to search for
- **Return Type**: `Future<Account?>` - Nullable Account object
- **Implementation**:
  1. Gets the database connection
  2. Queries accounts table where account_number matches parameter
  3. Returns null if no matching account found
  4. Otherwise returns an Account object from the first matching row
  5. Note: Unlike getAccountById, this doesn't populate the accountType field

### getAllAccounts()

```dart
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
```

- **Purpose**: Retrieves all accounts with their account types
- **Return Type**: `Future<List<Account>>` - List of all accounts
- **Implementation**:
  1. Gets the database connection
  2. Queries all accounts, ordering by account_number
  3. Optimizes by retrieving all account types in one query
  4. Creates a lookup map where keys are type IDs and values are AccountType objects
  5. Maps each row to an Account object
  6. Populates the accountType field for each account using the lookup map
  7. Returns the complete list

### getAccountsByType(int typeId)

```dart
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
```

- **Purpose**: Retrieves accounts filtered by their type ID
- **Parameters**: `int typeId` - ID of the account type to filter by
- **Return Type**: `Future<List<Account>>` - List of matching accounts
- **Implementation**:
  1. Gets the database connection
  2. Queries accounts with the given type_id, ordered by account_number
  3. Retrieves the AccountType object once (optimization)
  4. Maps each row to an Account object
  5. Attaches the same AccountType to all accounts (since they all have the same type)
  6. Returns the list of accounts with types

### getAccountsByParent(int? parentId)

```dart
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
```

- **Purpose**: Retrieves accounts based on their parent account ID
- **Parameters**: `int? parentId` - Nullable ID of the parent account (null to get root accounts)
- **Return Type**: `Future<List<Account>>` - List of child accounts
- **Implementation**:
  1. Gets the database connection
  2. Handles two scenarios with dynamic SQL:
     - If parentId is null: finds accounts where parent_id IS NULL (root accounts)
     - If parentId has a value: finds accounts with that specific parent_id
  3. Builds the appropriate WHERE clause and arguments
  4. Queries the accounts table with the constructed conditions
  5. Similar to getAllAccounts, optimizes account type lookup
  6. Returns the populated account list

### getAccountsTree()

```dart
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
```

- **Purpose**: Builds a hierarchical tree structure of accounts
- **Return Type**: `Future<List<Account>>` - Tree of accounts starting from root accounts
- **Implementation**:
  1. Retrieves all accounts with their types using getAllAccounts()
  2. Creates a lookup map for quick access to accounts by ID
  3. Filters to get only root accounts (those with null parentId)
  4. Defines a nested recursive function buildTree that:
     - Takes a list of accounts
     - For each account, finds all its children (accounts with matching parentId)
     - If no children, returns the account unchanged
     - Otherwise recursively builds the tree for children and attaches them
  5. Starts the recursion with root accounts and returns the complete tree

### getAccountBalance(int accountId)

```dart
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
```

- **Purpose**: Retrieves the current balance of a specific account
- **Parameters**: `int accountId` - ID of the account to get balance for
- **Return Type**: `Future<double>` - The current balance
- **Implementation**:
  1. Gets the database connection
  2. Queries the 'ledger' table for the latest entry of the specified account
     - Uses account_id to filter
     - Orders by id DESC (newest first)
     - Limits to 1 result (only want the latest)
  3. If no ledger entries exist, returns 0.0 as the default balance
  4. Otherwise, extracts the 'balance' field from the first result and returns it as a double

## Database Schema Insights

From this repository implementation, we can infer the following about the database schema:

1. **account_types table**:

   - Has id as primary key
   - Stores different types of accounts

2. **accounts table**:

   - Has id as primary key
   - Contains account_number field (unique identifier for accounts)
   - Contains type_id as a foreign key to account_types
   - Contains parent_id as a self-referencing foreign key (for account hierarchy)
   - Supports tree structure with parent-child relationships

3. **ledger table**:
   - Contains account_id as foreign key to accounts
   - Stores balance information for each account
   - Has id field for tracking entry sequence
   - Likely contains transaction information (though not directly accessed in this repository)

## Design Patterns

1. **Repository Pattern**: Isolates data access code from the rest of the application
2. **Dependency Injection**: Database service is injected rather than created internally
3. **Factory Methods**: Uses fromMap to create objects from database rows
4. **Immutable Objects**: Uses copyWith pattern for non-destructive updates

## Performance Considerations

1. Optimizes database queries for account type lookup by:

   - Fetching all types at once and creating a lookup map
   - Avoiding multiple database queries for the same information

2. Uses efficient tree building algorithm with:
   - Single query to fetch all accounts
   - Map-based lookups rather than repeated filtering
   - Recursive approach to build the entire tree structure
