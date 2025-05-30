import 'package:financel_acc/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/Fa-package/bloc/account/account_state.dart';
import 'package:financel_acc/Fa-package/bloc/ledger/ledger_bloc.dart';
import 'package:financel_acc/Fa-package/bloc/ledger/ledger_event.dart';
import 'package:financel_acc/Fa-package/bloc/ledger/ledger_state.dart';
import 'package:financel_acc/Fa-package/data/models/account.dart';
import 'package:financel_acc/ui/theme/app_theme.dart';
import 'package:financel_acc/ui/widgets/common_widgets.dart' as app_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class GeneralLedgerScreen extends StatefulWidget {
  const GeneralLedgerScreen({super.key});

  @override
  State<GeneralLedgerScreen> createState() => _GeneralLedgerScreenState();
}

class _GeneralLedgerScreenState extends State<GeneralLedgerScreen> {
  Account? selectedAccount;

  @override
  void initState() {
    super.initState();
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
            app_widgets.PageHeader(title: 'General Ledger', actions: []),
            const SizedBox(height: 16),
            _buildAccountSelector(),
            const SizedBox(height: 24),
            Expanded(
              child:
                  selectedAccount == null
                      ? app_widgets.EmptyStateWidget(
                        message: 'Select an account to view ledger entries',
                        icon: Icons.list_alt,
                      )
                      : _buildLedgerEntries(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountsLoading) {
          return const app_widgets.LoadingWidget(
            message: 'Loading accounts...',
          );
        } else if (state is AccountsLoaded) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.lightGrey),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: DropdownButtonFormField<Account>(
              decoration: InputDecoration(
                labelText: 'Select Account',
                labelStyle: AppTheme.bodyText.copyWith(
                  color: AppTheme.primaryColor,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              value: selectedAccount,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppTheme.primaryColor,
              ),
              style: AppTheme.bodyText,
              items:
                  state.accounts.map((account) {
                    return DropdownMenuItem(
                      value: account,
                      child: Text('${account.accountNumber} - ${account.name}'),
                    );
                  }).toList(),
              onChanged: (account) {
                setState(() {
                  selectedAccount = account;
                });
                if (account != null) {
                  context.read<LedgerBloc>().add(
                    LoadLedgerForAccount(account.id!),
                  );
                }
              },
            ),
          );
        } else if (state is AccountError) {
          return app_widgets.ErrorWidget(
            message: state.message,
            onRetry:
                () => context.read<AccountBloc>().add(const LoadAccounts()),
          );
        }
        return const app_widgets.EmptyStateWidget(
          message: 'Failed to load accounts',
          icon: Icons.error_outline,
        );
      },
    );
  }

  Widget _buildLedgerEntries() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final numberFormat = NumberFormat('#,##0.00');

    return BlocBuilder<LedgerBloc, LedgerState>(
      builder: (context, state) {
        if (state is LedgerLoading) {
          return const app_widgets.LoadingWidget(
            message: 'Loading ledger entries...',
          );
        } else if (state is LedgerLoaded) {
          if (state.ledgerEntries.isEmpty) {
            return app_widgets.EmptyStateWidget(
              message: 'No ledger entries found for this account',
              icon: Icons.list_alt,
            );
          }

          return app_widgets.CustomCard(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '${selectedAccount?.accountNumber} - ${selectedAccount?.name}',
                    style: AppTheme.heading3,
                  ),
                ),
                Divider(color: AppTheme.lightGrey, height: 1),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        AppTheme.backgroundGrey,
                      ),
                      dataRowColor: MaterialStateProperty.all(
                        AppTheme.pureWhite,
                      ),
                      dividerThickness: 1,
                      columnSpacing: 24,
                      headingTextStyle: AppTheme.heading3.copyWith(
                        fontSize: 16,
                      ),
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
                            'Debit',
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Credit',
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Balance',
                            style: AppTheme.heading3.copyWith(fontSize: 16),
                          ),
                        ),
                      ],
                      rows:
                          state.ledgerEntries.map((entry) {
                            return DataRow(
                              cells: [
                                DataCell(Text(dateFormat.format(entry.date))),
                                DataCell(
                                  Text(
                                    entry.referenceNumber ?? '',
                                    style: AppTheme.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    entry.debit > 0
                                        ? numberFormat.format(entry.debit)
                                        : '',
                                    textAlign: TextAlign.right,
                                    style: AppTheme.bodyText.copyWith(
                                      color:
                                          entry.debit > 0
                                              ? AppTheme.successColor
                                              : null,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    entry.credit > 0
                                        ? numberFormat.format(entry.credit)
                                        : '',
                                    textAlign: TextAlign.right,
                                    style: AppTheme.bodyText.copyWith(
                                      color:
                                          entry.credit > 0
                                              ? AppTheme.errorColor
                                              : null,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    numberFormat.format(entry.balance),
                                    textAlign: TextAlign.right,
                                    style: AppTheme.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          entry.balance >= 0
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const app_widgets.EmptyStateWidget(
          message: 'No ledger entries found',
          icon: Icons.list_alt,
        );
      },
    );
  }
}
