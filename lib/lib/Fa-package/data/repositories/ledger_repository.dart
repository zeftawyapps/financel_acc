import '../database/database_service.dart';
import '../models/ledger.dart';
import '../models/financial_statement.dart';
import 'package:intl/intl.dart';

class LedgerRepository {
  final DatabaseService _databaseService;

  LedgerRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  Future<List<Ledger>> getLedgerEntriesByAccount(int accountId) async {
    final db = await _databaseService.database;
    final result = await db.query(
      'ledger',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date ASC',
    );

    final ledgerEntries = result.map((e) => Ledger.fromMap(e)).toList();

    // Get account info
    final accountResult = await db.query(
      'accounts',
      columns: ['account_number', 'name'],
      where: 'id = ?',
      whereArgs: [accountId],
    );

    String? accountNumber;
    String? accountName;

    if (accountResult.isNotEmpty) {
      accountNumber = accountResult.first['account_number'] as String;
      accountName = accountResult.first['name'] as String;
    }

    // Get journal reference numbers
    for (var i = 0; i < ledgerEntries.length; i++) {
      final entry = ledgerEntries[i];
      final journalResult = await db.query(
        'journals',
        columns: ['reference_number'],
        where: 'id = ?',
        whereArgs: [entry.journalId],
      );

      String? referenceNumber;
      if (journalResult.isNotEmpty) {
        referenceNumber = journalResult.first['reference_number'] as String;
      }

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
        accountName: accountName,
        accountNumber: accountNumber,
        referenceNumber: referenceNumber,
      );
    }

    return ledgerEntries;
  }

  Future<List<TrialBalance>> getTrialBalance() async {
    final db = await _databaseService.database;

    // Get latest balance for each account
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

    List<TrialBalance> trialBalanceList = [];

    for (final row in result) {
      final accountTypeId = row['account_type_id'] as int;
      final balance = row['balance'] as double;

      double debit = 0.0;
      double credit = 0.0;

      // For asset and expense accounts, positive balance is debit
      if (accountTypeId == 1 || accountTypeId == 5) {
        if (balance > 0) {
          debit = balance;
        } else {
          credit = -balance;
        }
      }
      // For liability, equity, and revenue accounts, positive balance is credit
      else {
        if (balance > 0) {
          credit = balance;
        } else {
          debit = -balance;
        }
      }

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

    return trialBalanceList;
  }

  Future<BalanceSheet> getBalanceSheet({DateTime? asOfDate}) async {
    final db = await _databaseService.database;
    final date = asOfDate ?? DateTime.now();

    // Get all accounts with their balances
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
           AND l.date <= ?
           ORDER BY l.id DESC 
           LIMIT 1), 0
        ) AS balance
      FROM accounts a
      JOIN account_types t ON a.type_id = t.id
      WHERE a.is_active = 1
      ORDER BY a.account_number
    ''',
      [date.toIso8601String()],
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

  Future<IncomeStatement> getIncomeStatement({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseService.database;
    final start = startDate ?? DateTime(DateTime.now().year, 1, 1);
    final end = endDate ?? DateTime.now();

    // Get revenue and expense accounts with their totals for the period
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
      WHERE a.is_active = 1 AND (t.id = 4 OR t.id = 5)  -- Revenue or Expense
      GROUP BY a.id
      ORDER BY a.account_number
    ''',
      [start.toIso8601String(), end.toIso8601String()],
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
