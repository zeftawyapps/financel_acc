import 'package:financel_acc/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/Fa-package/bloc/account/account_state.dart';
import 'package:financel_acc/Fa-package/bloc/journal/journal_bloc.dart';
import 'package:financel_acc/Fa-package/bloc/journal/journal_event.dart';
import 'package:financel_acc/Fa-package/bloc/journal/journal_state.dart';
import 'package:financel_acc/Fa-package/data/models/account.dart';
import 'package:financel_acc/Fa-package/data/models/journal.dart';
import 'package:financel_acc/ui/widgets/journal/journal_entry_row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class JournalForm extends StatefulWidget {
  final Journal? journal;

  const JournalForm({super.key, this.journal});

  @override
  State<JournalForm> createState() => _JournalFormState();
}

class _JournalFormState extends State<JournalForm> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<JournalEntryRow> _entryRows = [];
  final List<Account> _accounts = [];
  bool _isLoading = true;
  double _totalDebit = 0.0;
  double _totalCredit = 0.0;

  @override
  void initState() {
    super.initState();

    // Load accounts for dropdown
    context.read<AccountBloc>().add(const LoadAccounts());

    // Initialize date with today if adding new journal
    if (widget.journal == null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Add initial two empty rows for debit and credit
      _addEmptyRow();
      _addEmptyRow();
    } else {
      // Populate form with existing journal data
      _dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.journal!.date);
      _referenceController.text = widget.journal!.referenceNumber;
      _descriptionController.text = widget.journal!.description ?? '';

      // Load journal entries if editing
      _loadJournalEntries();
    }
  }

  void _loadJournalEntries() {
    if (widget.journal?.id != null) {
      // Load the journal entries for this journal
      context.read<JournalBloc>().add(LoadJournal(widget.journal!.id!));
    }

    // If no entries were loaded or creating a new journal, add empty rows
    if (_entryRows.isEmpty) {
      _addEmptyRow();
      _addEmptyRow();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addEmptyRow() {
    setState(() {
      _entryRows.add(
        JournalEntryRow(
          key: UniqueKey(),
          accounts: _accounts,
          onDelete: _deleteRow,
          onValueChanged: _updateTotals,
          isReadOnly: widget.journal?.isPosted ?? false,
        ),
      );
    });
  }

  void _deleteRow(Key key) {
    setState(() {
      _entryRows.removeWhere((row) => row.key == key);
      _updateTotals();
    });
  }

  void _updateTotals() {
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    for (var row in _entryRows) {
      totalDebit += row.debitAmount;
      totalCredit += row.creditAmount;
    }

    setState(() {
      _totalDebit = totalDebit;
      _totalCredit = totalCredit;
    });
  }

  void _saveJournal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_totalDebit != _totalCredit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Total debit must equal total credit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_entryRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one journal entry line is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Collect data from rows
    final List<JournalEntry> entries = [];
    final now = DateTime.now();

    for (var row in _entryRows) {
      if (row.accountId != null &&
          (row.debitAmount > 0 || row.creditAmount > 0)) {
        entries.add(
          JournalEntry(
            id: null,
            journalId: widget.journal?.id ?? 0,
            accountId: row.accountId!,
            description: row.description,
            debit: row.debitAmount,
            credit: row.creditAmount,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    if (entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add valid journal entries'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final journal = Journal(
      id: widget.journal?.id,
      date: DateFormat('yyyy-MM-dd').parse(_dateController.text),
      referenceNumber: _referenceController.text,
      description: _descriptionController.text,
      isPosted: widget.journal?.isPosted ?? false,
      createdAt: widget.journal?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.journal == null) {
      context.read<JournalBloc>().add(AddJournal(journal, entries));
    } else {
      context.read<JournalBloc>().add(UpdateJournal(journal, entries));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: MultiBlocListener(
          listeners: [
            BlocListener<AccountBloc, AccountState>(
              listener: (context, state) {
                if (state is AccountsLoaded) {
                  setState(() {
                    _accounts.clear();
                    _accounts.addAll(state.accounts);
                    _isLoading = false;

                    // Update account references in rows
                    for (var row in _entryRows) {
                      row.updateAccounts(_accounts);
                    }
                  });
                }
              },
            ),
            BlocListener<JournalBloc, JournalState>(
              listener: (context, state) {
                if (state is JournalLoaded &&
                    widget.journal != null &&
                    state.journal.id == widget.journal!.id) {
                  // Clear existing rows
                  setState(() {
                    _entryRows.clear();
                  });

                  // Add rows for each entry
                  if (state.journal.entries != null &&
                      state.journal.entries!.isNotEmpty) {
                    for (var entry in state.journal.entries!) {
                      // Create new rows
                      final row = JournalEntryRow(
                        key: UniqueKey(),
                        accounts: _accounts,
                        onDelete: _deleteRow,
                        onValueChanged: _updateTotals,
                        isReadOnly: widget.journal?.isPosted ?? false,
                      );

                      setState(() {
                        _entryRows.add(row);
                      }); // Set the values manually after initialization
                      Future.delayed(Duration.zero, () {
                        if (row.state != null) {
                          row.state!.selectedAccountId = entry.accountId;
                          row.state!.descriptionController.text =
                              entry.description ?? '';
                          if (entry.debit > 0) {
                            row.state!.debitController.text =
                                entry.debit.toString();
                            row.state!.debitAmount = entry.debit;
                          }
                          if (entry.credit > 0) {
                            row.state!.creditController.text =
                                entry.credit.toString();
                            row.state!.creditAmount = entry.credit;
                          }
                          // Force refresh UI
                          row.state!.setState(() {});
                        }
                      });
                    }
                    // Update totals after loading entries
                    _updateTotals();
                  }
                }
              },
            ),
          ],
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.journal == null
                      ? 'Add Journal Entry'
                      : 'Edit Journal Entry',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          hintText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.journal?.isPosted ?? false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a date';
                          }
                          try {
                            DateFormat('yyyy-MM-dd').parse(value);
                          } catch (e) {
                            return 'Please enter a valid date';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _referenceController,
                        decoration: const InputDecoration(
                          labelText: 'Reference Number',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: widget.journal?.isPosted ?? false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a reference number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: widget.journal?.isPosted ?? false,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Journal entry line items header
                const Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Debit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Credit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 48), // For delete button
                  ],
                ),
                const Divider(),
                // Journal entry line items list
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _entryRows.length,
                    itemBuilder: (context, index) => _entryRows[index],
                  ),
                ),
                // Add row button
                if (!(widget.journal?.isPosted ?? false))
                  TextButton.icon(
                    onPressed: _addEmptyRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Line'),
                  ),
                const Divider(),
                // Totals row
                Row(
                  children: [
                    const Expanded(flex: 3, child: SizedBox()),
                    const SizedBox(width: 8),
                    const Expanded(
                      flex: 2,
                      child: Text(
                        'Totals:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat.currency(symbol: '').format(_totalDebit),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _totalDebit != _totalCredit ? Colors.red : null,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        NumberFormat.currency(symbol: '').format(_totalCredit),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _totalDebit != _totalCredit ? Colors.red : null,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                // Balance status
                if (_totalDebit != _totalCredit)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Journal entry is not balanced',
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.right,
                    ),
                  ),
                const SizedBox(height: 16),
                // Dialog actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    if (!(widget.journal?.isPosted ?? false))
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveJournal,
                        child: Text(widget.journal == null ? 'Save' : 'Update'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
