import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_state.dart';
import 'package:financel_acc/lib/Fa-package/data/models/journal.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_event.dart';
import 'package:financel_acc/lib/ui/theme/app_theme.dart';
import 'package:financel_acc/lib/ui/widgets/common_widgets.dart' as app_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'journal_form.dart';

class JournalEntriesScreen extends StatefulWidget {
  const JournalEntriesScreen({super.key});

  @override
  State<JournalEntriesScreen> createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends State<JournalEntriesScreen> {
  @override
  void initState() {
    super.initState();
    // Load journal entries when screen is displayed
    context.read<JournalBloc>().add(const LoadJournals());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            app_widgets.PageHeader(
              title: 'Journal Entries',
              actions: [
                app_widgets.ActionButton(
                  onPressed: () => _showAddJournalDialog(context),
                  icon: Icons.add,
                  label: 'New Journal Entry',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<JournalBloc, JournalState>(
                builder: (context, state) {
                  if (state is JournalsLoading) {
                    return const app_widgets.LoadingWidget(
                      message: 'Loading journal entries...',
                    );
                  } else if (state is JournalsLoaded) {
                    if (state.journals.isEmpty) {
                      return app_widgets.EmptyStateWidget(
                        message:
                            'No journal entries found. Create your first entry to get started.',
                        icon: Icons.edit_note,
                        onAction: () => _showAddJournalDialog(context),
                        actionLabel: 'Create Entry',
                      );
                    }
                    return _buildJournalTable(context, state.journals);
                  } else if (state is JournalError) {
                    return app_widgets.ErrorWidget(
                      message: state.message,
                      onRetry:
                          () => context.read<JournalBloc>().add(
                            const LoadJournals(),
                          ),
                    );
                  }
                  return const app_widgets.EmptyStateWidget(
                    message: 'No journal entries found',
                    icon: Icons.edit_note,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildJournalTable(BuildContext context, List<Journal> entries) {
  final dateFormat = DateFormat('yyyy-MM-dd');

  return app_widgets.CustomCard(
    padding: const EdgeInsets.all(0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppTheme.backgroundGrey),
          dataRowColor: MaterialStateProperty.all(AppTheme.pureWhite),
          dividerThickness: 1,
          columnSpacing: 24,
          headingTextStyle: AppTheme.heading3.copyWith(fontSize: 16),
          dataTextStyle: AppTheme.bodyText,
          columns: [
            DataColumn(
              label: Text(
                'Date',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Reference',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Description',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Status',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
            DataColumn(
              label: Text(
                'Actions',
                style: AppTheme.heading3.copyWith(fontSize: 16),
              ),
            ),
          ],
          rows:
              entries.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(Text(dateFormat.format(entry.date))),
                    DataCell(
                      Text(
                        entry.referenceNumber,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        entry.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(_buildStatusBadge(entry.isPosted)),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppTheme.primaryColor,
                            ),
                            tooltip: 'Edit Entry',
                            onPressed:
                                () => _showEditJournalDialog(context, entry),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppTheme.errorColor,
                            ),
                            tooltip: 'Delete Entry',
                            onPressed:
                                () => _confirmDeleteJournal(context, entry),
                          ),
                          if (!entry.isPosted)
                            IconButton(
                              icon: const Icon(
                                Icons.check_circle,
                                color: AppTheme.accentColor,
                              ),
                              tooltip: 'Post Entry',
                              onPressed:
                                  () => _confirmPostJournal(context, entry),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    ),
  );
}

Widget _buildStatusBadge(bool isPosted) {
  return app_widgets.StatusBadge(
    text: isPosted ? 'Posted' : 'Draft',
    isPositive: isPosted,
  );
}

void _showAddJournalDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const JournalForm(),
    barrierDismissible: false,
  );
}

void _showEditJournalDialog(BuildContext context, Journal journal) {
  showDialog(
    context: context,
    builder: (context) => JournalForm(journal: journal),
    barrierDismissible: false,
  );
}

void _confirmDeleteJournal(BuildContext context, Journal journal) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Delete Journal Entry', style: AppTheme.heading2),
          content: Text(
            'Are you sure you want to delete journal entry ${journal.referenceNumber}? This action cannot be undone.',
            style: AppTheme.bodyText,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<JournalBloc>().add(DeleteJournal(journal.id!));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
            ),
          ],
        ),
  );
}

void _confirmPostJournal(BuildContext context, Journal journal) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Post Journal Entry', style: AppTheme.heading2),
          content: Text(
            'Are you sure you want to post journal entry ${journal.referenceNumber}? '
            'This action will finalize the entry and record it in the general ledger. This action cannot be undone.',
            style: AppTheme.bodyText,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<JournalBloc>().add(
                  PostJournalToLedger(journal.id!),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Post'),
            ),
          ],
        ),
  );
}
