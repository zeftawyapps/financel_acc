import 'package:financel_acc/lib/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_state.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_event.dart';
import 'package:financel_acc/lib/Fa-package/bloc/journal/journal_state.dart';
import 'package:financel_acc/lib/Fa-package/data/models/account.dart';
import 'package:financel_acc/lib/Fa-package/data/models/journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      });

                      // Set the values manually after initialization
                      Future.delayed(Duration.zero, () {
                        if (row._state != null) {
                          row._state!._selectedAccountId = entry.accountId;
                          row._state!._descriptionController.text =
                              entry.description ?? '';
                          if (entry.debit > 0) {
                            row._state!._debitController.text =
                                entry.debit.toString();
                            row._state!._debitAmount = entry.debit;
                          }
                          if (entry.credit > 0) {
                            row._state!._creditController.text =
                                entry.credit.toString();
                            row._state!._creditAmount = entry.credit;
                          }
                          // Force refresh UI
                          row._state!.setState(() {});
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

// ignore: must_be_immutable
class JournalEntryRow extends StatefulWidget {
  final List<Account> accounts;
  final Function(Key) onDelete;
  final Function() onValueChanged;
  final bool isReadOnly;

  // These getters will be used to calculate totals in the parent widget
  int? get accountId => _state?._selectedAccountId;
  String? get description => _state?._descriptionController.text;
  double get debitAmount => _state?._debitAmount ?? 0.0;
  double get creditAmount => _state?._creditAmount ?? 0.0;

  // Reference to the state to access current values
  // ignore: library_private_types_in_public_api
  _JournalEntryRowState? _state;

  // Update accounts list when loaded
  void updateAccounts(List<Account> newAccounts) {
    _state?.updateAccounts(newAccounts);
  }

  JournalEntryRow({
    required Key key,
    required this.accounts,
    required this.onDelete,
    required this.onValueChanged,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  State<JournalEntryRow> createState() => _JournalEntryRowState();
}

class _JournalEntryRowState extends State<JournalEntryRow> {
  int? _selectedAccountId;
  final _descriptionController = TextEditingController();
  final _debitController = TextEditingController();
  final _creditController = TextEditingController();
  double _debitAmount = 0.0;
  double _creditAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Set the reference to this state in the widget
    widget._state = this;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _debitController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  void updateAccounts(List<Account> newAccounts) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              value: _selectedAccountId,
              hint: const Text('Select Account'),
              isExpanded: true,
              isDense: true,
              items:
                  widget.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.accountNumber} - ${account.name}'),
                    );
                  }).toList(),
              onChanged:
                  widget.isReadOnly
                      ? null
                      : (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                        widget.onValueChanged();
                      },
              validator: (value) {
                if (value == null) {
                  return 'Required';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              readOnly: widget.isReadOnly,
              onChanged: (_) => widget.onValueChanged(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _debitController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              readOnly: widget.isReadOnly,
              onChanged: (value) {
                setState(() {
                  _debitAmount = double.tryParse(value) ?? 0.0;

                  // Clear credit if debit has a value
                  if (_debitAmount > 0) {
                    _creditController.text = '';
                    _creditAmount = 0.0;
                  }
                });
                widget.onValueChanged();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _creditController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
              ),
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              readOnly: widget.isReadOnly,
              onChanged: (value) {
                setState(() {
                  _creditAmount = double.tryParse(value) ?? 0.0;

                  // Clear debit if credit has a value
                  if (_creditAmount > 0) {
                    _debitController.text = '';
                    _debitAmount = 0.0;
                  }
                });
                widget.onValueChanged();
              },
            ),
          ),
          SizedBox(
            width: 48,
            child:
                widget.isReadOnly
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => widget.onDelete(widget.key!),
                    ),
          ),
        ],
      ),
    );
  }
}
