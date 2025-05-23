import 'package:bloc/bloc.dart';
import '../../data/repositories/ledger_repository.dart';
import 'ledger_event.dart';
import 'ledger_state.dart';

class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  final LedgerRepository _ledgerRepository;

  LedgerBloc({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository,
      super(LedgerInitial()) {
    on<LoadLedgerForAccount>(_onLoadLedgerForAccount);
    on<LoadTrialBalance>(_onLoadTrialBalance);
    on<LoadBalanceSheet>(_onLoadBalanceSheet);
    on<LoadIncomeStatement>(_onLoadIncomeStatement);
    on<RefreshData>(_onRefreshData);
  }

  Future<void> _onLoadLedgerForAccount(
    LoadLedgerForAccount event,
    Emitter<LedgerState> emit,
  ) async {
    emit(LedgerLoading());
    try {
      final ledgerEntries = await _ledgerRepository.getLedgerEntriesByAccount(
        event.accountId,
      );
      emit(LedgerLoaded(ledgerEntries, event.accountId));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }

  Future<void> _onLoadTrialBalance(
    LoadTrialBalance event,
    Emitter<LedgerState> emit,
  ) async {
    emit(LedgerLoading());
    try {
      final trialBalance = await _ledgerRepository.getTrialBalance();

      // Calculate totals
      double totalDebits = 0.0;
      double totalCredits = 0.0;

      for (final entry in trialBalance) {
        totalDebits += entry.debit;
        totalCredits += entry.credit;
      }

      emit(TrialBalanceLoaded(trialBalance, totalDebits, totalCredits));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }

  Future<void> _onLoadBalanceSheet(
    LoadBalanceSheet event,
    Emitter<LedgerState> emit,
  ) async {
    print('📊 Loading balance sheet for date: ${event.asOfDate}');
    emit(LedgerLoading());
    try {
      final balanceSheet = await _ledgerRepository.getBalanceSheet(
        asOfDate: event.asOfDate,
      );
      print(
        '📊 Balance sheet loaded: ${balanceSheet.totalAssets} assets, ${balanceSheet.totalLiabilitiesEquity} liab+equity',
      );
      emit(BalanceSheetLoaded(balanceSheet));
    } catch (e) {
      print('❌ Error loading balance sheet: $e');
      emit(LedgerError(e.toString()));
    }
  }

  Future<void> _onLoadIncomeStatement(
    LoadIncomeStatement event,
    Emitter<LedgerState> emit,
  ) async {
    emit(LedgerLoading());
    try {
      final incomeStatement = await _ledgerRepository.getIncomeStatement(
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(IncomeStatementLoaded(incomeStatement));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }

  Future<void> _onRefreshData(
    RefreshData event,
    Emitter<LedgerState> emit,
  ) async {
    emit(LedgerLoading());
    try {
      final trialBalance = await _ledgerRepository.getTrialBalance();

      // Calculate totals
      double totalDebits = 0.0;
      double totalCredits = 0.0;

      for (final entry in trialBalance) {
        totalDebits += entry.debit;
        totalCredits += entry.credit;
      }

      emit(TrialBalanceLoaded(trialBalance, totalDebits, totalCredits));
    } catch (e) {
      emit(LedgerError(e.toString()));
    }
  }
}
