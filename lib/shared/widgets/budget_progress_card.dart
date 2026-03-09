import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/budget_provider.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';

class BudgetProgressCard extends StatelessWidget {
  final BudgetStatus status;

  const BudgetProgressCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.isOverBudget
        ? AppColors.expense
        : (status.isWarning ? Colors.orangeAccent : AppColors.primary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status.isOverBudget
              ? AppColors.expense.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${CurrencyFormatter.formatCompact(status.spent)} / ${CurrencyFormatter.formatCompact(status.limit)}',
                style: TextStyle(
                  color: status.isOverBudget
                      ? AppColors.expense
                      : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: status.percentage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (status.isWarning || status.isOverBudget) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  status.isOverBudget
                      ? Icons.error_outline
                      : Icons.warning_amber_rounded,
                  color: color,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  status.isOverBudget
                      ? 'Over budget by ${CurrencyFormatter.format(status.spent - status.limit)}'
                      : '${CurrencyFormatter.formatCompact(status.remaining)} remaining',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
