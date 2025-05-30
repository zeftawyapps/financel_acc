import '../database/database_service.dart'; // Import for database access
import '../models/journal.dart'; // Import for Journal and JournalEntry models
import '../models/ledger.dart'; // Import for Ledger model

/// Repository class that handles all journal-related database operations
/// Uses the Repository pattern to abstract database interactions for journal entries and posting
class JournalRepository {
  /// Database service instance for executing queries
  final DatabaseService _databaseService;

  /// Constructor with dependency injection
  /// @param databaseService - Required service to handle database connections
  JournalRepository({required DatabaseService databaseService})
    : _databaseService =
          databaseService; // Initializer list assigns parameter to field

  /// Creates a new journal record in the database
  /// @param journal - The journal object to be inserted
  /// @return Future<int> - ID of the newly created journal
  Future<int> createJournal(Journal journal) async {
    final db = await _databaseService.database; // Get database connection
    return await db.insert(
      'journals',
      journal.toMap(),
    ); // Insert journal and return new ID
  }

  /// Updates an existing journal record in the database
  /// @param journal - The journal object with updated values
  /// @return Future<int> - Number of affected rows (usually 1)
  Future<int> updateJournal(Journal journal) async {
    final db = await _databaseService.database; // Get database connection
    return await db.update(
      'journals',
      journal.toMap(), // Convert journal to map for database
      where: 'id = ?', // SQL WHERE clause with parameter placeholder
      whereArgs: [journal.id], // Parameter value (prevents SQL injection)
    );
  }

  /// Deletes a journal record and all its related entries from the database
  /// Handles cascading delete of journal entries and ledger entries
  /// @param id - ID of the journal to delete
  /// @return Future<int> - Number of journal rows affected (usually 1)
  Future<int> deleteJournal(int id) async {
    final db = await _databaseService.database; // Get database connection

    // First delete all journal entries
    await db.delete(
      'journal_entries',
      where: 'journal_id = ?', // Filter by journal ID
      whereArgs: [id], // Parameter value
    );

    // Delete ledger entries if there are any
    await db.delete('ledger', where: 'journal_id = ?', whereArgs: [id]);

    // Then delete the journal
    return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  /// Retrieves a single journal with its entries by ID
  /// Also populates account information for each entry
  /// @param id - ID of the journal to retrieve
  /// @return Future<Journal?> - Nullable Journal object (null if not found)
  Future<Journal?> getJournalById(int id) async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query('journals', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null; // Return null if journal not found
    }

    final journal = Journal.fromMap(
      result.first,
    ); // Create Journal object from first row

    // Get journal entries
    final entriesResult = await db.query(
      'journal_entries',
      where: 'journal_id = ?', // Filter by journal ID
      whereArgs: [id], // Parameter value
    );

    // Convert rows to JournalEntry objects
    final entries = entriesResult.map((e) => JournalEntry.fromMap(e)).toList();

    // Get account names and numbers for each entry
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      // Query account information
      final accountResult = await db.query(
        'accounts',
        columns: ['account_number', 'name'], // Only need specific columns
        where: 'id = ?', // Filter by account ID
        whereArgs: [entry.accountId], // Parameter value
      );

      // Enrich entry with account details if found
      if (accountResult.isNotEmpty) {
        entries[i] = entry.copyWith(
          accountNumber: accountResult.first['account_number'] as String,
          accountName: accountResult.first['name'] as String,
        );
      }
    }

