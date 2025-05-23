import 'package:equatable/equatable.dart';
import 'package:financel_acc/Fa-package/data/models/journal.dart';

abstract class JournalEvent extends Equatable {
  const JournalEvent();

  @override
  List<Object?> get props => [];
}

class LoadJournals extends JournalEvent {
  const LoadJournals();
}

class LoadJournal extends JournalEvent {
  final int id;

  const LoadJournal(this.id);

  @override
  List<Object?> get props => [id];
}

class AddJournal extends JournalEvent {
  final Journal journal;
  final List<JournalEntry> entries;

  const AddJournal(this.journal, this.entries);

  @override
  List<Object?> get props => [journal, entries];
}

class UpdateJournal extends JournalEvent {
  final Journal journal;
  final List<JournalEntry> entries;

  const UpdateJournal(this.journal, this.entries);

  @override
  List<Object?> get props => [journal, entries];
}

class DeleteJournal extends JournalEvent {
  final int id;

  const DeleteJournal(this.id);

  @override
  List<Object?> get props => [id];
}

class PostJournalToLedger extends JournalEvent {
  final int id;

  const PostJournalToLedger(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshData extends JournalEvent {
  const RefreshData();
}
