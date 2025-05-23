import 'package:equatable/equatable.dart';

class Journal extends Equatable {
  final int? id;
  final String referenceNumber;
  final DateTime date;
  final String? description;
  final bool isPosted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<JournalEntry>? entries;

  const Journal({
    this.id,
    required this.referenceNumber,
    required this.date,
    this.description,
    this.isPosted = false,
    required this.createdAt,
    required this.updatedAt,
    this.entries,
  });

  @override
  List<Object?> get props => [
    id,
    referenceNumber,
    date,
    description,
    isPosted,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reference_number': referenceNumber,
      'date': date.toIso8601String(),
      'description': description,
      'is_posted': isPosted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'],
      referenceNumber: map['reference_number'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      isPosted: map['is_posted'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Journal copyWith({
    int? id,
    String? referenceNumber,
    DateTime? date,
    String? description,
    bool? isPosted,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<JournalEntry>? entries,
  }) {
    return Journal(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      date: date ?? this.date,
      description: description ?? this.description,
      isPosted: isPosted ?? this.isPosted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entries: entries ?? this.entries,
    );
  }

  @override
  String toString() {
    return 'Journal(id: $id, referenceNumber: $referenceNumber, date: $date, isPosted: $isPosted)';
  }
}

class JournalEntry extends Equatable {
  final int? id;
  final int journalId;
  final int accountId;
  final String? description;
  final double debit;
  final double credit;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Not stored in database, used for UI
  final String? accountName;
  final String? accountNumber;

  const JournalEntry({
    this.id,
    required this.journalId,
    required this.accountId,
    this.description,
    required this.debit,
    required this.credit,
    required this.createdAt,
    required this.updatedAt,
    this.accountName,
    this.accountNumber,
  });

  @override
  List<Object?> get props => [
    id,
    journalId,
    accountId,
    description,
    debit,
    credit,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'journal_id': journalId,
      'account_id': accountId,
      'description': description,
      'debit': debit,
      'credit': credit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      journalId: map['journal_id'],
      accountId: map['account_id'],
      description: map['description'],
      debit: map['debit'],
      credit: map['credit'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  JournalEntry copyWith({
    int? id,
    int? journalId,
    int? accountId,
    String? description,
    double? debit,
    double? credit,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accountName,
    String? accountNumber,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }

  @override
  String toString() {
    return 'JournalEntry(id: $id, journalId: $journalId, accountId: $accountId, debit: $debit, credit: $credit)';
  }
}
