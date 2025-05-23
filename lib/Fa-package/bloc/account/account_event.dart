import 'package:equatable/equatable.dart';
import '../../data/models/account.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccounts extends AccountEvent {
  const LoadAccounts();
}

class LoadAccountTypes extends AccountEvent {
  const LoadAccountTypes();
}

class LoadAccountTree extends AccountEvent {
  const LoadAccountTree();
}

class AddAccount extends AccountEvent {
  final Account account;

  const AddAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class UpdateAccount extends AccountEvent {
  final Account account;

  const UpdateAccount(this.account);

  @override
  List<Object?> get props => [account];
}

class DeleteAccount extends AccountEvent {
  final int id;

  const DeleteAccount(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshData extends AccountEvent {
  const RefreshData();
}
