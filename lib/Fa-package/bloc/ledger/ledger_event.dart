import 'package:equatable/equatable.dart';

abstract class LedgerEvent extends Equatable {
  const LedgerEvent();

  @override
  List<Object?> get props => [];
}

class LoadLedgerForAccount extends LedgerEvent {
  final int accountId;

  const LoadLedgerForAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

class LoadTrialBalance extends LedgerEvent {
  const LoadTrialBalance();
}

class RefreshData extends LedgerEvent {
  const RefreshData();
}

class LoadBalanceSheet extends LedgerEvent {
  final DateTime? asOfDate;

  const LoadBalanceSheet({this.asOfDate});

  @override
  List<Object?> get props => [asOfDate];
}

class LoadIncomeStatement extends LedgerEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadIncomeStatement({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}
