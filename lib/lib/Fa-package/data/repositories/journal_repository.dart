import '../database/database_service.dart';
import '../models/journal.dart';
import '../models/ledger.dart';

class JournalRepository {
  final DatabaseService _databaseService;

  JournalRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  Future<int> createJournal(Journal journal) async {
    final db = await _databaseService.database;
    return await db.insert('journals', journal.toMap());
  }

  Future<int> updateJournal(Journal journal) async {
    final db = await _databaseService.database;
    return await db.update(
      'journals',
      journal.toMap(),
      where: 'id = ?',
      whereArgs: [journal.id],
    );
  }

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

  Future<Journal?> getJournalById(int id) async {
    final db = await _databaseService.database;
    final result = await db.query('journals', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    final journal = Journal.fromMap(result.first);

    // Get journal entries
    final entriesResult = await db.query(
      'journal_entries',
      where: 'journal_id = ?',
      whereArgs: [id],
    );

    final entries = entriesResult.map((e) => JournalEntry.fromMap(e)).toList();

    // Get account names and numbers
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final accountResult = await db.query(
        'accounts',
        columns: ['account_number', 'name'],
        where: 'id = ?',
        whereArgs: [entry.accountId],
      );

      if (accountResult.isNotEmpty) {
        entries[i] = entry.copyWith(
          accountNumber: accountResult.first['account_number'] as String,
          accountName: accountResult.first['name'] as String,
        );
      }
    }

    return journal.copyWith(entries: entries);
  }

  Future<List<Journal>> getAllJournals() async {
    final db = await _databaseService.database;
    final result = await db.query('journals', orderBy: 'date DESC');
    return result.map((map) => Journal.fromMap(map)).toList();
  }

  Future<int> createJournalEntry(JournalEntry entry) async {
    final db = await _databaseService.database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<int> updateJournalEntry(JournalEntry entry) async {
    final db = await _databaseService.database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteJournalEntry(int id) async {
    final db = await _databaseService.database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<JournalEntry>> getEntriesByJournalId(int journalId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'journal_entries',
      where: 'journal_id = ?',
      whereArgs: [journalId],
    );

    final entries = result.map((e) => JournalEntry.fromMap(e)).toList();

    // Get account names and numbers
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final accountResult = await db.query(
        'accounts',
        columns: ['account_number', 'name'],
        where: 'id = ?',
        whereArgs: [entry.accountId],
      );

      if (accountResult.isNotEmpty) {
        entries[i] = entry.copyWith(
          accountNumber: accountResult.first['account_number'] as String,
          accountName: accountResult.first['name'] as String,
        );
      }
    }

    return entries;
  }

  // Post journal to ledger
  Future<bool> postJournalToLedger(int journalId) async {
    final db = await _databaseService.database;

    // Get the journal
    final journalResult = await db.query(
      'journals',
      where: 'id = ?',
      whereArgs: [journalId],
    );

    if (journalResult.isEmpty) {
      return false;
    }

    final journal = Journal.fromMap(journalResult.first);

    // Check if already posted
    if (journal.isPosted) {
      return false;
    }

    // Get the journal entries
    final entriesResult = await db.query(
      'journal_entries',
      where: 'journal_id = ?',
      whereArgs: [journalId],
    );

    final entries = entriesResult.map((e) => JournalEntry.fromMap(e)).toList();

    // Begin transaction
    await db.transaction((txn) async {
      for (final entry in entries) {
        // Get the latest balance for this account
        final balanceResult = await txn.query(
          'ledger',
          columns: ['balance'],
          where: 'account_id = ?',
          whereArgs: [entry.accountId],
          orderBy: 'id DESC',
          limit: 1,
        );

        double previousBalance = 0.0;
        if (balanceResult.isNotEmpty) {
          previousBalance = balanceResult.first['balance'] as double;
        }

        // Calculate new balance (depends on account type)
        final accountResult = await txn.query(
          'accounts',
          columns: ['type_id'],
          where: 'id = ?',
          whereArgs: [entry.accountId],
        );

        int accountTypeId = accountResult.first['type_id'] as int;

        double newBalance = previousBalance;

        // For asset and expense accounts, debit increases, credit decreases
        if (accountTypeId == 1 || accountTypeId == 5) {
          newBalance = previousBalance + entry.debit - entry.credit;
        }
        // For liability, equity, and revenue accounts, credit increases, debit decreases
        else {
          newBalance = previousBalance - entry.debit + entry.credit;
        }

        // Insert into ledger
        await txn.insert('ledger', {
          'account_id': entry.accountId,
          'journal_id': journalId,
          'entry_id': entry.id!,
          'date': journal.date.toIso8601String(),
          'debit': entry.debit,
          'credit': entry.credit,
          'balance': newBalance,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Update journal as posted
      await txn.update(
        'journals',
        {'is_posted': 1, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [journalId],
      );
    });

    return true;
  }
}