    // Return a new copy of the journal with entries populated
    return journal.copyWith(entries: entries);
  }

  /// Retrieves all journals from the database, ordered by date (newest first)
  /// @return Future<List<Journal>> - List of all journals
  Future<List<Journal>> getAllJournals() async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query(
      'journals',
      orderBy: 'date DESC',
    ); // Query all journals, newest first
    return result
        .map((map) => Journal.fromMap(map))
        .toList(); // Convert rows to Journal objects
  }

  /// Creates a new journal entry record in the database
  /// @param entry - The journal entry object to be inserted
  /// @return Future<int> - ID of the newly created journal entry
  Future<int> createJournalEntry(JournalEntry entry) async {
    final db = await _databaseService.database; // Get database connection
    return await db.insert(
      'journal_entries',
      entry.toMap(),
    ); // Insert entry and return new ID
  }

  /// Updates an existing journal entry record in the database
  /// @param entry - The journal entry object with updated values
  /// @return Future<int> - Number of affected rows (usually 1)
  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await _databaseService.database; // Get database connection
    return await db.update(
      'journal_entries',
      entry.toMap(), // Convert entry to map for database
      where: 'id = ?', // SQL WHERE clause with parameter placeholder
      whereArgs: [entry.id], // Parameter value (prevents SQL injection)
    );
  }

  /// Deletes a journal entry record from the database
  /// @param id - ID of the journal entry to delete
  /// @return Future<int> - Number of affected rows (usually 1)
  Future<int> deleteJournalEntry(int id) async {
    final db = await _databaseService.database; // Get database connection
    return await db.delete(
      'journal_entries',
      where: 'id = ?',
      whereArgs: [id],
    ); // Delete entry with given ID
  }

  /// Retrieves all entries for a specific journal, with account details
  /// @param journalId - ID of the journal to get entries for
  /// @return Future<List<JournalEntry>> - List of journal entries with account details
  Future<List<JournalEntry>> getEntriesByJournalId(int journalId) async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query(
      'journal_entries',
      where: 'journal_id = ?', // Filter by journal ID
      whereArgs: [journalId], // Parameter value
    );

    // Convert rows to JournalEntry objects
    final entries = result.map((e) => JournalEntry.fromMap(e)).toList();

    // Enrich entries with account details
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      // Query account information
      final accountResult = await db.query(
        'accounts',
        columns: ['account_number', 'name'], // Only need specific columns
        where: 'id = ?', // Filter by account ID
        whereArgs: [entry.accountId], // Parameter value
      );

      // Add account details to entry if found
      if (accountResult.isNotEmpty) {
        entries[i] = entry.copyWith(
          accountNumber: accountResult.first['account_number'] as String,
          accountName: accountResult.first['name'] as String,
        );
      }
    }

    return entries; // Return the enriched entries
  }

  /// Posts a journal to the ledger, creating ledger entries for each journal entry
  /// Updates account balances and marks the journal as posted
  /// @param journalId - ID of the journal to post
  /// @return Future<bool> - True if posting was successful, false otherwise
  Future<bool> postJournalToLedger(int journalId) async {
    final db = await _databaseService.database; // Get database connection

    // Get the journal record
    final journalResult = await db.query(
      'journals',
      where: 'id = ?', // Filter by journal ID
      whereArgs: [journalId], // Parameter value
    );

    // Return false if journal doesn't exist
    if (journalResult.isEmpty) {
      return false;
    }

    // Convert row to Journal object
    final journal = Journal.fromMap(journalResult.first);

    // Prevent double-posting by checking if already posted
    if (journal.isPosted) {
      return false;
    }

    // Retrieve all entries for this journal
    final entriesResult = await db.query(
      'journal_entries',
      where: 'journal_id = ?', // Filter by journal ID
      whereArgs: [journalId], // Parameter value
    );

    // Convert rows to JournalEntry objects
    final entries = entriesResult.map((e) => JournalEntry.fromMap(e)).toList();

    // Begin database transaction to ensure atomicity
    await db.transaction((txn) async {
      for (final entry in entries) {
        // Get the latest balance for this account
        final balanceResult = await txn.query(
          'ledger',
          columns: ['balance'], // Only need the balance column
          where: 'account_id = ?', // Filter by account ID
          whereArgs: [entry.accountId], // Parameter value
          orderBy: 'id DESC', // Get most recent entry first
          limit: 1, // Only need the latest entry
        );

        // Start with zero balance if no previous entries
        double previousBalance = 0.0;
        if (balanceResult.isNotEmpty) {
          previousBalance = balanceResult.first['balance'] as double;
        }

        // Calculate new balance (depends on account type - accounting principle)
        final accountResult = await txn.query(
          'accounts',
          columns: ['type_id'], // Only need the account type ID
          where: 'id = ?', // Filter by account ID
          whereArgs: [entry.accountId], // Parameter value
        );

        // Get the account type ID to determine debit/credit behavior
        int accountTypeId = accountResult.first['type_id'] as int;

        double newBalance = previousBalance;

        // Apply accounting rules based on account type
        // For asset and expense accounts, debit increases, credit decreases
        if (accountTypeId == 1 || accountTypeId == 5) {
          newBalance = previousBalance + entry.debit - entry.credit;
        }
        // For liability, equity, and revenue accounts, credit increases, debit decreases
        else {
          newBalance = previousBalance - entry.debit + entry.credit;
        }

        // Insert new ledger entry with updated balance
        await txn.insert('ledger', {
          'account_id': entry.accountId,
          'journal_id': journalId,
          'entry_id': entry.id!,
          'date':
              journal.date
                  .toIso8601String(), // Use journal date for all entries
          'debit': entry.debit,
          'credit': entry.credit,
          'balance': newBalance, // Store the new calculated balance
          'created_at': DateTime.now().toIso8601String(), // Current timestamp
        });
      }

      // Mark the journal as posted to prevent double-posting
      await txn.update(
        'journals',
        {
          'is_posted': 1,
          'updated_at': DateTime.now().toIso8601String(),
        }, // Set posted flag and update timestamp
        where: 'id = ?',
        whereArgs: [journalId],
      );
    });

    return true; // Return success
  }
}
