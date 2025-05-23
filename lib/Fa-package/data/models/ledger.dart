import 'package:equatable/equatable.dart';

class Ledger extends Equatable {
  final int? id;
  final int accountId;
  final int journalId;
  final int entryId;
  final DateTime date;
  final double debit;
  final double credit;
  final double balance;
  final DateTime createdAt;

  // Not stored in database, used for UI
  final String? accountName;
  final String? accountNumber;
  final String? referenceNumber;

  const Ledger({
    this.id,
    required this.accountId,
    required this.journalId,
    required this.entryId,
    required this.date,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.createdAt,
    this.accountName,
    this.accountNumber,
    this.referenceNumber,
  });

  @override
  List<Object?> get props => [
    id,
    accountId,
    journalId,
    entryId,
    date,
    debit,
    credit,
    balance,
    createdAt,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_id': accountId,
      'journal_id': journalId,
      'entry_id': entryId,
      'date': date.toIso8601String(),
      'debit': debit,
      'credit': credit,
      'balance': balance,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Ledger.fromMap(Map<String, dynamic> map) {
    return Ledger(
      id: map['id'],
      accountId: map['account_id'],
      journalId: map['journal_id'],
      entryId: map['entry_id'],
      date: DateTime.parse(map['date']),
      debit: map['debit'],
      credit: map['credit'],
      balance: map['balance'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'Ledger(id: $id, accountId: $accountId, journalId: $journalId, entryId: $entryId, date: $date, debit: $debit, credit: $credit, balance: $balance)';
  }
}

class TrialBalance extends Equatable {
  final String accountNumber;
  final String accountName;
  final String accountTypeName;
  final double debit;
  final double credit;

  const TrialBalance({
    required this.accountNumber,
    required this.accountName,
    required this.accountTypeName,
    required this.debit,
    required this.credit,
  });

  @override
  List<Object?> get props => [
    accountNumber,
    accountName,
    accountTypeName,
    debit,
    credit,
  ];

  @override
  String toString() {
    return 'TrialBalance(accountNumber: $accountNumber, accountName: $accountName, accountTypeName: $accountTypeName, debit: $debit, credit: $credit)';
  }
}
