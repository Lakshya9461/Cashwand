import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';

import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/budget_provider.dart';
import 'package:expense_tracker/domain/entities/budget_entity.dart';
import 'package:expense_tracker/domain/repositories/i_budget_repository.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/domain/entities/profile_entity.dart';
import 'package:expense_tracker/domain/repositories/i_profile_repository.dart';
import 'package:expense_tracker/presentation/providers/profile_provider.dart';

class FakeProfileRepository implements IProfileRepository {
  @override
  Future<void> delete(String id) async {}
  @override
  Future<List<ProfileEntity>> getAll() async => [
    ProfileEntity(id: 'default', name: 'Personal', isDefault: true),
  ];
  @override
  Future<ProfileEntity?> getById(String id) async => null;
  @override
  Future<void> insert(ProfileEntity profile) async {}
  @override
  Future<void> update(ProfileEntity profile) async {}
}

class FakeTransactionRepository implements ITransactionRepository {
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  @override
  Future<void> insert(TransactionEntity transaction) async {}
  @override
  Future<List<TransactionEntity>> getAll() async => [];
  @override
  Future<TransactionEntity?> getById(String id) async => null;
  @override
  Future<List<TransactionEntity>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async => [];
  @override
  Future<List<TransactionEntity>> getByCategory(String categoryId) async => [];
  @override
  Future<void> update(TransactionEntity transaction) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> deleteAll() async {}
  @override
  Future<Map<String, double>> getMonthlySummary(int year, int month) async => {
    'income': 0.0,
    'expense': 0.0,
  };
}

class FakeBudgetRepository implements IBudgetRepository {
  String _activeProfileId = 'default';

  @override
  String get activeProfileId => _activeProfileId;

  @override
  void setActiveProfile(String profileId) {
    _activeProfileId = profileId;
  }

  @override
  Future<void> upsert(BudgetEntity budget) async {}
  @override
  Future<List<BudgetEntity>> getForMonth(int year, int month) async => [];
  @override
  Future<BudgetEntity?> getOverallBudget(int year, int month) async => null;
  @override
  Future<BudgetEntity?> getCategoryBudget(
    String categoryId,
    int year,
    int month,
  ) async => null;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> deleteAll() async {}
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'app_lock_enabled': false});

    final repository = FakeTransactionRepository();
    final budgetRepo = FakeBudgetRepository();
    final profileRepo = FakeProfileRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ProfileProvider(profileRepo)..loadProfiles(),
          ),
          ChangeNotifierProxyProvider<ProfileProvider, TransactionProvider>(
            create: (_) => TransactionProvider(repository),
            update: (_, profileProvider, txProvider) {
              final activeId = profileProvider.activeProfileId;
              if (repository.activeProfileId != activeId) {
                repository.setActiveProfile(activeId);
                txProvider?.loadTransactions();
              }
              return txProvider ?? TransactionProvider(repository);
            },
          ),
          ChangeNotifierProxyProvider<ProfileProvider, BudgetProvider>(
            create: (_) => BudgetProvider(budgetRepo),
            update: (_, profileProvider, budgetProvider) {
              final activeId = profileProvider.activeProfileId;
              if (budgetRepo.activeProfileId != activeId) {
                budgetRepo.setActiveProfile(activeId);
              }
              return budgetProvider ?? BudgetProvider(budgetRepo);
            },
          ),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const App(),
      ),
    );

    // Verify that Dashboard is shown
    expect(find.text('CashWand'), findsOneWidget);
    await tester.pumpAndSettle(); // Allow async list loading
    expect(find.text('No transactions yet'), findsOneWidget);
  });
}
