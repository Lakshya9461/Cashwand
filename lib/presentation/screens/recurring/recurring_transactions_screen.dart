import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/extensions/category_entity_extensions.dart';
import 'package:expense_tracker/domain/entities/recurring_transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/domain/enums/recurrence_frequency.dart';
import 'package:expense_tracker/presentation/providers/recurring_transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/account_provider.dart';
import 'package:expense_tracker/presentation/providers/profile_provider.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';

class RecurringTransactionsScreen extends StatelessWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecurringTransactionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring'),
        actions: [
          if (provider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              tooltip: 'Process due now',
              onPressed: () async {
                final count = await provider.processDueTransactions();
                if (context.mounted) {
                  if (count > 0) {
                    context.read<TransactionProvider>().loadTransactions();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        count > 0
                            ? '$count transaction(s) generated!'
                            : 'Nothing due yet.',
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.items.isEmpty
          ? _buildEmptyState()
          : _buildList(context, provider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddModal(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Recurring'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat_rounded, size: 64, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'No recurring transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Set up auto-tracked rent,\nsubscriptions, or salary.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    RecurringTransactionProvider provider,
  ) {
    final catProvider = context.watch<CategoryProvider>();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        final item = provider.items[index];

        // Look up category
        final category = catProvider.categories
            .where((c) => c.id == item.categoryId)
            .firstOrNull;

        final color = item.type == TransactionType.income
            ? AppColors.income
            : AppColors.expense;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: !item.isActive
                ? Border.all(color: AppColors.textMuted.withValues(alpha: 0.3))
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(
                item.type == TransactionType.income
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                color: color,
              ),
            ),
            title: Text(
              item.description.isNotEmpty
                  ? item.description
                  : (category?.name ?? item.categoryId),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: item.isActive
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                decoration: item.isActive ? null : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${item.frequency.label} · Next: ${_formatDate(item.nextDueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: item.isDue
                        ? AppColors.expense
                        : AppColors.textSecondary,
                    fontWeight: item.isDue
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  CurrencyFormatter.format(item.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(item.isActive ? 'Pause' : 'Resume'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.expense),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'toggle') {
                      provider.toggleActive(item.id, !item.isActive);
                    } else if (value == 'delete') {
                      _confirmDelete(context, item, provider);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
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
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _confirmDelete(
    BuildContext context,
    RecurringTransactionEntity item,
    RecurringTransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring?'),
        content: Text(
          'Remove "${item.description.isNotEmpty ? item.description : "this item"}"? Past generated transactions will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteItem(item.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddRecurringModal(),
    );
  }
}

// ---------------------------------------------------------------------------
// Add Recurring Modal
// ---------------------------------------------------------------------------

class _AddRecurringModal extends StatefulWidget {
  const _AddRecurringModal();

  @override
  State<_AddRecurringModal> createState() => _AddRecurringModalState();
}

class _AddRecurringModalState extends State<_AddRecurringModal> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  String? _categoryId;
  String? _accountId;
  DateTime _startDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final categories = context.watch<CategoryProvider>().categories;
    final accounts = context.watch<AccountProvider>().accounts;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Recurring Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Type toggle
            Row(
              children: TransactionType.values.map((t) {
                final selected = _type == t;
                final color = t == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: t == TransactionType.income ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _type = t;
                        _categoryId = null;
                        _accountId = null;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.15)
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: color.withValues(alpha: 0.4))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            t.label,
                            style: TextStyle(
                              color: selected ? color : AppColors.textMuted,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Amount
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Netflix, Rent, Salary',
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Frequency
            const Text(
              'Frequency',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: RecurrenceFrequency.values.map((f) {
                final selected = _frequency == f;
                return ChoiceChip(
                  label: Text(f.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _frequency = f),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Category (expense only)
            if (_type == TransactionType.expense) ...[
              const Text(
                'Category',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final selected = _categoryId == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _categoryId = cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? cat.colorValue.withValues(alpha: 0.15)
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: selected
                            ? Border.all(
                                color: cat.colorValue.withValues(alpha: 0.4),
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat.iconData,
                            size: 16,
                            color: selected
                                ? cat.colorValue
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: selected
                                  ? cat.colorValue
                                  : AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Account (income only)
            if (_type == TransactionType.income) ...[
              const Text(
                'Account',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: accounts.map((acc) {
                  final selected = _accountId == acc.id;
                  return ChoiceChip(
                    label: Text(acc.name),
                    selected: selected,
                    onSelected: (_) => setState(() => _accountId = acc.id),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Start date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primary,
              ),
              title: Text(
                'Starts: ${_formatDate(_startDate)}',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Recurring',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      '',
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
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  void _save() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) return;

    final profileId = context.read<ProfileProvider>().activeProfileId;
    final provider = context.read<RecurringTransactionProvider>();

    final entity = RecurringTransactionEntity(
      id: const Uuid().v4(),
      profileId: profileId,
      amount: amount,
      type: _type,
      categoryId: _type == TransactionType.income
          ? 'salary'
          : (_categoryId ?? 'other'),
      accountId: _type == TransactionType.income ? _accountId : null,
      description: _descController.text.trim(),
      frequency: _frequency,
      startDate: _startDate,
      nextDueDate: _startDate,
    );

    provider.addItem(entity).then((_) async {
      final generated = await provider.processDueTransactions();
      // Wait for any needed build ticks to clear so as not to trigger rebuild warnings
      if (generated > 0) {
        Future.microtask(() {
          // ignore: use_build_context_synchronously
          if (context.mounted)
            context.read<TransactionProvider>().loadTransactions();
        });
      }
    });

    Navigator.pop(context);
  }
}
