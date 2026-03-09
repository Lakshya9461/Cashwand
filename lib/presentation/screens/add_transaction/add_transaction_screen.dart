import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/presentation/providers/account_provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/extensions/category_entity_extensions.dart';
import 'package:expense_tracker/core/extensions/account_entity_extensions.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';

/// Add Transaction form — designed for <5 second entry.
///
/// UX optimizations:
/// - Amount input is auto-focused (most important field)
/// - Type toggle is prominent (income/expense)
/// - Categories shown as a scrollable chip grid
/// - Date defaults to today (most common case)
/// - Save button is always visible
class AddTransactionScreen extends StatefulWidget {
  final TransactionEntity? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  TransactionType _type = TransactionType.expense;
  String? _categoryId;
  String? _accountId;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      final t = widget.transaction!;
      _amountController.text = t.amount.toString();
      _descController.text = t.description;
      _type = t.type;
      _categoryId = t.type == TransactionType.expense ? t.categoryId : null;
      _accountId = t.accountId;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final isEdit = widget.transaction != null;
    final entity = TransactionEntity(
      id: isEdit ? widget.transaction!.id : const Uuid().v4(),
      amount: double.parse(_amountController.text),
      type: _type,
      categoryId: _type == TransactionType.income
          ? 'salary'
          : (_categoryId ?? 'other'), // Fixed ID mapping
      accountId: _accountId,
      description: _descController.text.trim(),
      date: _date,
      createdAt: isEdit ? widget.transaction!.createdAt : DateTime.now(),
    );

    final provider = context.read<TransactionProvider>();
    if (isEdit) {
      await provider.updateTransaction(entity);
    } else {
      await provider.addTransaction(entity);
    }

    HapticFeedback.lightImpact();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.transaction != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Type Toggle
            _buildTypeToggle(),
            const SizedBox(height: 24),

            // Amount Input
            _buildAmountInput(),
            const SizedBox(height: 20),

            // Category Selector (only for expense)
            if (_type == TransactionType.expense) ...[
              _buildCategorySection(),
              const SizedBox(height: 20),
            ],

            // Account Selector (for both income and expense)
            _buildAccountSection(),
            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                prefixIcon: Icon(
                  Icons.notes_rounded,
                  color: AppColors.textMuted,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              maxLength: 100,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Date Picker
            _buildDatePicker(),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Text(
                        isEdit ? 'Save Changes' : 'Save Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: TransactionType.values.map((type) {
          final isSelected = _type == type;
          final color = type == TransactionType.income
              ? AppColors.income
              : AppColors.expense;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                _type = type;
                _categoryId = null; // Reset selection on type change
                _accountId = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: color.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type == TransactionType.income
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: isSelected ? color : AppColors.textMuted,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.label,
                      style: TextStyle(
                        color: isSelected ? color : AppColors.textMuted,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      autofocus: true,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(
          color: AppColors.textMuted.withValues(alpha: 0.5),
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        prefixText: '₹ ',
        prefixStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Enter an amount';
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Amount must be greater than 0';
        }
        if (amount > 10000000) return 'Amount too large';
        return null;
      },
    );
  }

  Widget _buildCategorySection() {
    final catProvider = context.watch<CategoryProvider>();
    final categories = catProvider.categories;
    // Optionally filter based on _type, assuming we add a type matching field to categories later or just show all for MVP

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _categoryId == cat.id;
            return GestureDetector(
              onTap: () => setState(() => _categoryId = cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.colorValue.withValues(alpha: 0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(color: cat.colorValue.withValues(alpha: 0.4))
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.iconData,
                      size: 18,
                      color: isSelected ? cat.colorValue : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: isSelected
                            ? cat.colorValue
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (categories.isEmpty && catProvider.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (categories.isEmpty && !catProvider.isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              catProvider.error ?? 'No categories available for this profile.',
              style: const TextStyle(color: AppColors.expense),
            ),
          ),
      ],
    );
  }

  Widget _buildAccountSection() {
    final accounts = context.watch<AccountProvider>().accounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _type == TransactionType.income ? 'Income Account' : 'Paid From',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: accounts.map((acc) {
            final isSelected = _accountId == acc.id;
            return GestureDetector(
              onTap: () => setState(() => _accountId = acc.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      acc.iconData,
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      acc.name,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    final isToday = DateTime.now().difference(_date).inDays == 0;
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              isToday ? 'Today' : '${_date.day}/${_date.month}/${_date.year}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
