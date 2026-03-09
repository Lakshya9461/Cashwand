import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helper: creates a valid entity with sensible defaults.
  // Override any field to test specific scenarios.
  // ---------------------------------------------------------------------------
  TransactionEntity makeEntity({
    String id = 'test-id-001',
    double amount = 100.0,
    TransactionType type = TransactionType.expense,
    String categoryId = 'food-id',
    String description = 'Test transaction',
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type,
      categoryId: categoryId,
      description: description,
      date: date ?? DateTime.now(),
      createdAt: createdAt,
    );
  }

  // ===========================================================================
  // CONSTRUCTION — Valid Entities
  // ===========================================================================

  group('Construction - valid entities', () {
    test('creates entity with all required fields', () {
      final entity = makeEntity();
      expect(entity.id, 'test-id-001');
      expect(entity.amount, 100.0);
      expect(entity.type, TransactionType.expense);
      expect(entity.categoryId, 'food-id');
      expect(entity.description, 'Test transaction');
    });

    test('auto-sets createdAt when not provided', () {
      final before = DateTime.now();
      final entity = makeEntity();
      final after = DateTime.now();

      expect(
        entity.createdAt.isAfter(before) ||
            entity.createdAt.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        entity.createdAt.isBefore(after) ||
            entity.createdAt.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('uses provided createdAt when given', () {
      final customDate = DateTime(2026, 1, 1, 12, 0, 0);
      final entity = makeEntity(createdAt: customDate);
      expect(entity.createdAt, customDate);
    });

    test('allows empty description (defaults to empty string)', () {
      final entity = makeEntity(description: '');
      expect(entity.description, '');
    });

    test('allows minimum positive amount (0.01)', () {
      final entity = makeEntity(amount: 0.01);
      expect(entity.amount, 0.01);
    });

    test('allows maximum amount (10,000,000)', () {
      final entity = makeEntity(amount: 10000000);
      expect(entity.amount, 10000000);
    });

    test('allows description exactly at 100 characters', () {
      final desc = 'a' * 100;
      final entity = makeEntity(description: desc);
      expect(entity.description.length, 100);
    });

    test('allows today as transaction date', () {
      final today = DateTime.now();
      final entity = makeEntity(date: today);
      expect(entity.date, today);
    });
  });

  // ===========================================================================
  // VALIDATION — Amount
  // ===========================================================================

  group('Validation - amount', () {
    test('rejects zero amount', () {
      expect(() => makeEntity(amount: 0), throwsA(isA<ArgumentError>()));
    });

    test('rejects negative amount', () {
      expect(() => makeEntity(amount: -50.0), throwsA(isA<ArgumentError>()));
    });

    test('rejects amount exceeding 10,000,000', () {
      expect(() => makeEntity(amount: 10000001), throwsA(isA<ArgumentError>()));
    });

    test('rejects very small negative amount (-0.01)', () {
      expect(() => makeEntity(amount: -0.01), throwsA(isA<ArgumentError>()));
    });
  });

  // ===========================================================================
  // VALIDATION — Description
  // ===========================================================================

  group('Validation - description', () {
    test('rejects description longer than 100 characters', () {
      final longDesc = 'a' * 101;
      expect(
        () => makeEntity(description: longDesc),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects very long description (1000 chars)', () {
      final veryLongDesc = 'x' * 1000;
      expect(
        () => makeEntity(description: veryLongDesc),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ===========================================================================
  // VALIDATION — Date
  // ===========================================================================

  group('Validation - date', () {
    test('rejects date far in the future', () {
      final futureDate = DateTime.now().add(const Duration(days: 365));
      expect(() => makeEntity(date: futureDate), throwsA(isA<ArgumentError>()));
    });

    test('allows past dates', () {
      final pastDate = DateTime(2020, 1, 1);
      final entity = makeEntity(date: pastDate);
      expect(entity.date, pastDate);
    });

    test('allows very old dates', () {
      final oldDate = DateTime(2000, 6, 15);
      final entity = makeEntity(date: oldDate);
      expect(entity.date, oldDate);
    });
  });

  // ===========================================================================
  // COMPUTED PROPERTIES
  // ===========================================================================

  group('Computed properties', () {
    test('signedAmount is negative for expenses', () {
      final entity = makeEntity(amount: 250.0, type: TransactionType.expense);
      expect(entity.signedAmount, -250.0);
    });

    test('signedAmount is positive for income', () {
      final entity = makeEntity(amount: 5000.0, type: TransactionType.income);
      expect(entity.signedAmount, 5000.0);
    });

    test('isExpense returns true for expense type', () {
      final entity = makeEntity(type: TransactionType.expense);
      expect(entity.isExpense, isTrue);
      expect(entity.isIncome, isFalse);
    });

    test('isIncome returns true for income type', () {
      final entity = makeEntity(type: TransactionType.income);
      expect(entity.isIncome, isTrue);
      expect(entity.isExpense, isFalse);
    });
  });

  // ===========================================================================
  // EQUALITY
  // ===========================================================================

  group('Equality', () {
    test('entities with same id are equal', () {
      final a = makeEntity(id: 'same-id', amount: 100);
      final b = makeEntity(id: 'same-id', amount: 999);
      expect(a, equals(b));
    });

    test('entities with different ids are not equal', () {
      final a = makeEntity(id: 'id-1');
      final b = makeEntity(id: 'id-2');
      expect(a, isNot(equals(b)));
    });

    test('same id produces same hashCode', () {
      final a = makeEntity(id: 'hash-test');
      final b = makeEntity(id: 'hash-test');
      expect(a.hashCode, equals(b.hashCode));
    });

    test('entity equals itself (identity)', () {
      final entity = makeEntity();
      expect(entity, equals(entity));
    });

    test('entity is not equal to non-entity objects', () {
      final entity = makeEntity();
      // ignore: unrelated_type_equality_checks
      expect(entity == 'not an entity', isFalse);
    });

    test('can be used in a Set (deduplication by id)', () {
      final a = makeEntity(id: 'dup-id', amount: 100);
      final b = makeEntity(id: 'dup-id', amount: 200);
      final c = makeEntity(id: 'other-id');
      final set = {a, b, c};
      expect(set.length, 2); // a and b collapse into one
    });
  });

  // ===========================================================================
  // COPY WITH
  // ===========================================================================

  group('copyWith', () {
    test('creates a new instance with updated amount', () {
      final original = makeEntity(amount: 100);
      final updated = original.copyWith(amount: 200);
      expect(updated.amount, 200);
      expect(original.amount, 100); // original unchanged
    });

    test('preserves all other fields when updating one', () {
      final original = makeEntity(
        id: 'copy-test',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'food-id',
        description: 'Original',
      );
      final updated = original.copyWith(description: 'Updated');

      expect(updated.id, original.id);
      expect(updated.amount, original.amount);
      expect(updated.type, original.type);
      expect(updated.categoryId, original.categoryId);
      expect(updated.description, 'Updated');
      expect(updated.date, original.date);
      expect(updated.createdAt, original.createdAt);
    });

    test('validates the new copy (rejects invalid amount)', () {
      final original = makeEntity(amount: 100);
      expect(
        () => original.copyWith(amount: -50),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('can change type from expense to income', () {
      final expense = makeEntity(type: TransactionType.expense);
      final income = expense.copyWith(type: TransactionType.income);
      expect(income.isIncome, isTrue);
      expect(expense.isExpense, isTrue); // original unchanged
    });
  });

  // ===========================================================================
  // TO STRING
  // ===========================================================================

  group('toString', () {
    test('includes key fields in output', () {
      final entity = makeEntity(
        id: 'str-test',
        amount: 42.5,
        type: TransactionType.expense,
      );
      final str = entity.toString();
      expect(str, contains('str-test'));
      expect(str, contains('42.5'));
      expect(str, contains('Expense'));
    });
  });
}
