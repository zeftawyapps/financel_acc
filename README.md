# Financial Accounting System - Data Model Documentation

This document outlines the core data models used in the Financial Accounting application, which can be used for presentations and documentation.

## Core Data Models

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
