import 'package:equatable/equatable.dart';
import '../../data/models/account.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountsInitial extends AccountState {}

class AccountsLoading extends AccountState {}

class AccountTypesLoaded extends AccountState {
  final List<AccountType> accountTypes;

  const AccountTypesLoaded(this.accountTypes);

  @override
  List<Object?> get props => [accountTypes];
}

class AccountsLoaded extends AccountState {
  final List<Account> accounts;

  const AccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountTreeLoaded extends AccountState {
  final List<Account> accountTree;

  const AccountTreeLoaded(this.accountTree);

  @override
  List<Object?> get props => [accountTree];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
