import 'package:financel_acc/lib/Fa-package/bloc/account/account_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/account/account_event.dart';
import 'package:financel_acc/lib/ui/screens/accounts/accounts_screen.dart';
import 'package:financel_acc/lib/ui/screens/financial/financial_statements_screen.dart';
import 'package:financel_acc/lib/ui/screens/journal/journal_entries_screen.dart';
import 'package:financel_acc/lib/ui/screens/ledger/general_ledger_screen.dart';
import 'package:financel_acc/lib/ui/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<AccountBloc>().add(const LoadAccounts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance,
                        color: AppTheme.primaryColor,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Financial Accounting',
                        style: AppTheme.heading3.copyWith(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppTheme.lightGrey),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Icons.account_balance_wallet,
                        label: 'Chart of Accounts',
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Icons.edit_note,
                        label: 'Journal Entries',
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Icons.list_alt,
                        label: 'General Ledger',
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Icons.bar_chart,
                        label: 'Financial Statements',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = index == _selectedIndex;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          border:
              isSelected
                  ? Border(
                    left: BorderSide(color: AppTheme.primaryColor, width: 4),
                  )
                  : null,
        ),
        padding: EdgeInsets.only(
          left: isSelected ? 21 : 25,
          top: 16,
          bottom: 16,
          right: 25,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.mediumGrey,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: AppTheme.bodyText.copyWith(
                color: isSelected ? AppTheme.primaryColor : AppTheme.darkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return const AccountsScreen();
      case 1:
        return const JournalEntriesScreen();
      case 2:
        return const GeneralLedgerScreen();
      case 3:
        return const FinancialStatementsScreen();
      default:
        return const Center(child: Text('Select a menu item'));
    }
  }
}
