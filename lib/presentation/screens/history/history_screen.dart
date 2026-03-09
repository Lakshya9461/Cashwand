import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/domain/entities/transaction_entity.dart';
import 'package:expense_tracker/domain/enums/transaction_type.dart';
import 'package:expense_tracker/presentation/providers/transaction_provider.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/shared/widgets/empty_state.dart';
import 'package:expense_tracker/shared/widgets/transaction_list_item.dart';
import 'package:expense_tracker/shared/widgets/export_dialog.dart';

/// Full transaction history with search, filter, and sort.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  // Filters
  TransactionType? _typeFilter;
  String? _categoryFilter;
  DateTimeRange? _dateRange;
  _SortMode _sortMode = _SortMode.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionEntity> _applyFilters(List<TransactionEntity> all) {
    var filtered = List<TransactionEntity>.from(all);

    // Text search
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.description.toLowerCase().contains(query) ||
            t.categoryId.toLowerCase().contains(query) ||
            t.amount.toString().contains(query);
      }).toList();
    }

    // Type filter
    if (_typeFilter != null) {
      filtered = filtered.where((t) => t.type == _typeFilter).toList();
    }

    // Category filter
    if (_categoryFilter != null) {
      filtered = filtered
          .where((t) => t.categoryId == _categoryFilter)
          .toList();
    }

    // Date range filter
    if (_dateRange != null) {
      filtered = filtered.where((t) {
        final date = DateTime(t.date.year, t.date.month, t.date.day);
        final start = DateTime(
          _dateRange!.start.year,
          _dateRange!.start.month,
          _dateRange!.start.day,
        );
        final end = DateTime(
          _dateRange!.end.year,
          _dateRange!.end.month,
          _dateRange!.end.day,
        ).add(const Duration(days: 1));
        return !date.isBefore(start) && date.isBefore(end);
      }).toList();
    }

    // Sort
    switch (_sortMode) {
      case _SortMode.newest:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case _SortMode.oldest:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case _SortMode.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case _SortMode.lowestAmount:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return filtered;
  }

  bool get _hasActiveFilters =>
      _typeFilter != null ||
      _categoryFilter != null ||
      _dateRange != null ||
      _sortMode != _SortMode.newest;

  int get _activeFilterCount {
    int count = 0;
    if (_typeFilter != null) count++;
    if (_categoryFilter != null) count++;
    if (_dateRange != null) count++;
    if (_sortMode != _SortMode.newest) count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _typeFilter = null;
      _categoryFilter = null;
      _dateRange = null;
      _sortMode = _SortMode.newest;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.transactions.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No history yet',
              subtitle: 'Your transactions will appear here',
            );
          }

          final filtered = _applyFilters(provider.transactions);

          return Column(
            children: [
              // Active filter chips
              if (_hasActiveFilters || _searchController.text.isNotEmpty)
                _buildActiveFilterBar(
                  filtered.length,
                  provider.transactions.length,
                ),

              // Results
              Expanded(
                child: filtered.isEmpty
                    ? _buildNoResults()
                    : _buildTransactionList(filtered, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _showSearch
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search by description, amount...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            )
          : const Text('Transaction History'),
      actions: [
        // Search toggle
        IconButton(
          icon: Icon(
            _showSearch ? Icons.search_off_rounded : Icons.search_rounded,
            color: _showSearch ? AppColors.primary : AppColors.textSecondary,
          ),
          tooltip: 'Search',
          onPressed: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchController.clear();
            });
          },
        ),

        // Filter button
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(
                Icons.tune_rounded,
                color: AppColors.textSecondary,
              ),
              tooltip: 'Filters',
              onPressed: () => _showFilterSheet(context),
            ),
            if (_activeFilterCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$_activeFilterCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Export & Clear
        Consumer<TransactionProvider>(
          builder: (context, provider, _) {
            if (provider.transactions.isEmpty) return const SizedBox();
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.file_download_rounded),
                  color: AppColors.primary,
                  tooltip: 'Export',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppColors.surface,
                      isScrollControlled: true,
                      builder: (context) => const ExportDialog(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_rounded),
                  color: AppColors.expense,
                  tooltip: 'Clear All',
                  onPressed: () => _showClearConfirmation(context, provider),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActiveFilterBar(int showing, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          Icon(Icons.filter_list_rounded, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Showing $showing of $total',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _clearAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.expense.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.expense,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            'No matching transactions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.clear_all_rounded),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionEntity> filtered,
    TransactionProvider provider,
  ) {
    // Group by date header
    final groups = <String, List<TransactionEntity>>{};
    for (final t in filtered) {
      final key = _dateGroupKey(t.date);
      groups.putIfAbsent(key, () => []);
      groups[key]!.add(t);
    }

    final groupKeys = groups.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: groupKeys.length,
      itemBuilder: (context, groupIndex) {
        final dateKey = groupKeys[groupIndex];
        final items = groups[dateKey]!;
        final dayTotal = items.fold<double>(0, (s, t) => s + t.signedAmount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header with day total
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${dayTotal >= 0 ? '+' : ''}${CurrencyFormatter.format(dayTotal.abs())}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: dayTotal >= 0
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
            ...items.map(
              (transaction) => TransactionListItem(
                transaction: transaction,
                onTap: () {
                  context.push('/add', extra: transaction);
                },
                onDismissed: () {
                  HapticFeedback.mediumImpact();
                  final deleted = transaction;
                  provider.deleteTransaction(transaction.id);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transaction deleted'),
                      backgroundColor: AppColors.surface,
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: AppColors.primary,
                        onPressed: () => provider.addTransaction(deleted),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  String _dateGroupKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';

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

    if (date.year == now.year) {
      return '${date.day} ${months[date.month]}';
    }
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  // ---------------------------------------------------------------------------
  // Filter Bottom Sheet
  // ---------------------------------------------------------------------------

  void _showFilterSheet(BuildContext context) {
    final catProvider = context.read<CategoryProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters & Sort',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_hasActiveFilters)
                        TextButton(
                          onPressed: () {
                            setState(_clearAllFilters);
                            setSheetState(() {});
                          },
                          child: const Text(
                            'Reset All',
                            style: TextStyle(color: AppColors.expense),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- TYPE ----
                  const Text(
                    'TYPE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: _typeFilter == null,
                        onTap: () {
                          setState(() => _typeFilter = null);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'Expense',
                        selected: _typeFilter == TransactionType.expense,
                        color: AppColors.expense,
                        onTap: () {
                          setState(() => _typeFilter = TransactionType.expense);
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        label: 'Income',
                        selected: _typeFilter == TransactionType.income,
                        color: AppColors.income,
                        onTap: () {
                          setState(() => _typeFilter = TransactionType.income);
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- CATEGORY ----
                  const Text(
                    'CATEGORY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All',
                        selected: _categoryFilter == null,
                        onTap: () {
                          setState(() => _categoryFilter = null);
                          setSheetState(() {});
                        },
                      ),
                      ...catProvider.categories.map((cat) {
                        return _filterChip(
                          label: cat.name,
                          selected: _categoryFilter == cat.id,
                          onTap: () {
                            setState(() => _categoryFilter = cat.id);
                            setSheetState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- DATE RANGE ----
                  const Text(
                    'DATE RANGE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'All Time',
                        selected: _dateRange == null,
                        onTap: () {
                          setState(() => _dateRange = null);
                          setSheetState(() {});
                        },
                      ),
                      _filterChip(
                        label: 'Today',
                        selected: _isDatePreset('today'),
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            _dateRange = DateTimeRange(
                              start: DateTime(now.year, now.month, now.day),
                              end: DateTime(now.year, now.month, now.day),
                            );
                          });
                          setSheetState(() {});
                        },
                      ),
                      _filterChip(
                        label: 'This Week',
                        selected: _isDatePreset('week'),
                        onTap: () {
                          final now = DateTime.now();
                          final weekStart = now.subtract(
                            Duration(days: now.weekday - 1),
                          );
                          setState(() {
                            _dateRange = DateTimeRange(
                              start: DateTime(
                                weekStart.year,
                                weekStart.month,
                                weekStart.day,
                              ),
                              end: DateTime(now.year, now.month, now.day),
                            );
                          });
                          setSheetState(() {});
                        },
                      ),
                      _filterChip(
                        label: 'This Month',
                        selected: _isDatePreset('month'),
                        onTap: () {
                          final now = DateTime.now();
                          setState(() {
                            _dateRange = DateTimeRange(
                              start: DateTime(now.year, now.month, 1),
                              end: DateTime(now.year, now.month, now.day),
                            );
                          });
                          setSheetState(() {});
                        },
                      ),
                      _filterChip(
                        label: 'Custom...',
                        selected:
                            _dateRange != null &&
                            !_isDatePreset('today') &&
                            !_isDatePreset('week') &&
                            !_isDatePreset('month'),
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange: _dateRange,
                          );
                          if (picked != null) {
                            setState(() => _dateRange = picked);
                            setSheetState(() {});
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ---- SORT ----
                  const Text(
                    'SORT BY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _SortMode.values.map((mode) {
                      return _filterChip(
                        label: mode.label,
                        selected: _sortMode == mode,
                        onTap: () {
                          setState(() => _sortMode = mode);
                          setSheetState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isDatePreset(String preset) {
    if (_dateRange == null) return false;
    final now = DateTime.now();
    final start = _dateRange!.start;
    final end = _dateRange!.end;

    switch (preset) {
      case 'today':
        return start.day == now.day &&
            start.month == now.month &&
            start.year == now.year &&
            end.day == now.day;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return start.day == weekStart.day &&
            start.month == weekStart.month &&
            end.day == now.day;
      case 'month':
        return start.day == 1 &&
            start.month == now.month &&
            start.year == now.year &&
            end.day == now.day;
      default:
        return false;
    }
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: chipColor.withValues(alpha: 0.4))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? chipColor : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showClearConfirmation(
    BuildContext context,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Clear History',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearAllTransactions();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Delete All',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sort Mode Enum
// ---------------------------------------------------------------------------

enum _SortMode {
  newest('Newest First'),
  oldest('Oldest First'),
  highestAmount('Highest Amount'),
  lowestAmount('Lowest Amount');

  final String label;
  const _SortMode(this.label);
}
