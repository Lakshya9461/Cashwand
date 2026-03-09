import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';

class ExportService {
  /// Generates the Excel file bytes for the given transactions.
  /// Transactions are expected to be unsorted or sorted DESC.
  /// We will sort them ASC inside here as per requirements.
  static Future<Uint8List> generateExcel(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) async {
    // 1. Setup Excel and sheets
    final excel = Excel.createExcel();
    final String sheetName = 'Transactions Report';
    final String summarySheetName = 'Category Summary';

    // Rename default sheet
    excel.rename(excel.getDefaultSheet()!, sheetName);
    Sheet sheet = excel[sheetName];

    // 2. Sort transactions ASC
    final sortedTx = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in sortedTx) {
      if (tx.isIncome) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final netSavings = totalIncome - totalExpense;

    // 3. Write Summary Block
    final dateFormatter = DateFormat('yyyy-MM-dd');
    sheet.appendRow([TextCellValue('Transaction Export Report')]);
    sheet.appendRow([
      TextCellValue('Date Range:'),
      TextCellValue(
        '${dateFormatter.format(start)} to ${dateFormatter.format(end)}',
      ),
    ]);
    sheet.appendRow([
      TextCellValue('Total Income:'),
      DoubleCellValue(totalIncome),
    ]);
    sheet.appendRow([
      TextCellValue('Total Expense:'),
      DoubleCellValue(totalExpense),
    ]);
    sheet.appendRow([
      TextCellValue('Net Savings:'),
      DoubleCellValue(netSavings),
    ]);
    sheet.appendRow([
      TextCellValue('Total Transactions:'),
      IntCellValue(sortedTx.length),
    ]);
    sheet.appendRow([TextCellValue('')]); // Blank row

    // 4. Write Headers
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Type'),
      TextCellValue('Category'),
      TextCellValue('Account'),
      TextCellValue('Description'),
      TextCellValue('Amount'),
      TextCellValue('Signed Amount'),
      TextCellValue('Running Balance'),
      TextCellValue('Month'),
      TextCellValue('Transaction ID'),
    ]);

    // 5. Write Transaction Rows with Running Balance
    double runningBalance = 0;
    final rowFormatter = DateFormat('yyyy-MM-dd HH:mm');
    final monthFormatter = DateFormat('MMMM yyyy');

    for (final tx in sortedTx) {
      runningBalance += tx.signedAmount;

      sheet.appendRow([
        TextCellValue(rowFormatter.format(tx.date)),
        TextCellValue(tx.type.label),
        TextCellValue(tx.categoryId),
        TextCellValue(tx.accountId ?? ''),
        TextCellValue(tx.description),
        DoubleCellValue(tx.amount),
        DoubleCellValue(tx.signedAmount),
        DoubleCellValue(runningBalance),
        TextCellValue(monthFormatter.format(tx.date)),
        TextCellValue(tx.id),
      ]);
    }

    // 6. Second Sheet: Category Summary
    Sheet catSheet = excel[summarySheetName];
    catSheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('Total Expense'),
      TextCellValue('% of Total'),
    ]);

    if (totalExpense > 0) {
      final categorySums = <String, double>{};
      for (final tx in sortedTx) {
        if (tx.isExpense) {
          final catLabel = tx.categoryId;
          categorySums[catLabel] = (categorySums[catLabel] ?? 0) + tx.amount;
        }
      }

      // Sort categories by expense descending
      final sortedCategories = categorySums.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (final entry in sortedCategories) {
        final percentage = (entry.value / totalExpense) * 100;
        catSheet.appendRow([
          TextCellValue(entry.key),
          DoubleCellValue(entry.value),
          DoubleCellValue(double.parse(percentage.toStringAsFixed(2))),
        ]);
      }
    }

    // Save
    return Uint8List.fromList(excel.encode()!);
  }
}
