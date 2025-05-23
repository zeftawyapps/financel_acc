# Financial Accounting System Prompt

## Core Accounting Structure

I want to create a hierarchical account structure for:

- Assets
- Liabilities
- Owner's Equity
- Expenses
- Revenues

This accounting system will implement the American journal format.
Transactions will be:

1. Recorded in journal entries
2. Posted to ledger accounts
3. End balances transferred to trial balance
4. Used to create financial statements (balance sheet and income statement)

## Technical Requirements

The application will:

- Work with SQLite (using sqflite_common_ffi package) in Windows
- Use BLoC pattern for state management
- Implement double-entry bookkeeping (debits = credits)
- Support hierarchical account organization
- Generate comprehensive financial reports

## Development Process

1. Design the database schema for accounts, journals, and ledgers
2. Create the data models and repositories
3. Implement BLoC pattern for business logic
4. Build the UI components for account management, journal entries, and reporting
5. Test the system with sample accounting workflowsto create the tree account for the asset lability owners Equity expense and revenues
   this account will create in American journal
   the sum of accounts posted to ledger account
   the end palaces post to trial balance
   create the financial statement balance sheet and income statement
   the app work with sqflite_common_ffi: in windows app  
   we use the bloc as state management
