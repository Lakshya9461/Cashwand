import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:expense_tracker/presentation/screens/add_transaction/add_transaction_screen.dart';
import 'package:expense_tracker/presentation/screens/history/history_screen.dart';
import 'package:expense_tracker/presentation/screens/insights/insights_screen.dart';
import 'package:expense_tracker/presentation/screens/budget/budget_settings_screen.dart';
import 'package:expense_tracker/presentation/screens/settings/settings_screen.dart';
import 'package:expense_tracker/presentation/screens/settings/about_screen.dart';
import 'package:expense_tracker/presentation/screens/settings/profile_manager_screen.dart';
import 'package:expense_tracker/presentation/screens/auth/lock_screen.dart';
import 'package:expense_tracker/presentation/screens/auth/set_pin_screen.dart';
import 'package:expense_tracker/presentation/screens/manager/category_manager_screen.dart';
import 'package:expense_tracker/presentation/screens/manager/account_manager_screen.dart';
import 'package:expense_tracker/presentation/screens/recurring/recurring_transactions_screen.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';

/// App navigation configuration using go_router.
///
/// Three routes for MVP:
/// - `/` → Dashboard (home)
/// - `/add` → Add Transaction form
/// - `/history` → Full transaction history
class AppRouter {
  AppRouter._();

  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isChecking) return null;

        final isLocked =
            authProvider.isAppLockEnabled && !authProvider.isAuthenticated;
        final isGoingToLock = state.matchedLocation == '/lock';

        if (isLocked && !isGoingToLock) {
          return '/lock';
        }
        if (!isLocked && isGoingToLock) {
          return '/';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/lock', builder: (context, state) => const LockScreen()),
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/add',
          pageBuilder: (context, state) {
            final transaction = state.extra as TransactionEntity?;
            return CustomTransitionPage(
              child: AddTransactionScreen(transaction: transaction),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: child,
                    );
                  },
            );
          },
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/insights',
          builder: (context, state) => const InsightsScreen(),
        ),
        GoRoute(
          path: '/budgets',
          builder: (context, state) => const BudgetSettingsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/set-pin',
          builder: (context, state) => const SetPinScreen(),
        ),
        GoRoute(
          path: '/profile-manager',
          builder: (context, state) => const ProfileManagerScreen(),
        ),
        GoRoute(
          path: '/category-manager',
          builder: (context, state) => const CategoryManagerScreen(),
        ),
        GoRoute(
          path: '/account-manager',
          builder: (context, state) => const AccountManagerScreen(),
        ),
        GoRoute(
          path: '/recurring',
          builder: (context, state) => const RecurringTransactionsScreen(),
        ),
      ],
    );
  }
}
