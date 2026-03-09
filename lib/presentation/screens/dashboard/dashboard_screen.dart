import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/budget_provider.dart';
import 'package:expense_tracker/presentation/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker/shared/widgets/balance_card.dart';
import 'package:expense_tracker/shared/widgets/budget_progress_card.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/transaction_list_item.dart';
import 'package:expense_tracker/shared/widgets/profile_switcher.dart';

/// Main dashboard — the first screen users see.
///
/// Designed for glanceable finance: users should understand their
/// financial position within 2 seconds of opening the app.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load transactions, budgets, and trigger recurring logic on first build
    Future.microtask(() async {
      if (!mounted) return;
      context.read<TransactionProvider>().loadTransactions();
      context.read<BudgetProvider>().loadBudgets();

      final recurringProvider = context.read<RecurringTransactionProvider>();
      await recurringProvider.loadItems();
      await recurringProvider.processDueTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ProfileSwitcher(),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.pie_chart_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => context.push('/insights'),
            tooltip: 'Spending Insights',
          ),
          IconButton(
            icon: const Icon(
              Icons.history_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => context.push('/history'),
            tooltip: 'Transaction History',
          ),
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.expense,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadTransactions(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTransactions(),
            color: AppColors.primary,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Balance Card - Listens only to balance and totals
                Selector<TransactionProvider, _BalanceState>(
                  selector: (_, p) => _BalanceState(
                    p.currentBalance,
                    p.monthlyIncome,
                    p.monthlyExpense,
                  ),
                  builder: (context, state, _) {
                    return BalanceCard(
                      balance: state.balance,
                      monthlyIncome: state.income,
                      monthlyExpense: state.expense,
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Overall Budget Progress (if exists)
                Consumer2<BudgetProvider, TransactionProvider>(
                  builder: (context, budgetProvider, txProvider, _) {
                    final overallBudget = budgetProvider.overallBudget;
                    if (overallBudget == null) {
                      return GestureDetector(
                        onTap: () => context.push('/budgets'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              '+ Set a Monthly Budget',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final status = budgetProvider.computeStatus(
                      overallBudget,
                      txProvider.monthlyExpense,
                    );
                    return GestureDetector(
                      onTap: () => context.push('/budgets'),
                      child: BudgetProgressCard(status: status),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Selector<TransactionProvider, int>(
                      selector: (_, p) => p.transactions.length,
                      builder: (context, count, _) {
                        if (count <= 5) return const SizedBox.shrink();
                        return TextButton(
                          onPressed: () => context.push('/history'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Transaction List or Empty State
                Selector<TransactionProvider, List<TransactionEntity>>(
                  selector: (_, p) => p.recentTransactions,
                  builder: (context, recent, _) {
                    if (recent.isEmpty) return const EmptyState();
                    return Column(
                      children: recent
                          .map(
                            (t) => TransactionListItem(
                              transaction: t,
                              onTap: () => context.push('/add', extra: t),
                              onDismissed: () => context
                                  .read<TransactionProvider>()
                                  .deleteTransaction(t.id),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: Selector<TransactionProvider, double>(
        selector: (_, p) => p.currentBalance,
        builder: (context, balance, _) {
          return FloatingActionButton.extended(
            onPressed: () => context.push('/add'),
            backgroundColor: balance < 0
                ? AppColors.expense
                : AppColors.primary,
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Add',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}

/// Helper class for [DashboardScreen] to select balance state.
class _BalanceState {
  final double balance;
  final double income;
  final double expense;

  _BalanceState(this.balance, this.income, this.expense);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BalanceState &&
          runtimeType == other.runtimeType &&
          balance == other.balance &&
          income == other.income &&
          expense == other.expense;

  @override
  int get hashCode => balance.hashCode ^ income.hashCode ^ expense.hashCode;
}
