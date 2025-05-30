import '../database/database_service.dart'; // Import for database access
import '../models/ledger.dart'; // Import for Ledger model
import '../models/financial_statement.dart'; // Import for financial statement models
import 'package:intl/intl.dart'; // Import for date formatting

/// Repository class that handles all ledger-related database operations
/// Provides methods for financial reporting and account balance tracking
class LedgerRepository {
  /// Database service instance for executing queries
  final DatabaseService _databaseService;

  /// Constructor with dependency injection
  /// @param databaseService - Required service to handle database connections
  LedgerRepository({required DatabaseService databaseService})
    : _databaseService =
          databaseService; // Initializer list assigns parameter to field

  /// Retrieves ledger entries for a specific account, enriched with account and journal information
  /// @param accountId - ID of the account to get ledger entries for
  /// @return Future<List<Ledger>> - List of ledger entries in chronological order
  Future<List<Ledger>> getLedgerEntriesByAccount(int accountId) async {
    final db = await _databaseService.database; // Get database connection
    final result = await db.query(
      'ledger',
      where: 'account_id = ?', // Filter by account ID
      whereArgs: [accountId], // Parameter value
      orderBy: 'date ASC', // Order by date, oldest first (chronological order)
    );

    // Convert rows to Ledger objects
    final ledgerEntries = result.map((e) => Ledger.fromMap(e)).toList();

    // Get account information (name and number)
    final accountResult = await db.query(
      'accounts',
      columns: ['account_number', 'name'], // Only need these columns
      where: 'id = ?', // Filter by account ID
      whereArgs: [accountId], // Parameter value
    );

    // Initialize account information variables
    String? accountNumber;
    String? accountName;

    // Extract account information if available
    if (accountResult.isNotEmpty) {
      accountNumber = accountResult.first['account_number'] as String;
      accountName = accountResult.first['name'] as String;
    }

    // Get journal reference numbers for each ledger entry
    for (var i = 0; i < ledgerEntries.length; i++) {
      final entry = ledgerEntries[i];
      // Query journal information to get reference number
      final journalResult = await db.query(
        'journals',
        columns: ['reference_number'], // Only need the reference number
        where: 'id = ?', // Filter by journal ID
        whereArgs: [entry.journalId], // Parameter value
      );

      // Extract reference number if available
      String? referenceNumber;
      if (journalResult.isNotEmpty) {
        referenceNumber = journalResult.first['reference_number'] as String;
      }

      // Create new ledger entry with all information combined
      ledgerEntries[i] = Ledger(
        id: entry.id,
        accountId: entry.accountId,
        journalId: entry.journalId,
        entryId: entry.entryId,
        date: entry.date,
        debit: entry.debit,
        credit: entry.credit,
        balance: entry.balance,
        createdAt: entry.createdAt,
        // Enrich with account and journal information
        accountName: accountName,
        accountNumber: accountNumber,
        referenceNumber: referenceNumber,
      );
    }

    return ledgerEntries; // Return the fully populated ledger entries
  }

