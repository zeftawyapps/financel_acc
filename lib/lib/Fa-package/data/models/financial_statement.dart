import 'package:equatable/equatable.dart';

/// Base class for financial statement items
class FinancialStatementItem extends Equatable {
  final String accountNumber;
  final String accountName;
  final String accountTypeName;
  final double balance;

  const FinancialStatementItem({
    required this.accountNumber,
    required this.accountName,
    required this.accountTypeName,
    required this.balance,
  });

  @override
  List<Object> get props => [
    accountNumber,
    accountName,
    accountTypeName,
    balance,
  ];
}

/// Model for balance sheet sections (Assets, Liabilities, Equity)
class BalanceSheetSection extends Equatable {
  final String title;
  final List<FinancialStatementItem> items;
  final double totalAmount;

  const BalanceSheetSection({
    required this.title,
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [title, items, totalAmount];
}

/// Model for income statement sections (Revenue, Expenses)
class IncomeStatementSection extends Equatable {
  final String title;
  final List<FinancialStatementItem> items;
  final double totalAmount;

  const IncomeStatementSection({
    required this.title,
    required this.items,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [title, items, totalAmount];
}

/// Complete balance sheet model
class BalanceSheet extends Equatable {
  final DateTime asOfDate;
  final BalanceSheetSection assets;
  final BalanceSheetSection liabilities;
  final BalanceSheetSection equity;
  final double totalAssets;
  final double totalLiabilitiesEquity;

  const BalanceSheet({
    required this.asOfDate,
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.totalAssets,
    required this.totalLiabilitiesEquity,
  });

  @override
  List<Object> get props => [
    asOfDate,
    assets,
    liabilities,
    equity,
    totalAssets,
    totalLiabilitiesEquity,
  ];
}

/// Complete income statement model
class IncomeStatement extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final IncomeStatementSection revenue;
  final IncomeStatementSection expenses;
  final double netIncome;

  const IncomeStatement({
    required this.startDate,
    required this.endDate,
    required this.revenue,
    required this.expenses,
    required this.netIncome,
  });

  @override
  List<Object> get props => [startDate, endDate, revenue, expenses, netIncome];
}
