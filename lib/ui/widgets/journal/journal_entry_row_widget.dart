import 'package:financel_acc/Fa-package/data/models/account.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class JournalEntryRow extends StatefulWidget {
  final List<Account> accounts;
  final Function(Key) onDelete;
  final Function() onValueChanged;
  final bool isReadOnly;

  // These getters will be used to calculate totals in the parent widget
  int? get accountId => state?.selectedAccountId;
  String? get description => state?.descriptionController.text;
  double get debitAmount => state?.debitAmount ?? 0.0;
  double get creditAmount => state?.creditAmount ?? 0.0;

  // Reference to the state to access current values
  // ignore: library_private_types_in_public_api
  JournalEntryRowState? state;

  // Update accounts list when loaded
  void updateAccounts(List<Account> newAccounts) {
    state?.updateAccounts(newAccounts);
  }

  JournalEntryRow({
    required Key key,
    required this.accounts,
    required this.onDelete,
    required this.onValueChanged,
    this.isReadOnly = false,
  }) : super(key: key);
  @override
  State<JournalEntryRow> createState() => JournalEntryRowState();
}

class JournalEntryRowState extends State<JournalEntryRow> {
  int? selectedAccountId;
  final descriptionController = TextEditingController();
  final debitController = TextEditingController();
  final creditController = TextEditingController();
  double debitAmount = 0.0;
  double creditAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Set the reference to this state in the widget
    widget.state = this;
  }

  @override
  void dispose() {
    descriptionController.dispose();
    debitController.dispose();
    creditController.dispose();
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
              value: selectedAccountId,
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
                          selectedAccountId = value;
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
              controller: descriptionController,
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
              controller: debitController,
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
                  debitAmount = double.tryParse(value) ?? 0.0;

                  // Clear credit if debit has a value
                  if (debitAmount > 0) {
                    creditController.text = '';
                    creditAmount = 0.0;
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
              controller: creditController,
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
                  creditAmount = double.tryParse(value) ?? 0.0;

                  // Clear debit if credit has a value
                  if (creditAmount > 0) {
                    debitController.text = '';
                    debitAmount = 0.0;
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
