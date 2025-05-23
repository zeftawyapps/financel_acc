import 'package:bloc/bloc.dart';
import '../../data/repositories/journal_repository.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalRepository _journalRepository;

  JournalBloc({required JournalRepository journalRepository})
    : _journalRepository = journalRepository,
      super(JournalsInitial()) {
    on<LoadJournals>(_onLoadJournals);
    on<LoadJournal>(_onLoadJournal);
    on<AddJournal>(_onAddJournal);
    on<UpdateJournal>(_onUpdateJournal);
    on<DeleteJournal>(_onDeleteJournal);
    on<PostJournalToLedger>(_onPostJournalToLedger);
    on<RefreshData>(_onRefreshData);
  }

  Future<void> _onLoadJournals(
    LoadJournals event,
    Emitter<JournalState> emit,
  ) async {
    emit(JournalsLoading());
    try {
      final journals = await _journalRepository.getAllJournals();
      emit(JournalsLoaded(journals));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onLoadJournal(
    LoadJournal event,
    Emitter<JournalState> emit,
  ) async {
    emit(JournalsLoading());
    try {
      final journal = await _journalRepository.getJournalById(event.id);
      if (journal != null) {
        emit(JournalLoaded(journal));
      } else {
        emit(const JournalError('Journal not found'));
      }
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onAddJournal(
    AddJournal event,
    Emitter<JournalState> emit,
  ) async {
    try {
      // Create journal
      final journalId = await _journalRepository.createJournal(event.journal);

      // Create journal entries
      for (final entry in event.entries) {
        await _journalRepository.createJournalEntry(
          entry.copyWith(journalId: journalId),
        );
      }

      // Reload journals
      final journals = await _journalRepository.getAllJournals();
      emit(JournalsLoaded(journals));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onUpdateJournal(
    UpdateJournal event,
    Emitter<JournalState> emit,
  ) async {
    try {
      if (event.journal.id == null) {
        emit(const JournalError('Journal ID is required for update'));
        return;
      }

      // Update journal
      await _journalRepository.updateJournal(event.journal);

      // Get existing entries
      final existingEntries = await _journalRepository.getEntriesByJournalId(
        event.journal.id!,
      );

      // Delete all existing entries
      for (final entry in existingEntries) {
        if (entry.id != null) {
          await _journalRepository.deleteJournalEntry(entry.id!);
        }
      }

      // Create new entries
      for (final entry in event.entries) {
        await _journalRepository.createJournalEntry(
          entry.copyWith(journalId: event.journal.id!),
        );
      }

      // Reload journal
      final updatedJournal = await _journalRepository.getJournalById(
        event.journal.id!,
      );

      if (updatedJournal != null) {
        emit(JournalLoaded(updatedJournal));
      } else {
        emit(const JournalError('Journal not found after update'));
      }
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onDeleteJournal(
    DeleteJournal event,
    Emitter<JournalState> emit,
  ) async {
    try {
      await _journalRepository.deleteJournal(event.id);

      // Reload journals
      final journals = await _journalRepository.getAllJournals();
      emit(JournalsLoaded(journals));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onPostJournalToLedger(
    PostJournalToLedger event,
    Emitter<JournalState> emit,
  ) async {
    try {
      final success = await _journalRepository.postJournalToLedger(event.id);

      if (success) {
        emit(const JournalPosted());

        // Reload journal to show updated status
        final journal = await _journalRepository.getJournalById(event.id);
        if (journal != null) {
          emit(JournalLoaded(journal));
        }
      } else {
        emit(const JournalError('Failed to post journal to ledger'));
      }
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  Future<void> _onRefreshData(
    RefreshData event,
    Emitter<JournalState> emit,
  ) async {
    emit(JournalsLoading());
    try {
      final journals = await _journalRepository.getAllJournals();
      emit(JournalsLoaded(journals));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }
}
