# Ledger Repository Documentation

This document provides a detailed explanation of the `ledger_repository.dart` file which is a core component of the Financial Accounting application. The repository handles all ledger operations and financial report generation.

## Overview

The `LedgerRepository` class serves as a data access layer for the application, providing methods to interact with the database for ledger-related operations and generating financial reports such as the trial balance, balance sheet, and income statement.

## Class Structure

### Imports

```dart
import '../database/database_service.dart';
import '../models/ledger.dart';
import '../models/financial_statement.dart';
import 'package:intl/intl.dart';
```

- `database_service.dart`: Provides database connection and general database operations
- `ledger.dart`: Contains the Ledger model class
- `financial_statement.dart`: Contains models for financial reports (TrialBalance, BalanceSheet, etc.)
- `intl`: Dart package for date formatting and internationalization

### Constructor

```dart
final DatabaseService _databaseService;

LedgerRepository({required DatabaseService databaseService})
  : _databaseService = databaseService;
```

- Uses dependency injection to receive a `DatabaseService` instance
- Stores the service in a private field `_databaseService` for database access throughout the class
- The initializer list syntax (`:`) assigns the parameter to the field during object construction

## Methods

### getLedgerEntriesByAccount(int accountId)

```dart
Future<List<Ledger>> getLedgerEntriesByAccount(int accountId) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Retrieves all ledger entries for a specific account
- **Parameters**: `int accountId` - The ID of the account to get entries for
- **Return Type**: `Future<List<Ledger>>` - List of ledger entries in chronological order
- **Implementation**:
  1. Queries the ledger table filtered by account ID and ordered by date
  2. Gets account information (name and number) from the accounts table
  3. For each ledger entry, gets the journal reference number
  4. Creates enriched ledger objects with all the information

### getTrialBalance()

```dart
Future<List<TrialBalance>> getTrialBalance() async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Generates a trial balance report based on current account balances
- **Return Type**: `Future<List<TrialBalance>>` - List of trial balance entries
- **Implementation**:
  1. Uses a complex SQL query to get the latest balance for each active account
  2. Processes each account based on accounting rules:
     - For assets and expenses: positive balance is debit, negative is credit
     - For liabilities, equity, and revenue: positive balance is credit, negative is debit
  3. Creates TrialBalance objects with the appropriate debit and credit values

### getBalanceSheet({DateTime? asOfDate})

```dart
Future<BalanceSheet> getBalanceSheet({DateTime? asOfDate}) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Generates a balance sheet as of a specific date
- **Parameters**: `DateTime? asOfDate` - Optional date parameter (defaults to current date)
- **Return Type**: `Future<BalanceSheet>` - Complete balance sheet object
- **Implementation**:
  1. Uses SQL to get account balances as of the specified date
  2. Separates accounts by type:
     - Assets (account_type_id = 1)
     - Liabilities (account_type_id = 2)
     - Equity (account_type_id = 3)
  3. Calculates totals for each section
  4. Creates BalanceSheetSection objects for assets, liabilities, and equity
  5. Assembles and returns a complete BalanceSheet object with all sections and totals

### getIncomeStatement({DateTime? startDate, DateTime? endDate})

```dart
Future<IncomeStatement> getIncomeStatement({
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Implementation details omitted for brevity
}
```

- **Purpose**: Generates an income statement for a specific period
- **Parameters**:
  - `DateTime? startDate` - Optional start date (defaults to beginning of current year)
  - `DateTime? endDate` - Optional end date (defaults to current date)
- **Return Type**: `Future<IncomeStatement>` - Complete income statement object
- **Implementation**:
  1. Uses SQL to calculate account activity for the specified period
  2. Separates accounts by type:
     - Revenue (account_type_id = 4)
     - Expenses (account_type_id = 5)
  3. Only includes accounts with non-zero activity in the period
  4. Calculates totals for revenue and expenses
  5. Creates IncomeStatementSection objects for revenue and expenses
  6. Calculates net income (revenue - expenses)
  7. Assembles and returns a complete IncomeStatement object

## Database Schema Insights

From this repository implementation, we can infer the following about the database schema:

1. **ledger table**:

   - Has id as primary key
   - Contains account_id, journal_id, and entry_id as foreign keys
   - Stores date, debit, credit, and balance information
   - Contains created_at timestamp
   - Maintains a running balance for each account

2. **accounts table**:

   - Has id as primary key
   - Contains account_number and name fields
   - Has type_id field linking to account_types
   - Contains is_active flag to filter out inactive accounts

3. **account_types table**:

   - Has id as primary key
   - Types are:
     - 1: Assets
     - 2: Liabilities
     - 3: Equity
     - 4: Revenue
     - 5: Expenses
   - Contains name and code fields

4. **journals table**:
   - Has id as primary key
   - Contains reference_number field for journal identification

## Financial Reporting Features

1. **Trial Balance**:

   - Lists all accounts with their debit and credit balances
   - Follows accounting rules for different account types
   - Shows account numbers and names for clarity

2. **Balance Sheet**:

   - Shows financial position as of a specific date
   - Organizes accounts into Assets, Liabilities, and Equity sections
   - Calculates section totals and overall totals
   - Validates that Assets = Liabilities + Equity

3. **Income Statement**:
   - Shows financial performance for a specific period
   - Organizes accounts into Revenue and Expenses sections
   - Calculates section totals and net income
   - Filters out accounts with no activity in the period

## Accounting Principles Implemented

1. **Double-Entry Accounting**:

   - Each transaction affects at least two accounts
   - The total of all debits equals the total of all credits

2. **Account Type Rules**:

   - Assets and Expenses: Debit increases, Credit decreases
   - Liabilities, Equity, and Revenue: Credit increases, Debit decreases

3. **Financial Statement Structure**:
   - Balance Sheet: Assets = Liabilities + Equity
   - Income Statement: Revenue - Expenses = Net Income

## SQL Technique Highlights

1. **Complex Subqueries**:

   - Uses subqueries to get latest balance for accounts
   - Applies COALESCE to handle null values

2. **Efficient Date Filtering**:

   - Uses date parameters in queries for point-in-time reporting
   - Allows flexible date ranges for income statement

3. **Aggregation**:
   - Uses SUM for calculating period totals in income statement

## Performance Considerations

1. **Optimized Queries**:

   - Uses column selection to minimize data transfer
   - Uses LIMIT 1 when only one record is needed

2. **Data Processing**:
   - Performs necessary calculations in SQL where possible
   - Processes data in memory for complex business logic
