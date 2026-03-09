import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';

void main() {
  group('TransactionType', () {
    test('has exactly 2 values', () {
      expect(TransactionType.values.length, 2);
    });

    test('income has positive sign (+1)', () {
      expect(TransactionType.income.sign, 1);
    });

    test('expense has negative sign (-1)', () {
      expect(TransactionType.expense.sign, -1);
    });

    test('income label is "Income"', () {
      expect(TransactionType.income.label, 'Income');
    });

    test('expense label is "Expense"', () {
      expect(TransactionType.expense.label, 'Expense');
    });
  });
}
