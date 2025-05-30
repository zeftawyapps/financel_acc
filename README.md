# Financial Accounting System

A comprehensive double-entry bookkeeping application built with Flutter for managing financial accounts, recording transactions, and generating financial statements.

## Arabic Documentation

A complete Arabic translation of this documentation is available in [README_AR.md](README_AR.md).

## How to Prompt to Vibe Code

If you are a trainer and want to try to create the app, you can use the prompt in this file [promt_to_vibeCode](promt_to_vibeCode.md)

## Table of Contents

- [Installation Instructions](#installation-instructions)
  - [Windows Installation Options](#windows-installation-options)
  - [Uninstallation](#uninstallation)
- [Development Setup](#development-setup)
- [Building for Production](#building-for-production)
- [System Requirements](#system-requirements)
- [Key Features](#key-features)
- [How to Use](#how-to-use)
- [Data Model Documentation](#data-model-documentation)
- [Database Relationships](#database-relationships)
- [Application Flow](#application-flow)
- [Project Structure](#project-structure)
- [Accounting Structure](#accounting-structure)

## Installation Instructions

### Windows Installation Options

#### MSIX Package Installation (Recommended)

1. Run the `open_msix_package.bat` file to locate the MSIX installer
2. Or navigate directly to the MSIX package file (`FinancialAccounting.msix`) in the `setup_app\WindowsStore` folder
3. Double-click the MSIX file to install using Windows App Installer
4. If prompted, click "Install" to confirm
5. After installation, the app will appear in your Start menu as "Financial Accounting System"

> **Note:** If you don't see the MSIX file, you may need to build it first by running:
>
> ```powershell
> flutter pub run msix:create --output-path=setup_app\WindowsStore
> ```
>
> For detailed instructions on accessing the MSIX file, see [MSIX_ACCESS_GUIDE.md](MSIX_ACCESS_GUIDE.md)

### Uninstallation

1. Open Windows Settings
2. Go to Apps > Installed apps
3. Find "Financial Accounting System" in the list
4. Click the three dots and select "Uninstall"

## Development Setup:

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
# Build Flutter app for Windows
flutter build windows --release

# The built application will be available at:
# build/windows/x64/runner/Release/

# Create Windows installer
./build_installer.ps1

# Create ZIP package for alternative distribution
./create_release.ps1
```

## System Requirements

- **Operating System:** Windows 10 version 10.0.17763.0 or higher
- **Processor:** 1.5 GHz or faster processor
- **Memory:** 4 GB RAM minimum
- **Storage:** 100 MB available storage space
- **Display:** 1280 x 720 or higher resolution
- **Additional Requirements:**
  - Microsoft Visual C++ Redistributable 2015-2019 (included in installer)
  - Windows App Installer for MSIX installation

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

### Entity Relationship Diagram

```
┌───────────────────┐       ┌─────────────────────┐      ┌───────────────────┐
│    AccountType    │       │      Account        │      │    JournalEntry   │
├───────────────────┤       ├─────────────────────┤      ├───────────────────┤
│ id (PK)           │       │ id (PK)             │      │ id (PK)           │
│ name              │◄──────┤ typeId (FK)         │◄─────┤ accountId (FK)    │
│ code              │       │ accountNumber        │      │ journalId (FK)────┼──────┐
└───────────────────┘       │ name                │      │ description       │      │
                            │ parentId (FK)────────┐     │ debit             │      │
                            │ level               │|     │ credit            │      │
                            │ isActive            │|     └───────────────────┘      │
                            └───────────────────┬─┘|                                │
                                                |  |                                │
                                                └──┘                                │
                                                                                   │
                            ┌────────────────────┐     ┌────────────────────┐       │
                            │       Ledger       │     │      Journal       │       │
                            ├────────────────────┤     ├────────────────────┤       │
                            │ id (PK)            │     │ id (PK)            │◄──────┘
                            │ accountId (FK)─────┼─────┤ referenceNumber    │
                            │ journalId (FK)─────┼─────┤ date               │
                            │ entryId (FK)───────┼─────┤ description        │
                            │ date               │     │ isPosted           │
                            │ debit              │     └────────────────────┘
                            │ credit             │
                            │ balance            │
                            └────────────────────┘
```

### Financial Statements Data Flow

```
                   ┌───────────────────────────────────────────┐
                   │               Ledger Records              │
                   └─────────────────┬─────────────────────────┘
                                     │
                         ┌───────────▼────────────┐
                         │     Trial Balance      │
                         └───────────┬────────────┘
                                     │
                   ┌─────────────────┴─────────────────┐
                   ▼                                   ▼
        ┌────────────────────┐             ┌────────────────────┐
        │    Balance Sheet   │             │  Income Statement  │
        ├────────────────────┤             ├────────────────────┤
        │ - Assets           │             │ - Revenues         │
        │ - Liabilities      │             │ - Expenses         │
        │ - Owner's Equity   │             │ - Net Income       │
        └────────────────────┘             └────────────────────┘
```

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

## Project Structure

The Financial Accounting System follows a well-organized project structure for maintainability and scalability:

### Directory Structure

```
financel_acc/
├── lib/                      # Main application code
│   ├── main.dart            # Application entry point
│   ├── Fa-package/          # Financial accounting package
│   │   ├── bloc/            # Business Logic Components
│   │   │   ├── account/     # Account-related business logic
│   │   │   ├── journal/     # Journal-related business logic
│   │   │   └── ledger/      # Ledger-related business logic
│   │   └── data/            # Data layer
│   │       ├── database/    # Database services
│   │       ├── models/      # Data models
│   │       └── repositories/# Repositories for data access
│   ├── ui/                  # User interface components
│   │   ├── screens/         # Application screens
│   │   │   ├── accounts/    # Account management screens
│   │   │   ├── financial/   # Financial statements screens
│   │   │   ├── journal/     # Journal entry screens
│   │   │   └── ledger/      # General ledger screens
│   │   ├── theme/           # Theme configuration
│   │   └── widgets/         # Reusable UI widgets
│   └── utils/               # Utility functions and helpers
├── windows/                # Windows platform-specific code
├── setup_app/             # Installation packages
│   ├── Installer/         # Windows installer files
│   ├── Portable/          # Portable application package
│   ├── SharedAssets/      # Shared documentation and assets
│   └── WindowsStore/      # Windows Store (MSIX) package
└── test/                  # Application tests
```

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                        Presentation Layer                    │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │ Home Screen  │  │ UI Widgets  │  │ Theme Configuration  │ │
│  └──────────────┘  └─────────────┘  └──────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                        Business Logic Layer                  │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │ Account Bloc │  │ Journal Bloc│  │ Ledger Bloc          │ │
│  └──────────────┘  └─────────────┘  └──────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│                        Data Layer                            │
│  ┌──────────────┐  ┌─────────────┐  ┌──────────────────────┐ │
│  │ Repositories │  │ Data Models │  │ Database Service     │ │
│  └──────────────┘  └─────────────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

This architecture follows the BLoC pattern (Business Logic Component), which separates the application into three main layers:

1. **Presentation Layer**: UI components that display data and capture user input
2. **Business Logic Layer**: BLoCs that handle state management and business rules
3. **Data Layer**: Repositories and models that handle data access and storage

## Accounting Structure

This application implements a comprehensive accounting system with the following structure:

- **Chart of Accounts**: Hierarchical organization of accounts including:

  - Assets
  - Liabilities
  - Owner's Equity
  - Expenses
  - Revenues

- **Journal Entries**: The application uses the American journal format for recording transactions.

- **Ledger Accounts**: All journal entries are posted to the appropriate ledger accounts to maintain running balances.

- **Trial Balance**: End balances are posted to the trial balance for verification.

- **Financial Statements**: The system automatically generates:
  - Balance Sheet (showing financial position)
  - Income Statement (showing financial performance)

The application is built using Flutter with SQLite database support (via sqflite_common_ffi package) for Windows and implements the BLoC pattern for state management.
