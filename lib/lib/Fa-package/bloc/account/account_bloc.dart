import 'package:bloc/bloc.dart';
import '../../data/repositories/account_repository.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  AccountBloc({required AccountRepository accountRepository})
    : _accountRepository = accountRepository,
      super(AccountsInitial()) {
    on<LoadAccounts>(_onLoadAccounts);
    on<LoadAccountTypes>(_onLoadAccountTypes);
    on<LoadAccountTree>(_onLoadAccountTree);
    on<AddAccount>(_onAddAccount);
    on<UpdateAccount>(_onUpdateAccount);
    on<DeleteAccount>(_onDeleteAccount);
    on<RefreshData>(_onRefreshData);
  }

  Future<void> _onLoadAccounts(
    LoadAccounts event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountsLoading());
    try {
      final accounts = await _accountRepository.getAllAccounts();
      emit(AccountsLoaded(accounts));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadAccountTypes(
    LoadAccountTypes event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountsLoading());
    try {
      final types = await _accountRepository.getAllAccountTypes();
      emit(AccountTypesLoaded(types));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onLoadAccountTree(
    LoadAccountTree event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountsLoading());
    try {
      final tree = await _accountRepository.getAccountsTree();
      emit(AccountTreeLoaded(tree));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onAddAccount(
    AddAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.createAccount(event.account);

      if (state is AccountsLoaded) {
        final accounts = await _accountRepository.getAllAccounts();
        emit(AccountsLoaded(accounts));
      } else if (state is AccountTreeLoaded) {
        final tree = await _accountRepository.getAccountsTree();
        emit(AccountTreeLoaded(tree));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onUpdateAccount(
    UpdateAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.updateAccount(event.account);

      if (state is AccountsLoaded) {
        final accounts = await _accountRepository.getAllAccounts();
        emit(AccountsLoaded(accounts));
      } else if (state is AccountTreeLoaded) {
        final tree = await _accountRepository.getAccountsTree();
        emit(AccountTreeLoaded(tree));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AccountState> emit,
  ) async {
    try {
      await _accountRepository.deleteAccount(event.id);

      if (state is AccountsLoaded) {
        final accounts = await _accountRepository.getAllAccounts();
        emit(AccountsLoaded(accounts));
      } else if (state is AccountTreeLoaded) {
        final tree = await _accountRepository.getAccountsTree();
        emit(AccountTreeLoaded(tree));
      }
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }

  Future<void> _onRefreshData(
    RefreshData event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountsLoading());
    try {
      final tree = await _accountRepository.getAccountsTree();
      emit(AccountTreeLoaded(tree));
    } catch (e) {
      emit(AccountError(e.toString()));
    }
  }
}
