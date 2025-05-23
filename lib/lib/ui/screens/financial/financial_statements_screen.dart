import 'package:financel_acc/lib/Fa-package/bloc/ledger/ledger_bloc.dart';
import 'package:financel_acc/lib/Fa-package/bloc/ledger/ledger_event.dart';
import 'package:financel_acc/lib/Fa-package/bloc/ledger/ledger_state.dart';
import 'package:financel_acc/lib/Fa-package/data/models/financial_statement.dart';
import 'package:financel_acc/lib/ui/theme/app_theme.dart';
import 'package:financel_acc/lib/ui/widgets/common_widgets.dart' as app_widgets;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FinancialStatementsScreen extends StatefulWidget {
  const FinancialStatementsScreen({super.key});

  @override
  State<FinancialStatementsScreen> createState() =>
      _FinancialStatementsScreenState();
}

class _FinancialStatementsScreenState extends State<FinancialStatementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFinancialStatements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFinancialStatements() {
    // Load balance sheet with the selected date
    BlocProvider.of<LedgerBloc>(
      context,
    ).add(LoadBalanceSheet(asOfDate: _selectedDate));

    // Load income statement for the period from Jan 1 to selected date
    BlocProvider.of<LedgerBloc>(context).add(
      LoadIncomeStatement(
        startDate: DateTime(_selectedDate.year, 1, 1),
        endDate: _selectedDate,
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                app_widgets.PageHeader(
                  title: 'Financial Statements',
                  actions: [],
                ),
                TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primaryColor,
                  ),
                  label: Text(
                    DateFormat('MMMM dd, yyyy').format(_selectedDate),
                    style: AppTheme.bodyText.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Balance Sheet'),
                  Tab(text: 'Income Statement'),
                ],
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.mediumGrey,
                indicatorColor: AppTheme.primaryColor,
                labelStyle: AppTheme.bodyText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTheme.bodyText,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildBalanceSheet(), _buildIncomeStatement()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadFinancialStatements();
    }
  }

  Widget _buildBalanceSheet() {
    return BlocConsumer<LedgerBloc, LedgerState>(
      listenWhen:
          (previous, current) =>
              current is BalanceSheetLoaded || current is LedgerError,
      listener: (context, state) {
        if (state is LedgerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      buildWhen:
          (previous, current) =>
              current is LedgerLoading ||
              current is BalanceSheetLoaded ||
              current is LedgerError,
      builder: (context, state) {
        if (state is BalanceSheetLoaded) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildBalanceSheetTable(state.balanceSheet),
              ],
            ),
          );
        } else if (state is LedgerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No balance sheet data available'));
      },
    );
  }

  Widget _buildIncomeStatement() {
    final numberFormat = NumberFormat('#,##0.00');

    return BlocConsumer<LedgerBloc, LedgerState>(
      listenWhen:
          (previous, current) =>
              current is IncomeStatementLoaded || current is LedgerError,
      listener: (context, state) {
        if (state is LedgerError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      buildWhen:
          (previous, current) =>
              current is LedgerLoading ||
              current is IncomeStatementLoaded ||
              current is LedgerError,
      builder: (context, state) {
        if (state is IncomeStatementLoaded) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildIncomeStatementSection(
                    'Revenue',
                    state.incomeStatement.revenue.items,
                    state.incomeStatement.revenue.totalAmount,
                  ),
                  const SizedBox(height: 24),
                  _buildIncomeStatementSection(
                    'Expenses',
                    state.incomeStatement.expenses.items,
                    state.incomeStatement.expenses.totalAmount,
                  ),
                  const SizedBox(height: 24),
                  const Divider(thickness: 2),
                  ListTile(
                    title: const Text(
                      'Net Income',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '\$${numberFormat.format(state.incomeStatement.netIncome)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            state.incomeStatement.netIncome >= 0
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is LedgerLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return const Center(child: Text('No income statement data available'));
      },
    );
  }

  Widget _buildBalanceSheetTable(BalanceSheet balanceSheet) {
    final numberFormat = NumberFormat('#,##0.00');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('Account')),
          DataColumn(label: Text('Amount')),
        ],
        rows: [
          ...balanceSheet.assets.items.map(
            (item) => DataRow(
              cells: [
                DataCell(Text(item.accountName)),
                DataCell(Text('\$${numberFormat.format(item.balance)}')),
              ],
            ),
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Total Assets',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '\$${numberFormat.format(balanceSheet.totalAssets)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const DataRow(cells: [DataCell(Text('')), DataCell(Text(''))]),
          ...balanceSheet.liabilities.items.map(
            (item) => DataRow(
              cells: [
                DataCell(Text(item.accountName)),
                DataCell(Text('\$${numberFormat.format(item.balance)}')),
              ],
            ),
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Total Liabilities',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '\$${numberFormat.format(balanceSheet.liabilities.totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const DataRow(cells: [DataCell(Text('')), DataCell(Text(''))]),
          ...balanceSheet.equity.items.map(
            (item) => DataRow(
              cells: [
                DataCell(Text(item.accountName)),
                DataCell(Text('\$${numberFormat.format(item.balance)}')),
              ],
            ),
          ),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Total Equity',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '\$${numberFormat.format(balanceSheet.equity.totalAmount)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const DataRow(cells: [DataCell(Text('')), DataCell(Text(''))]),
          DataRow(
            cells: [
              const DataCell(
                Text(
                  'Total Liabilities & Equity',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              DataCell(
                Text(
                  '\$${numberFormat.format(balanceSheet.totalLiabilitiesEquity)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeStatementSection(
    String title,
    List<FinancialStatementItem> items,
    double total,
  ) {
    final numberFormat = NumberFormat('#,##0.00');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DataTable(
          columns: [
            DataColumn(label: Text('Account')),
            DataColumn(label: Text('Amount')),
          ],
          rows: [
            ...items.map(
              (item) => DataRow(
                cells: [
                  DataCell(Text(item.accountName)),
                  DataCell(Text('\$${numberFormat.format(item.balance)}')),
                ],
              ),
            ),
            DataRow(
              cells: [
                DataCell(
                  Text(
                    'Total $title',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(
                  Text(
                    '\$${numberFormat.format(total)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
