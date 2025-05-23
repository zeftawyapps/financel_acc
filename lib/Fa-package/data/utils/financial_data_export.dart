import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import '../models/financial_statement.dart';

class FinancialDataExport {
  /// Export balance sheet data to CSV
  static Future<String?> exportBalanceSheetToCSV(
    BalanceSheet balanceSheet,
  ) async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyy-MM-dd').format(balanceSheet.asOfDate);
      final fileName = 'balance_sheet_$dateStr.csv';
      final file = File('${directory.path}/$fileName');

      // Build CSV content
      final buffer = StringBuffer();

      // Add header
      buffer.writeln(
        'Balance Sheet as of ${DateFormat('MMMM dd, yyyy').format(balanceSheet.asOfDate)}',
      );
      buffer.writeln();

      // ASSETS section
      buffer.writeln('ASSETS');
      buffer.writeln('Account Number,Account Name,Account Type,Balance');

      for (final item in balanceSheet.assets.items) {
        buffer.writeln(
          '${item.accountNumber},${item.accountName.replaceAll(',', ' ')},${item.accountTypeName},${item.balance}',
        );
      }

      buffer.writeln('Total Assets,,${balanceSheet.totalAssets}');
      buffer.writeln();

      // LIABILITIES section
      buffer.writeln('LIABILITIES');
      buffer.writeln('Account Number,Account Name,Account Type,Balance');

      for (final item in balanceSheet.liabilities.items) {
        buffer.writeln(
          '${item.accountNumber},${item.accountName.replaceAll(',', ' ')},${item.accountTypeName},${item.balance}',
        );
      }

      buffer.writeln(
        'Total Liabilities,,${balanceSheet.liabilities.totalAmount}',
      );
      buffer.writeln();

      // EQUITY section
      buffer.writeln('EQUITY');
      buffer.writeln('Account Number,Account Name,Account Type,Balance');

      for (final item in balanceSheet.equity.items) {
        buffer.writeln(
          '${item.accountNumber},${item.accountName.replaceAll(',', ' ')},${item.accountTypeName},${item.balance}',
        );
      }

      buffer.writeln('Total Equity,,${balanceSheet.equity.totalAmount}');
      buffer.writeln();

      buffer.writeln(
        'Total Liabilities & Equity,,${balanceSheet.totalLiabilitiesEquity}',
      );

      // Write to file
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      print('Error exporting balance sheet to CSV: $e');
      return null;
    }
  }

  /// Export income statement data to CSV
  static Future<String?> exportIncomeStatementToCSV(
    IncomeStatement incomeStatement,
  ) async {
    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final startDateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(incomeStatement.startDate);
      final endDateStr = DateFormat(
        'yyyy-MM-dd',
      ).format(incomeStatement.endDate);
      final fileName = 'income_statement_${startDateStr}_to_$endDateStr.csv';
      final file = File('${directory.path}/$fileName');

      // Build CSV content
      final buffer = StringBuffer();

      // Add header
      buffer.writeln(
        'Income Statement for the period ${DateFormat('MMMM dd, yyyy').format(incomeStatement.startDate)} - ${DateFormat('MMMM dd, yyyy').format(incomeStatement.endDate)}',
      );
      buffer.writeln();

      // REVENUE section
      buffer.writeln('REVENUE');
      buffer.writeln('Account Number,Account Name,Account Type,Amount');

      for (final item in incomeStatement.revenue.items) {
        buffer.writeln(
          '${item.accountNumber},${item.accountName.replaceAll(',', ' ')},${item.accountTypeName},${item.balance}',
        );
      }

      buffer.writeln('Total Revenue,,${incomeStatement.revenue.totalAmount}');
      buffer.writeln();

      // EXPENSES section
      buffer.writeln('EXPENSES');
      buffer.writeln('Account Number,Account Name,Account Type,Amount');

      for (final item in incomeStatement.expenses.items) {
        buffer.writeln(
          '${item.accountNumber},${item.accountName.replaceAll(',', ' ')},${item.accountTypeName},${item.balance}',
        );
      }

      buffer.writeln('Total Expenses,,${incomeStatement.expenses.totalAmount}');
      buffer.writeln();

      buffer.writeln('Net Income,,${incomeStatement.netIncome}');

      // Write to file
      await file.writeAsString(buffer.toString());

      return file.path;
    } catch (e) {
      print('Error exporting income statement to CSV: $e');
      return null;
    }
  }

  /// Share exported file using platform's share feature
  static Future<void> shareFile(String filePath, String title) async {
    try {
      final result = await Share.shareXFiles([XFile(filePath)], subject: title);

      if (result.status == ShareResultStatus.dismissed) {
        print('Share cancelled by user');
      }
    } catch (e) {
      print('Error sharing file: $e');
    }
  }

  /// Request storage permission if needed (for Android)
  static Future<bool> requestStoragePermission() async {
    // For Android 10 and above
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }

    // For iOS or other platforms, no storage permission needed
    return true;
  }
}
