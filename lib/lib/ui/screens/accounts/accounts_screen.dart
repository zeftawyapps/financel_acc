import 'package:financel_acc/lib/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_state.dart';
import 'package:financel_acc/lib/Fa-package/data/models/account.dart';
import 'package:financel_acc/lib/ui/theme/app_theme.dart';
import 'package:financel_acc/lib/ui/widgets/common_widgets.dart' as app_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'account_form.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    // Load the accounts when screen is displayed
    context.read<AccountBloc>().add(const LoadAccounts());
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
              title: 'Chart of Accounts',
              actions: [
                app_widgets.ActionButton(
                  icon: Icons.add,
                  label: 'Add Account',
                  onPressed: () => _showAddAccountDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountsLoading) {
                    return const app_widgets.LoadingWidget(
                      message: 'Loading accounts...',
                    );
                  } else if (state is AccountsLoaded) {
                    if (state.accounts.isEmpty) {
                      return app_widgets.EmptyStateWidget(
                        message:
                            'No accounts found. Add your first account to get started.',
                        icon: Icons.account_balance_wallet,
                        onAction: () => _showAddAccountDialog(context),
                        actionLabel: 'Add Account',
                      );
                    }
                    return _buildAccountsTable(context, state.accounts);
                  } else if (state is AccountError) {
                    return app_widgets.ErrorWidget(
                      message: state.message,
                      onRetry:
                          () => context.read<AccountBloc>().add(
                            const LoadAccounts(),
                          ),
                    );
                  }
                  return const app_widgets.EmptyStateWidget(
                    message: 'No accounts found',
                    icon: Icons.account_balance_wallet,
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

Widget _buildAccountsTable(BuildContext context, List<Account> accounts) {
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
            DataColumn(label: Text('Account Number')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Level')),
            DataColumn(label: Text('Actions')),
          ],
          rows:
              accounts.map((account) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        account.accountNumber,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DataCell(Text(account.name)),
                    DataCell(
                      _buildAccountTypeCell(account.accountType?.name ?? ''),
                    ),
                    DataCell(Text(account.level.toString())),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppTheme.primaryColor,
                            ),
                            tooltip: 'Edit Account',
                            onPressed:
                                () => _showEditAccountDialog(context, account),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: AppTheme.errorColor,
                            ),
                            tooltip: 'Delete Account',
                            onPressed:
                                () => _confirmDeleteAccount(context, account),
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

Widget _buildAccountTypeCell(String accountType) {
  Color badgeColor;

  switch (accountType.toLowerCase()) {
    case 'asset':
      badgeColor = Colors.blue;
      break;
    case 'liability':
      badgeColor = Colors.orange;
      break;
    case 'equity':
      badgeColor = Colors.green;
      break;
    case 'revenue':
      badgeColor = Colors.purple;
      break;
    case 'expense':
      badgeColor = Colors.red;
      break;
    default:
      badgeColor = AppTheme.mediumGrey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: badgeColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: badgeColor.withOpacity(0.3)),
    ),
    child: Text(
      accountType,
      style: TextStyle(
        color: badgeColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

void _showAddAccountDialog(BuildContext context) {
  showDialog(context: context, builder: (context) => const AccountForm());
}

void _showEditAccountDialog(BuildContext context, Account account) {
  showDialog(
    context: context,
    builder: (context) => AccountForm(account: account),
  );
}

void _confirmDeleteAccount(BuildContext context, Account account) {
  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text('Delete Account', style: AppTheme.heading2),
          content: Text(
            'Are you sure you want to delete ${account.name}? This action cannot be undone.',
            style: AppTheme.bodyText,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AccountBloc>().add(DeleteAccount(account.id!));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              icon: const Icon(Icons.delete),
              label: Text('Delete'),
            ),
          ],
        ),
  );
}
