import 'package:equatable/equatable.dart';

class AccountType extends Equatable {
  final int? id;
  final String name;
  final String code;

  const AccountType({this.id, required this.name, required this.code});

  @override
  List<Object?> get props => [id, name, code];

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'code': code};
  }

  factory AccountType.fromMap(Map<String, dynamic> map) {
    return AccountType(id: map['id'], name: map['name'], code: map['code']);
  }

  @override
  String toString() => 'AccountType(id: $id, name: $name, code: $code)';
}

class Account extends Equatable {
  final int? id;
  final String accountNumber;
  final String name;
  final int typeId;
  final int? parentId;
  final int level;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Not stored in database, used for UI
  final List<Account>? children;
  final AccountType? accountType;
  final double? balance;

  const Account({
    this.id,
    required this.accountNumber,
    required this.name,
    required this.typeId,
    this.parentId,
    required this.level,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.children,
    this.accountType,
    this.balance,
  });

  @override
  List<Object?> get props => [
    id,
    accountNumber,
    name,
    typeId,
    parentId,
    level,
    isActive,
    createdAt,
    updatedAt,
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account_number': accountNumber,
      'name': name,
      'type_id': typeId,
      'parent_id': parentId,
      'level': level,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      accountNumber: map['account_number'],
      name: map['name'],
      typeId: map['type_id'],
      parentId: map['parent_id'],
      level: map['level'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Account copyWith({
    int? id,
    String? accountNumber,
    String? name,
    int? typeId,
    int? parentId,
    int? level,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Account>? children,
    AccountType? accountType,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      accountNumber: accountNumber ?? this.accountNumber,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      children: children ?? this.children,
      accountType: accountType ?? this.accountType,
      balance: balance ?? this.balance,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, accountNumber: $accountNumber, name: $name, typeId: $typeId, parentId: $parentId, level: $level, isActive: $isActive)';
  }
}
