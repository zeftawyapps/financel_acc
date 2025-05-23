import 'package:financel_acc/lib/Fa-package/bloc/account/account_bloc.dart'
    as account;
import 'package:financel_acc/lib/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_state.dart'
    as account;
import 'package:financel_acc/lib/Fa-package/data/models/account.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AccountForm extends StatefulWidget {
  final Account? account;

  const AccountForm({super.key, this.account});

  @override
  State<AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _nameController = TextEditingController();

  int? _selectedTypeId;
  int? _selectedParentId;

  List<AccountType> _accountTypes = [];
  List<Account> _parentAccounts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load account types and existing accounts
    context.read<account.AccountBloc>().add(const LoadAccountTypes());
    context.read<account.AccountBloc>().add(const LoadAccounts());

    // If editing, populate the form
    if (widget.account != null) {
      _accountNumberController.text = widget.account!.accountNumber;
      _nameController.text = widget.account!.name;
      _selectedTypeId = widget.account!.typeId;
      _selectedParentId = widget.account!.parentId;
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // New function to build account type dropdown items
  List<DropdownMenuItem<int>> _buildAccountTypeItems() {
    return _accountTypes.map((type) {
      return DropdownMenuItem(
        value: type.id,
        child: Text('${type.name} (${type.code})'),
      );
    }).toList();
  }

  // New function to build parent account dropdown items
  List<DropdownMenuItem<int?>> _buildParentAccountItems() {
    return [
      const DropdownMenuItem(
        value: null,
        child: Text('No Parent (Root Account)'),
      ),
      ..._parentAccounts.map((account) {
        return DropdownMenuItem(
          value: account.id,
          child: Text('${account.accountNumber} - ${account.name}'),
        );
      }).toList(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
      content: BlocListener<account.AccountBloc, account.AccountState>(
        listener: (context, state) {
          if (state is account.AccountTypesLoaded) {
            setState(() {
              _accountTypes.clear(); // Clear the list before loading new data
              _accountTypes = state.accountTypes;
              if (_selectedTypeId == null && _accountTypes.isNotEmpty) {
                _selectedTypeId = _accountTypes.first.id;
              }
            });
          } else if (state is account.AccountsLoaded) {
            setState(() {
              _parentAccounts.clear(); // Clear the list before loading new data
              _parentAccounts = state.accounts;
              _isLoading = false;
            });
          }
        },
        child: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _accountNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                    hintText: 'e.g. 1000',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g. Cash',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter account name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  value: _selectedTypeId,
                  items: _buildAccountTypeItems(), // Use the new function
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select account type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int?>(
                  decoration: const InputDecoration(
                    labelText: 'Parent Account (Optional)',
                  ),
                  value: _selectedParentId,
                  items: _buildParentAccountItems(), // Use the new function
                  onChanged: (value) {
                    setState(() {
                      _selectedParentId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAccount,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      // Calculate level based on parent
      int level = 1;
      if (_selectedParentId != null) {
        final parentAccount = _parentAccounts.firstWhere(
          (account) => account.id == _selectedParentId,
        );
        level = parentAccount.level + 1;
      }
      final accountModel = Account(
        id: widget.account?.id,
        accountNumber: _accountNumberController.text,
        name: _nameController.text,
        typeId: _selectedTypeId!,
        parentId: _selectedParentId,
        level: level,
        isActive: widget.account?.isActive ?? true,
        createdAt: widget.account?.createdAt ?? now,
        updatedAt: now,
      );
      if (widget.account == null) {
        context.read<account.AccountBloc>().add(AddAccount(accountModel));
      } else {
        context.read<account.AccountBloc>().add(UpdateAccount(accountModel));
      }

      Navigator.of(context).pop(true);
    }
  }
}
