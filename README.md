# Financial Accounting System

A comprehensive double-entry bookkeeping application built with Flutter for managing financial accounts, recording transactions, and generating financial statements.

## Installation and Setup

### Windows Installation:

#### Option 1: Installer
1. Download the latest release from the GitHub Releases page
2. Run the `install_windows.bat` file with administrator privileges
3. A desktop shortcut will be created automatically

#### Option 2: Manual Installation
1. Download the latest release from the GitHub Releases page
2. Extract the ZIP file to your preferred location
3. Run `financel_acc.exe` to start the application

### Development Setup:

1. Make sure you have Flutter installed (https://flutter.dev/docs/get-started/install)
2. Ensure you have Windows development dependencies installed:
   ```
   flutter config --enable-windows-desktop
   ```
3. Clone this repository: `git clone https://github.com/zeftawyapps/financel_acc.git`
4. Navigate to the project folder: `cd financel_acc`
5. Get dependencies: `flutter pub get`
6. Run the app: `flutter run -d windows`

### Building for Production:

```powershell
# Build for Windows
flutter build windows --release

# The built application will be available at:
# build/windows/x64/runner/Release/
```

## Key Features

- **Chart of Accounts:** Create and manage account hierarchies for assets, liabilities, equity, income, and expenses
- **Journal Entries:** Record debit and credit transactions with automatic balancing
- **General Ledger:** View detailed account history with running balances
- **Financial Statements:** Generate balance sheets and income statements
- **Modern UI:** Clean, responsive interface with a professional design

## How to Use

### Setting Up Accounts:
1. Navigate to the "Chart of Accounts" screen from the main menu
2. Click "Add Account" to create new accounts
3. Specify account details: number, name, type, and parent account (if applicable)
4. Organize accounts in a hierarchical structure for better financial categorization

### Recording Transactions:
1. Go to "Journal Entries" from the main menu
2. Click "New Journal Entry"
3. Enter the transaction date, reference number, and description
4. Add debit and credit entries ensuring they balance (equal amounts on both sides)
5. Save the journal entry to record the transaction

### Viewing the General Ledger:
1. Access "General Ledger" from the main menu
2. Select an account from the dropdown
3. View all transactions affecting the selected account with running balances

### Generating Financial Statements:
1. Navigate to "Financial Statements" from the main menu
2. Use the date picker to select the reporting date
3. Switch between Balance Sheet and Income Statement views
4. Review financial position or performance information

## Data Model Documentation

### 1. Account Model

The accounting system is built around a flexible Chart of Accounts structure:

| Property      | Type           | Description                                        |
| ------------- | -------------- | -------------------------------------------------- |
| id            | int            | Unique identifier for the account                  |
| accountNumber | String         | Standardized account number/code                   |
| name          | String         | Account name (e.g., "Cash", "Accounts Receivable") |
| typeId        | int            | Reference to AccountType                           |
| parentId      | int (nullable) | Parent account ID for hierarchical relationships   |
| level         | int            | Depth in the account hierarchy                     |
| isActive      | bool           | Whether the account is active                      |
| children      | List<Account>  | Child accounts (used for UI)                       |
| accountType   | AccountType    | Account type information (used for UI)             |
| balance       | double         | Current balance of the account (used for UI)       |

#### Account Types

| Property | Type   | Description                                       |
| -------- | ------ | ------------------------------------------------- |
| id       | int    | Unique identifier for the account type            |
| name     | String | Type name (e.g., "Asset", "Liability", "Revenue") |
| code     | String | Type code used for reference and classification   |

### 2. Journal Model

Journal entries record financial transactions before they are posted to the general ledger:

| Property        | Type               | Description                                             |
| --------------- | ------------------ | ------------------------------------------------------- |
| id              | int                | Unique identifier for the journal                       |
| referenceNumber | String             | Unique reference number for the journal entry           |
| date            | DateTime           | Date of the journal entry                               |
| description     | String             | Description of the transaction                          |
| isPosted        | bool               | Whether the journal entry has been posted to the ledger |
| entries         | List<JournalEntry> | Individual line items (debits and credits)              |

#### Journal Entry

| Property      | Type   | Description                             |
| ------------- | ------ | --------------------------------------- |
| id            | int    | Unique identifier for the journal entry |
| journalId     | int    | Reference to parent journal             |
| accountId     | int    | Reference to the account                |
| description   | String | Optional description for this line item |
| debit         | double | Debit amount (if applicable)            |
| credit        | double | Credit amount (if applicable)           |
| accountName   | String | Account name (used for UI)              |
| accountNumber | String | Account number (used for UI)            |

### 3. Ledger Model

The ledger records all posted transactions with running balances for each account:

| Property        | Type     | Description                            |
| --------------- | -------- | -------------------------------------- |
| id              | int      | Unique identifier for the ledger entry |
| accountId       | int      | Reference to the account               |
| journalId       | int      | Reference to the source journal        |
| entryId         | int      | Reference to the source journal entry  |
| date            | DateTime | Date of the transaction                |
| debit           | double   | Debit amount (if applicable)           |
| credit          | double   | Credit amount (if applicable)          |
| balance         | double   | Running balance after this entry       |
| accountName     | String   | Account name (used for UI)             |
| accountNumber   | String   | Account number (used for UI)           |
| referenceNumber | String   | Journal reference number (used for UI) |

### 4. Financial Statements Models

#### Balance Sheet

| Property               | Type                | Description                                |
| ---------------------- | ------------------- | ------------------------------------------ |
| asOfDate               | DateTime            | Date of the balance sheet                  |
| assets                 | BalanceSheetSection | Assets section with items and total        |
| liabilities            | BalanceSheetSection | Liabilities section with items and total   |
| equity                 | BalanceSheetSection | Equity section with items and total        |
| totalAssets            | double              | Sum of all asset accounts                  |
| totalLiabilitiesEquity | double              | Sum of all liabilities and equity accounts |

#### Income Statement

| Property  | Type                   | Description                           |
| --------- | ---------------------- | ------------------------------------- |
| startDate | DateTime               | Start date of the reporting period    |
| endDate   | DateTime               | End date of the reporting period      |
| revenue   | IncomeStatementSection | Revenue section with items and total  |
| expenses  | IncomeStatementSection | Expenses section with items and total |
| netIncome | double                 | Profit/loss (revenue - expenses)      |

## Database Relationships

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│ AccountType │◄────────┤   Account    │◄────────┤JournalEntry │
└─────────────┘         └──────────────┘         └──────┬──────┘
                             ▲                          │
                             │                          │
                        ┌────┴─────┐              ┌─────▼─────┐
                        │  Ledger   │◄─────────────┤  Journal  │
                        └──────────┘              └───────────┘
```

## Application Flow

1. **Chart of Accounts**: Accounts are created and organized by type and hierarchy
2. **Journal Entries**: Transactions are recorded as journals with balanced debits and credits
3. **Posting**: Journal entries are posted to the general ledger, updating account balances
4. **Financial Statements**: Balance sheets and income statements are generated from ledger data

This financial accounting system implements double-entry bookkeeping principles, ensuring that for every transaction, debits always equal credits.
