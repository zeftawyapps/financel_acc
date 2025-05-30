# Journal Repository Documentation

This document provides a detailed explanation of the `journal_repository.dart` file which is a core component of the Financial Accounting application. The repository handles all database operations related to journals and journal entries.

## Overview

The `JournalRepository` class serves as a data access layer for the application, providing methods to interact with the database for journal-related operations. It uses the Repository pattern to abstract the data storage implementation details from the rest of the application. It also handles the crucial accounting operation of posting journals to the ledger.

## Class Structure

### Imports

```dart
import '../database/database_service.dart';
import '../models/journal.dart';
import '../models/ledger.dart';
```

- `database_service.dart`: Provides database connection and general database operations
- `journal.dart`: Contains the Journal and JournalEntry model classes
- `ledger.dart`: Contains the Ledger model class, used when posting to the ledger

### Constructor

```dart
final DatabaseService _databaseService;

JournalRepository({required DatabaseService databaseService})
  : _databaseService = databaseService;
```

- Uses dependency injection to receive a `DatabaseService` instance
- Stores the service in a private field `_databaseService` for database access throughout the class
- The initializer list syntax (`:`) assigns the parameter to the field during object construction

## Methods

### createJournal(Journal journal)

```dart
Future<int> createJournal(Journal journal) async {
  final db = await _databaseService.database;
  return await db.insert('journals', journal.toMap());
}
```

- **Purpose**: Creates a new journal record in the database
- **Parameters**: `Journal journal` - The journal object to insert
- **Return Type**: `Future<int>` - The ID of the newly created journal
- **Implementation**:
  1. Gets the database connection
  2. Converts the Journal object to a Map using the toMap() method
  3. Inserts the map into the 'journals' table
  4. Returns the ID of the newly inserted row

### updateJournal(Journal journal)

```dart
Future<int> updateJournal(Journal journal) async {
  final db = await _databaseService.database;
  return await db.update(
    'journals',
    journal.toMap(),
    where: 'id = ?',
    whereArgs: [journal.id],
  );
}
```

- **Purpose**: Updates an existing journal record
- **Parameters**: `Journal journal` - The journal object with updated values (must include id)
- **Return Type**: `Future<int>` - Number of rows affected (typically 1 or 0)
- **Implementation**:
  1. Gets the database connection
  2. Uses the update method with:
     - Target table: 'journals'
     - Data: journal.toMap()
     - WHERE clause to target specific journal ID
     - journal.id in whereArgs array for parameterized query
  3. Returns the count of rows modified

### deleteJournal(int id)

```dart
Future<int> deleteJournal(int id) async {
  final db = await _databaseService.database;

  // First delete all journal entries
  await db.delete(
    'journal_entries',
    where: 'journal_id = ?',
    whereArgs: [id],
  );

  // Delete ledger entries if there are any
  await db.delete('ledger', where: 'journal_id = ?', whereArgs: [id]);

  // Then delete the journal
  return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
}
```

- **Purpose**: Deletes a journal and its related records from the database
- **Parameters**: `int id` - ID of the journal to delete
- **Return Type**: `Future<int>` - Number of journal rows deleted (typically 1 or 0)
- **Implementation**:
  1. Gets the database connection
  2. Handles cascading delete in a specific order:
     - First deletes all related journal entries
     - Then deletes any related ledger entries
     - Finally deletes the journal itself
  3. Returns the count of deleted journal rows

### getJournalById(int id)

```dart
Future<Journal?> getJournalById(int id) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Retrieves a single journal with all its entries by ID
- **Parameters**: `int id` - ID of the journal to retrieve
- **Return Type**: `Future<Journal?>` - Nullable Journal object
- **Implementation**:
  1. Gets the database connection
  2. Queries the 'journals' table for a specific ID
  3. Returns null if no matching journal found
  4. Otherwise:
     - Creates a Journal object from the database row
     - Fetches all associated journal entries
     - Enriches each entry with account information
     - Returns a new copy of the journal with the entries field populated

### getAllJournals()

```dart
Future<List<Journal>> getAllJournals() async {
  final db = await _databaseService.database;
  final result = await db.query('journals', orderBy: 'date DESC');
  return result.map((map) => Journal.fromMap(map)).toList();
}
```

- **Purpose**: Retrieves all journals from the database
- **Return Type**: `Future<List<Journal>>` - List of all journals
- **Implementation**:
  1. Gets the database connection
  2. Queries all journals, ordering by date in descending order (newest first)
  3. Maps each row to a Journal object
  4. Returns the list of Journal objects
  5. Note: This doesn't fetch journal entries for performance reasons

### createJournalEntry(JournalEntry entry)

```dart
Future<int> createJournalEntry(JournalEntry entry) async {
  final db = await _databaseService.database;
  return await db.insert('journal_entries', entry.toMap());
}
```

- **Purpose**: Creates a new journal entry record in the database
- **Parameters**: `JournalEntry entry` - The journal entry object to insert
- **Return Type**: `Future<int>` - The ID of the newly created journal entry
- **Implementation**:
  1. Gets the database connection
  2. Converts the JournalEntry object to a Map using the toMap() method
  3. Inserts the map into the 'journal_entries' table
  4. Returns the ID of the newly inserted row

### updateJournalEntry(JournalEntry entry)

```dart
Future<int> updateJournalEntry(JournalEntry entry) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Updates an existing journal entry record
- **Parameters**: `JournalEntry entry` - The entry object with updated values
- **Return Type**: `Future<int>` - Number of rows affected
- **Implementation**: Similar to updateJournal but for journal entries