  /// Generates a trial balance report based on the current account balances
  /// @return Future<List<TrialBalance>> - List of trial balance items
  Future<List<TrialBalance>> getTrialBalance() async {
    final db = await _databaseService.database; // Get database connection

    // Use raw SQL for complex query to get latest balance for each account
    final result = await db.rawQuery('''
      SELECT 
        a.id AS account_id,
        a.account_number,
        a.name AS account_name,
        t.name AS account_type_name,
        t.id AS account_type_id,
        COALESCE(
          (SELECT l.balance 
           FROM ledger l 
           WHERE l.account_id = a.id 
           ORDER BY l.id DESC 
           LIMIT 1), 0
        ) AS balance
      FROM accounts a
      JOIN account_types t ON a.type_id = t.id
      WHERE a.is_active = 1
      ORDER BY a.account_number
    ''');

    // Initialize the trial balance list
    List<TrialBalance> trialBalanceList = [];

    // Process each account row and convert to trial balance entries
    for (final row in result) {
      final accountTypeId = row['account_type_id'] as int;
      final balance = row['balance'] as double;

      // Initialize debit and credit columns to zero
      double debit = 0.0;
      double credit = 0.0;

      // Apply accounting rules based on account type
      // For asset and expense accounts, positive balance is debit
      if (accountTypeId == 1 || accountTypeId == 5) {
        if (balance > 0) {
          debit = balance; // Positive balance goes to debit column
        } else {
          credit =
              -balance; // Negative balance becomes positive in credit column
        }
      }
      // For liability, equity, and revenue accounts, positive balance is credit
      else {
        if (balance > 0) {
          credit = balance; // Positive balance goes to credit column
        } else {
          debit = -balance; // Negative balance becomes positive in debit column
        }
      }

      // Add the account to the trial balance list
      trialBalanceList.add(
        TrialBalance(
          accountNumber: row['account_number'] as String,
          accountName: row['account_name'] as String,
          accountTypeName: row['account_type_name'] as String,
          debit: debit,
          credit: credit,
        ),
      );
    }

    return trialBalanceList; // Return the completed trial balance
  }

  /// Generates a balance sheet report as of a specific date
  /// @param asOfDate - Optional date for the balance sheet (defaults to current date)
  /// @return Future<BalanceSheet> - Complete balance sheet report object
  Future<BalanceSheet> getBalanceSheet({DateTime? asOfDate}) async {
    final db = await _databaseService.database; // Get database connection
    final date =
        asOfDate ??
        DateTime.now(); // Use provided date or default to current date

    // Use raw SQL to get all accounts with their balances as of the specified date
    final result = await db.rawQuery(
      '''
      SELECT 
        a.id AS account_id,
        a.account_number,
        a.name AS account_name,
        t.name AS account_type_name,
        t.id AS account_type_id,
        t.code AS account_type_code,
        COALESCE(
          (SELECT l.balance 
           FROM ledger l 
           WHERE l.account_id = a.id 
           AND l.date <= ?         -- Only include entries up to the specified date
           ORDER BY l.id DESC      -- Get the most recent entry
           LIMIT 1), 0             -- Default to 0 if no entries exist
        ) AS balance
      FROM accounts a
      JOIN account_types t ON a.type_id = t.id
      WHERE a.is_active = 1        -- Only include active accounts
      ORDER BY a.account_number    -- Order by account number for readability
    ''',
      [date.toIso8601String()], // Parameter for the date filter
    );

    // Process assets (account_type_id = 1)
    final assetItems =
        result
            .where((row) => row['account_type_id'] as int == 1)
            .map(
              (row) => FinancialStatementItem(
                accountNumber: row['account_number'] as String,
                accountName: row['account_name'] as String,
                accountTypeName: row['account_type_name'] as String,
                balance: row['balance'] as double,
              ),
            )
            .toList();

    final totalAssets = assetItems.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    // Process liabilities (account_type_id = 2)
    final liabilityItems =
        result
            .where((row) => row['account_type_id'] as int == 2)
            .map(
              (row) => FinancialStatementItem(
                accountNumber: row['account_number'] as String,
                accountName: row['account_name'] as String,
                accountTypeName: row['account_type_name'] as String,
                balance: row['balance'] as double,
              ),
            )
            .toList();

    final totalLiabilities = liabilityItems.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    // Process equity (account_type_id = 3)
    final equityItems =
        result
            .where((row) => row['account_type_id'] as int == 3)
            .map(
              (row) => FinancialStatementItem(
                accountNumber: row['account_number'] as String,
                accountName: row['account_name'] as String,
                accountTypeName: row['account_type_name'] as String,
                balance: row['balance'] as double,
              ),
            )
            .toList();

    final totalEquity = equityItems.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    // Create balance sheet sections
    final assetsSection = BalanceSheetSection(
      title: 'Assets',
      items: assetItems,
      totalAmount: totalAssets,
    );

    final liabilitiesSection = BalanceSheetSection(
      title: 'Liabilities',
      items: liabilityItems,
      totalAmount: totalLiabilities,
    );

    final equitySection = BalanceSheetSection(
      title: 'Equity',
      items: equityItems,
      totalAmount: totalEquity,
    );

    // Create complete balance sheet
    return BalanceSheet(
      asOfDate: date,
      assets: assetsSection,
      liabilities: liabilitiesSection,
      equity: equitySection,
      totalAssets: totalAssets,
      totalLiabilitiesEquity: totalLiabilities + totalEquity,
    );
  }

