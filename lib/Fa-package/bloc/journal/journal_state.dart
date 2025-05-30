import 'package:equatable/equatable.dart';
import 'package:financel_acc/Fa-package/data/models/journal.dart';

abstract class JournalState extends Equatable {
  const JournalState();

  @override
  List<Object?> get props => [];
}

class JournalsInitial extends JournalState {}

class JournalsLoading extends JournalState {}

class JournalsLoaded extends JournalState {
  final List<Journal> journals;

  const JournalsLoaded(this.journals);

  @override
  List<Object?> get props => [journals];
}

class JournalLoaded extends JournalState {
  final Journal journal;

  const JournalLoaded(this.journal);

  @override
  List<Object?> get props => [journal];
}

class JournalPosted extends JournalState {
  const JournalPosted();
}

class JournalError extends JournalState {
  final String message;

  const JournalError(this.message);

  @override
  List<Object?> get props => [message];
}
