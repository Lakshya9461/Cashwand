import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/data/database/transaction_dao.dart';
import 'package:expense_tracker/data/database/budget_dao.dart';
import 'package:expense_tracker/data/repositories/transaction_repository.dart';
import 'package:expense_tracker/data/repositories/budget_repository.dart';
import 'package:expense_tracker/data/repositories/web_transaction_repository.dart';
import 'package:expense_tracker/data/repositories/web_budget_repository.dart';
import 'package:expense_tracker/data/repositories/web_profile_repository.dart';
import 'package:expense_tracker/data/database/profile_dao.dart';
import 'package:expense_tracker/data/repositories/profile_repository.dart';
import 'package:expense_tracker/domain/repositories/i_profile_repository.dart';
import 'package:expense_tracker/domain/repositories/i_transaction_repository.dart';
import 'package:expense_tracker/domain/repositories/i_budget_repository.dart';
import 'package:expense_tracker/domain/repositories/i_category_repository.dart';
import 'package:expense_tracker/domain/repositories/i_account_repository.dart';

// DAOs & Repositories
import 'package:expense_tracker/data/database/category_dao.dart';
import 'package:expense_tracker/data/repositories/category_repository.dart';
import 'package:expense_tracker/data/repositories/web_category_repository.dart';
import 'package:expense_tracker/data/database/account_dao.dart';
import 'package:expense_tracker/data/repositories/account_repository.dart';
import 'package:expense_tracker/data/repositories/web_account_repository.dart';
import 'package:expense_tracker/data/repositories/web_recurring_transaction_repository.dart';
import 'package:expense_tracker/domain/repositories/i_recurring_transaction_repository.dart';

// Providers
import 'package:expense_tracker/presentation/providers/profile_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/budget_provider.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/account_provider.dart';
import 'package:expense_tracker/presentation/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait only — finance UIs are designed for vertical layout
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Wire up dependencies based on platform
  late final ITransactionRepository transactionRepo;
  late final IBudgetRepository budgetRepo;
  late final IProfileRepository profileRepo;
  late final ICategoryRepository categoryRepo;
  late final IAccountRepository accountRepo;
  late final IRecurringTransactionRepository recurringRepo;

  if (kIsWeb) {
    transactionRepo = WebTransactionRepository();
    budgetRepo = WebBudgetRepository();
    profileRepo = WebProfileRepository();
    categoryRepo = WebCategoryRepository();
    accountRepo = WebAccountRepository();
    recurringRepo = WebRecurringTransactionRepository();
  } else {
    final dao = TransactionDao();
    final budgetDao = BudgetDao();
    final profileDao = ProfileDao();
    final categoryDao = CategoryDao();
    final accountDao = AccountDao();

    transactionRepo = TransactionRepository(dao: dao);
    budgetRepo = BudgetRepository(dao: budgetDao);
    profileRepo = ProfileRepository(dao: profileDao);
    categoryRepo = CategoryRepository(dao: categoryDao);
    accountRepo = AccountRepository(dao: accountDao);
    // For now, use web repo for recurring on all platforms (MVP simplicity)
    recurringRepo = WebRecurringTransactionRepository();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileRepo)..loadProfiles(),
        ),
        ChangeNotifierProxyProvider<ProfileProvider, TransactionProvider>(
          create: (_) =>
              TransactionProvider(transactionRepo)..loadTransactions(),
          update: (_, profileProvider, txProvider) {
            final activeId = profileProvider.activeProfileId;
            if (transactionRepo.activeProfileId != activeId) {
              transactionRepo.setActiveProfile(activeId);
              txProvider?.loadTransactions();
            }
            return txProvider ?? TransactionProvider(transactionRepo);
          },
        ),
        ChangeNotifierProxyProvider<ProfileProvider, CategoryProvider>(
          create: (_) => CategoryProvider(categoryRepo)..loadCategories(),
          update: (_, profileProvider, catProvider) {
            final activeId = profileProvider.activeProfileId;
            if (categoryRepo.activeProfileId != activeId) {
              categoryRepo.setActiveProfile(activeId);
              catProvider?.loadCategories();
            }
            return catProvider ?? CategoryProvider(categoryRepo);
          },
        ),
        ChangeNotifierProxyProvider<ProfileProvider, AccountProvider>(
          create: (_) => AccountProvider(accountRepo)..loadAccounts(),
          update: (_, profileProvider, accProvider) {
            final activeId = profileProvider.activeProfileId;
            if (accountRepo.activeProfileId != activeId) {
              accountRepo.setActiveProfile(activeId);
              accProvider?.loadAccounts();
            }
            return accProvider ?? AccountProvider(accountRepo);
          },
        ),
        ChangeNotifierProxyProvider<ProfileProvider, BudgetProvider>(
          create: (_) => BudgetProvider(budgetRepo),
          update: (_, profileProvider, budgetProvider) {
            final activeId = profileProvider.activeProfileId;
            if (budgetRepo.activeProfileId != activeId) {
              budgetRepo.setActiveProfile(activeId);
              // BudgetProvider naturally reactively updates when its methods are called,
              // but we might want to refresh the active month if it stores state.
              // For now, setting activeProfileId on the repo is enough.
            }
            return budgetProvider ?? BudgetProvider(budgetRepo);
          },
        ),
        ChangeNotifierProxyProvider<
          ProfileProvider,
          RecurringTransactionProvider
        >(
          create: (_) =>
              RecurringTransactionProvider(recurringRepo, transactionRepo)
                ..loadItems(),
          update: (_, profileProvider, recProvider) {
            final activeId = profileProvider.activeProfileId;
            if (recurringRepo.activeProfileId != activeId) {
              recurringRepo.setActiveProfile(activeId);
              recProvider?.loadItems();
            }
            return recProvider ??
                RecurringTransactionProvider(recurringRepo, transactionRepo);
          },
        ),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const App(),
    ),
  );
}
