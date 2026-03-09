import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/domain/enums/category_type.dart';

void main() {
  group('CategoryType', () {
    test('has exactly 9 values', () {
      expect(CategoryType.values.length, 9);
    });

    test('every category has a non-empty label', () {
      for (final category in CategoryType.values) {
        expect(
          category.label,
          isNotEmpty,
          reason: '${category.name} has empty label',
        );
      }
    });

    test('all labels are unique', () {
      final labels = CategoryType.values.map((c) => c.label).toSet();
      expect(labels.length, CategoryType.values.length);
    });

    test('expected categories exist', () {
      final names = CategoryType.values.map((c) => c.name).toSet();
      expect(
        names,
        containsAll([
          'food',
          'transport',
          'shopping',
          'bills',
          'entertainment',
          'health',
          'education',
          'salary',
          'other',
        ]),
      );
    });

    test('"other" category exists as catch-all', () {
      expect(CategoryType.other.label, 'Other');
    });

    test('"salary" category exists for income entries', () {
      expect(CategoryType.salary.label, 'Salary');
    });
  });
}
