import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/models/transaction_model.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Test fixtures
  // ---------------------------------------------------------------------------

  final testDate = DateTime(2026, 2, 25, 14, 30, 0);
  final testCreatedAt = DateTime(2026, 2, 25, 14, 30, 5);

  final sampleEntity = TransactionEntity(
    id: 'test-uuid-001',
    amount: 250.50,
    type: TransactionType.expense,
    categoryId: 'food',
    description: 'Lunch at cafeteria',
    date: testDate,
    createdAt: testCreatedAt,
  );

  final sampleMap = <String, dynamic>{
    'id': 'test-uuid-001',
    'amount': 250.50,
    'type': 'expense',
    'category': 'food',
    'account': null,
    'description': 'Lunch at cafeteria',
    'date': '2026-02-25T14:30:00.000',
    'created_at': '2026-02-25T14:30:05.000',
  };

  // ===========================================================================
  // fromEntity → toMap (Entity → SQLite)
  // ===========================================================================

  group('fromEntity', () {
    test('converts entity to model with correct field mapping', () {
      final model = TransactionModel.fromEntity(sampleEntity);

      expect(model.id, 'test-uuid-001');
      expect(model.amount, 250.50);
      expect(model.type, 'expense');
      expect(model.categoryId, 'food');
      expect(model.description, 'Lunch at cafeteria');
      expect(model.date, testDate.toIso8601String());
      expect(model.createdAt, testCreatedAt.toIso8601String());
    });

    test('serializes income type correctly', () {
      final incomeEntity = TransactionEntity(
        id: 'inc-001',
        amount: 5000,
        type: TransactionType.income,
        categoryId: 'salary',
        accountId: 'bank',
        date: testDate,
        createdAt: testCreatedAt,
      );
      final model = TransactionModel.fromEntity(incomeEntity);
      expect(model.type, 'income');
      expect(model.categoryId, 'salary');
      expect(model.accountId, 'bank');
    });

    test('serializes empty description', () {
      final entity = TransactionEntity(
        id: 'empty-desc',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'other',
        description: '',
        date: testDate,
        createdAt: testCreatedAt,
      );
      final model = TransactionModel.fromEntity(entity);
      expect(model.description, '');
    });
  });

  // ===========================================================================
  // toMap (Model → SQLite Map)
  // ===========================================================================

  group('toMap', () {
    test('produces correct SQLite column names', () {
      final model = TransactionModel.fromEntity(sampleEntity);
      final map = model.toMap();

      expect(map.containsKey('id'), isTrue);
      expect(map.containsKey('amount'), isTrue);
      expect(map.containsKey('type'), isTrue);
      expect(map.containsKey('category'), isTrue);
      expect(map.containsKey('account'), isTrue);
      expect(map.containsKey('description'), isTrue);
      expect(map.containsKey('date'), isTrue);
      expect(map.containsKey('created_at'), isTrue);
      expect(map.containsKey('profile_id'), isTrue);
      expect(map.length, 9);
    });

    test('stores dates as ISO 8601 strings', () {
      final model = TransactionModel.fromEntity(sampleEntity);
      final map = model.toMap();

      expect(map['date'], isA<String>());
      expect(map['created_at'], isA<String>());
      // Verify parsable
      expect(() => DateTime.parse(map['date'] as String), returnsNormally);
      expect(
        () => DateTime.parse(map['created_at'] as String),
        returnsNormally,
      );
    });

    test('stores enums as lowercase name strings', () {
      final model = TransactionModel.fromEntity(sampleEntity);
      final map = model.toMap();

      expect(map['type'], 'expense');
      expect(map['category'], 'food');
    });
  });

  // ===========================================================================
  // fromMap (SQLite Map → Model)
  // ===========================================================================

  group('fromMap', () {
    test('parses all fields correctly from SQLite row', () {
      final model = TransactionModel.fromMap(sampleMap);

      expect(model.id, 'test-uuid-001');
      expect(model.amount, 250.50);
      expect(model.type, 'expense');
      expect(model.categoryId, 'food');
      expect(model.accountId, isNull);
      expect(model.description, 'Lunch at cafeteria');
      expect(model.date, '2026-02-25T14:30:00.000');
      expect(model.createdAt, '2026-02-25T14:30:05.000');
    });

    test('handles null description (defaults to empty string)', () {
      final mapWithNullDesc = Map<String, dynamic>.from(sampleMap);
      mapWithNullDesc['description'] = null;

      final model = TransactionModel.fromMap(mapWithNullDesc);
      expect(model.description, '');
    });

    test('handles integer amount from SQLite (cast to double)', () {
      final mapWithIntAmount = Map<String, dynamic>.from(sampleMap);
      mapWithIntAmount['amount'] = 100; // SQLite may return int for .0 values

      final model = TransactionModel.fromMap(mapWithIntAmount);
      expect(model.amount, 100.0);
      expect(model.amount, isA<double>());
    });
  });

  // ===========================================================================
  // toEntity (Model → Domain Entity)
  // ===========================================================================

  group('toEntity', () {
    test('produces a valid TransactionEntity', () {
      final model = TransactionModel.fromMap(sampleMap);
      final entity = model.toEntity();

      expect(entity.id, 'test-uuid-001');
      expect(entity.amount, 250.50);
      expect(entity.type, TransactionType.expense);
      expect(entity.categoryId, 'food');
      expect(entity.accountId, isNull);
      expect(entity.description, 'Lunch at cafeteria');
      expect(entity.date.year, 2026);
      expect(entity.date.month, 2);
      expect(entity.date.day, 25);
    });

    test('resolves all Category types (stubbed test)', () {
      final map = Map<String, dynamic>.from(sampleMap);
      map['category'] = 'food';

      final model = TransactionModel.fromMap(map);
      final entity = model.toEntity();
      expect(entity.categoryId, 'food');
    });

    test('resolves all TransactionType enum values', () {
      for (final type in TransactionType.values) {
        final map = Map<String, dynamic>.from(sampleMap);
        map['type'] = type.name;

        final model = TransactionModel.fromMap(map);
        final entity = model.toEntity();
        expect(entity.type, type);
      }
    });

    test('throws on invalid enum name (corrupt data)', () {
      final badMap = Map<String, dynamic>.from(sampleMap);
      badMap['type'] = 'invalid_type';

      final model = TransactionModel.fromMap(badMap);
      expect(() => model.toEntity(), throwsArgumentError);
    });
  });

  // ===========================================================================
  // Round-trip: Entity → Model → Map → Model → Entity
  // ===========================================================================

  group('Round-trip conversion', () {
    test('entity survives full round-trip without data loss', () {
      // Entity → Model → Map → Model → Entity
      final model1 = TransactionModel.fromEntity(sampleEntity);
      final map = model1.toMap();
      final model2 = TransactionModel.fromMap(map);
      final roundTripped = model2.toEntity();

      expect(roundTripped.id, sampleEntity.id);
      expect(roundTripped.amount, sampleEntity.amount);
      expect(roundTripped.type, sampleEntity.type);
      expect(roundTripped.categoryId, sampleEntity.categoryId);
      expect(roundTripped.accountId, sampleEntity.accountId);
      expect(roundTripped.description, sampleEntity.description);
      // Date comparison — millisecond precision is preserved by ISO 8601
      expect(
        roundTripped.date.millisecondsSinceEpoch,
        sampleEntity.date.millisecondsSinceEpoch,
      );
      expect(
        roundTripped.createdAt.millisecondsSinceEpoch,
        sampleEntity.createdAt.millisecondsSinceEpoch,
      );
    });

    test('category id round-trips correctly', () {
      final entity = TransactionEntity(
        id: 'rt-category',
        amount: 100,
        type: TransactionType.expense,
        categoryId: 'custom-cat-id',
        date: testDate,
        createdAt: testCreatedAt,
      );
      final roundTripped = TransactionModel.fromMap(
        TransactionModel.fromEntity(entity).toMap(),
      ).toEntity();

      expect(roundTripped.categoryId, 'custom-cat-id');
    });
  });
}
