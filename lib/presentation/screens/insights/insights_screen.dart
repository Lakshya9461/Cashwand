import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/extensions/category_entity_extensions.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';

/// Analytics screen showing spending breakdown by category.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spending Insights'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Current Month'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            return TabBarView(
              children: [
                _buildCurrentMonthTab(context, provider),
                _buildTrendsTab(context, provider),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentMonthTab(
    BuildContext context,
    TransactionProvider provider,
  ) {
    final breakdown = provider.categoryBreakdown;
    final catProvider = context.watch<CategoryProvider>();

    if (breakdown.isEmpty) {
      return const EmptyState(
        icon: Icons.pie_chart_rounded,
        title: 'No data to analyze',
        subtitle: 'Add some expenses to see your breakdown',
      );
    }

    final totalSpending = breakdown.values.fold(0.0, (sum, val) => sum + val);

    // Sort breakdown by amount descending
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donut Chart with Total in Center
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    sections: sortedEntries.map((entry) {
                      final categoryId = entry.key;
                      final category = catProvider.getById(categoryId);
                      final catColor =
                          category?.colorValue ?? AppColors.primary;
                      final amount = entry.value;
                      final percentage = (amount / totalSpending) * 100;

                      return PieChartSectionData(
                        color: catColor,
                        value: amount,
                        title: percentage >= 5
                            ? '${percentage.toStringAsFixed(0)}%'
                            : '',
                        radius: 30, // thinner ring for donut
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Total Spent',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(totalSpending),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            'Top Categories',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Legend List grouped in a Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: sortedEntries.map((entry) {
                final category = catProvider.getById(entry.key);
                final catColor = category?.colorValue ?? AppColors.primary;
                final catLabel = category?.name ?? 'Unknown';

                return _CategorySpendingRow(
                  color: catColor,
                  label: catLabel,
                  amount: entry.value,
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            'Income vs Expense',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildIncomeExpenseChart(
              provider.monthlyIncome,
              provider.monthlyExpense,
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            'Daily Spending',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.only(
              left: 4,
              right: 16,
              top: 24,
              bottom: 16,
            ),
            height: 250,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildDailySpendingChart(provider.dailyExpenseBreakdown),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(BuildContext context, TransactionProvider provider) {
    final trendsData = provider.last6MonthsTrend;
    if (trendsData.isEmpty ||
        trendsData.values.every((v) => v['income'] == 0 && v['expense'] == 0)) {
      return const EmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No trend data yet',
        subtitle: 'Keep adding transactions to see your 6-month trends.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '6-Month Cash Flow',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Compare your income and expenses over the last 6 months.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.only(
              left: 4,
              right: 16,
              top: 24,
              bottom: 16,
            ),
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _buildSixMonthTrendChart(trendsData),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeExpenseChart(double income, double expense) {
    if (income == 0 && expense == 0) {
      return const Center(
        child: Text(
          'No data',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxY = income > expense ? income : expense;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceEvenly,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(enabled: false), // simplify for now
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: AppColors.income,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  case 1:
                    return const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
              reservedSize: 32,
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: income,
                color: AppColors.income,
                width: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: expense,
                color: AppColors.expense,
                width: 40,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailySpendingChart(Map<int, double> dailyData) {
    if (dailyData.isEmpty) {
      return const Center(
        child: Text(
          'No daily expenses yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final maxY = dailyData.values.reduce((a, b) => a > b ? a : b);
    final now = DateTime.now();

    List<BarChartGroupData> barGroups = [];
    for (int i = 1; i <= now.day; i++) {
      final amount = dailyData[i] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: amount,
              color: AppColors.expense.withValues(alpha: 0.8),
              width: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(enabled: false), // simplify interaction
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY / 3).ceilToDouble() : 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final day = value.toInt();
                if (day == 1 || day == now.day || day % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      day.toString(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == maxY * 1.2) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _compactFormat(value),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  String _compactFormat(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}m';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildSixMonthTrendChart(Map<String, Map<String, double>> trendsData) {
    final entries = trendsData.entries.toList();
    // find max
    var maxY = 0.0;
    for (var v in trendsData.values) {
      if ((v['income'] ?? 0) > maxY) maxY = v['income']!;
      if ((v['expense'] ?? 0) > maxY) maxY = v['expense']!;
    }

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceLight,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isIncome = rodIndex == 0;
              final label = isIncome ? 'Income' : 'Expense';
              return BarTooltipItem(
                '$label\n${CurrencyFormatter.format(rod.toY)}',
                TextStyle(
                  color: isIncome ? AppColors.income : AppColors.expense,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? (maxY / 4).ceilToDouble() : 100,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }
                // "2025-10" -> "Oct"
                final parts = entries[index].key.split('-');
                if (parts.length == 2) {
                  final monthInt = int.tryParse(parts[1]);
                  if (monthInt != null && monthInt >= 1 && monthInt <= 12) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        monthNames[monthInt - 1],
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == maxY * 1.2) {
                  return const SizedBox.shrink();
                }
                return Text(
                  _compactFormat(value),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((e) {
          final i = e.key;
          final valueMap = e.value.value;
          final income = valueMap['income'] ?? 0;
          final expense = valueMap['expense'] ?? 0;

          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: income,
                color: AppColors.income,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: expense,
                color: AppColors.expense,
                width: 10,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CategorySpendingRow extends StatelessWidget {
  final Color color;
  final String label;
  final double amount;

  const _CategorySpendingRow({
    required this.color,
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