  /// Generates an income statement report for a specific period
  /// @param startDate - Optional start date (defaults to beginning of current year)
  /// @param endDate - Optional end date (defaults to current date)
  /// @return Future<IncomeStatement> - Complete income statement report object
  Future<IncomeStatement> getIncomeStatement({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database; // Get database connection
    // Set default date range if not provided (current year to date)
    final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
    final end = endDate ?? DateTime.now();

    // Use raw SQL to get revenue and expense accounts with their totals for the period
    final result = await db.rawQuery(
      '''
      SELECT 
        a.id AS account_id,
        a.account_number,
        a.name AS account_name,
        t.name AS account_type_name,
        t.id AS account_type_id,
        t.code AS account_type_code,
        COALESCE(
          SUM(CASE WHEN l.date >= ? AND l.date <= ? THEN
            CASE WHEN t.id = 4 THEN l.credit - l.debit  -- Revenue (credits increase)
            WHEN t.id = 5 THEN l.debit - l.credit      -- Expenses (debits increase)
            ELSE 0 END
          ELSE 0 END), 0
        ) AS period_amount
      FROM accounts a
      JOIN account_types t ON a.type_id = t.id
      LEFT JOIN ledger l ON l.account_id = a.id
      WHERE a.is_active = 1 AND (t.id = 4 OR t.id = 5)  -- Only Revenue or Expense accounts
      GROUP BY a.id                                     -- Aggregate by account
      ORDER BY a.account_number                         -- Order by account number
    ''',
      [
        start.toIso8601String(),
        end.toIso8601String(),
      ], // Parameters for date range
    );

    // Process revenue (account_type_id = 4)
    final revenueItems =
        result
            .where(
              (row) =>
                  row['account_type_id'] as int == 4 &&
                  (row['period_amount'] as double) != 0,
            )
            .map(
              (row) => FinancialStatementItem(
                accountNumber: row['account_number'] as String,
                accountName: row['account_name'] as String,
                accountTypeName: row['account_type_name'] as String,
                balance: row['period_amount'] as double,
              ),
            )
            .toList();

    final totalRevenue = revenueItems.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    // Process expenses (account_type_id = 5)
    final expenseItems =
        result
            .where(
              (row) =>
                  row['account_type_id'] as int == 5 &&
                  (row['period_amount'] as double) != 0,
            )
            .map(
              (row) => FinancialStatementItem(
                accountNumber: row['account_number'] as String,
                accountName: row['account_name'] as String,
                accountTypeName: row['account_type_name'] as String,
                balance: row['period_amount'] as double,
              ),
            )
            .toList();

    final totalExpenses = expenseItems.fold<double>(
      0,
      (sum, item) => sum + item.balance,
    );

    // Create income statement sections
    final revenueSection = IncomeStatementSection(
      title: 'Revenue',
      items: revenueItems,
      totalAmount: totalRevenue,
    );

    final expensesSection = IncomeStatementSection(
      title: 'Expenses',
      items: expenseItems,
      totalAmount: totalExpenses,
    );

    // Create complete income statement
    return IncomeStatement(
      startDate: start,
      endDate: end,
      revenue: revenueSection,
      expenses: expensesSection,
      netIncome: totalRevenue - totalExpenses,
    );
  }
}
