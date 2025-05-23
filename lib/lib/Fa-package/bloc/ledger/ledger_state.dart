import 'package:equatable/equatable.dart';
import 'package:financel_acc/lib/Fa-package/data/models/ledger.dart';
import '../../data/models/financial_statement.dart';

abstract class LedgerState extends Equatable {
  const LedgerState();

  @override
  List<Object?> get props => [];
}

class LedgerInitial extends LedgerState {}

class LedgerLoading extends LedgerState {}

class LedgerLoaded extends LedgerState {
  final List<Ledger> ledgerEntries;
  final int accountId;

  const LedgerLoaded(this.ledgerEntries, this.accountId);

  @override
  List<Object?> get props => [ledgerEntries, accountId];
}

class TrialBalanceLoaded extends LedgerState {
  final List<TrialBalance> trialBalance;
  final double totalDebits;
  final double totalCredits;

  const TrialBalanceLoaded(
    this.trialBalance,
    this.totalDebits,
    this.totalCredits,
  );

  @override
  List<Object?> get props => [trialBalance, totalDebits, totalCredits];
}

class BalanceSheetLoaded extends LedgerState {
  final BalanceSheet balanceSheet;

  const BalanceSheetLoaded(this.balanceSheet);

  @override
  List<Object?> get props => [balanceSheet];
}

class IncomeStatementLoaded extends LedgerState {
  final IncomeStatement incomeStatement;

  const IncomeStatementLoaded(this.incomeStatement);

  @override
  List<Object?> get props => [incomeStatement];
}

class LedgerError extends LedgerState {
  final String message;

  const LedgerError(this.message);

  @override
  List<Object?> get props => [message];
}