### deleteJournalEntry(int id)

```dart
Future<int> deleteJournalEntry(int id) async {
  final db = await _databaseService.database;
  return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
}
```

- **Purpose**: Deletes a journal entry from the database
- **Parameters**: `int id` - ID of the journal entry to delete
- **Return Type**: `Future<int>` - Number of rows deleted
- **Implementation**:
  1. Gets the database connection
  2. Deletes the entry with the specified ID from the journal_entries table
  3. Returns the count of rows deleted

### getEntriesByJournalId(int journalId)

```dart
Future<List<JournalEntry>> getEntriesByJournalId(int journalId) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Retrieves all entries for a specific journal
- **Parameters**: `int journalId` - ID of the journal to get entries for
- **Return Type**: `Future<List<JournalEntry>>` - List of journal entries
- **Implementation**:
  1. Gets entries for the specified journal ID
  2. Enriches each entry with account information (name and number)

### postJournalToLedger(int journalId)

```dart
Future<bool> postJournalToLedger(int journalId) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Posts a journal to the ledger (key accounting function)
- **Parameters**: `int journalId` - ID of the journal to post
- **Return Type**: `Future<bool>` - Success or failure of the posting operation
- **Implementation**:
  1. Checks if the journal exists and is not already posted
  2. Gets all entries for the journal
  3. Performs a database transaction to ensure atomicity:
     - For each entry, calculates the new account balance based on accounting rules
     - Creates ledger entries with the updated balances
     - Marks the journal as posted
  4. Returns true if posting was successful

## Database Schema Insights

From this repository implementation, we can infer the following about the database schema:

1. **journals table**:

   - Has id as primary key
   - Contains date field for the journal date
   - Has reference_number field for journal identification
   - Contains is_posted flag to track posting status
   - Has created_at and updated_at timestamp fields

2. **journal_entries table**:

   - Has id as primary key
   - Contains journal_id as a foreign key to journals
   - Contains account_id as a foreign key to accounts
   - Stores debit and credit amounts
   - Linked to both journals and accounts

3. **ledger table**:

   - Contains account_id, journal_id, and entry_id as foreign keys
   - Stores date, debit, credit, and balance information
   - Records the running balance for each account
   - Contains created_at timestamp

4. **accounts table**:

   - Has id as primary key
   - Contains account_number and name fields
   - Has type_id field indicating the account type

5. **account_types table**:
   - Has id as primary key
   - Types appear to include:
     - 1: Assets
     - 2: Liabilities
     - 3: Equity
     - 4: Revenue
     - 5: Expenses

## Accounting Rules Implemented

1. **Double-Entry Bookkeeping**:

   - Each transaction affects at least two accounts
   - The sum of debits equals the sum of credits

2. **Account Type Balance Rules**:

   - Assets and Expenses: Debit increases, Credit decreases
   - Liabilities, Equity, and Revenue: Credit increases, Debit decreases

3. **Journal Posting Process**:
   - Journals are created with entries
   - Journals are posted to the ledger
   - Posting creates ledger entries that update account balances
   - Posting is a one-time operation (prevented by the is_posted flag)

## Design Patterns

1. **Repository Pattern**: Isolates data access code from the rest of the application
2. **Dependency Injection**: Database service is injected rather than created internally
3. **Factory Methods**: Uses fromMap to create objects from database rows
4. **Immutable Objects**: Uses copyWith pattern for non-destructive updates
5. **Transaction Pattern**: Uses database transactions to ensure atomicity of complex operations

## Performance Considerations

1. **Selective Data Loading**:

   - getAllJournals() doesn't fetch entries for better performance
   - getJournalById() fetches all details including entries and account information

2. **Cascading Deletes**:

   - Handles related records deletion in the correct order

3. **Transaction Use**:
   - Uses database transactions for the critical posting operation to ensure data integrity
