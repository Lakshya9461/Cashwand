import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';
import 'package:expense_tracker/presentation/providers/category_provider.dart';
import 'package:expense_tracker/core/extensions/category_entity_extensions.dart';

class CategoryManagerScreen extends StatelessWidget {
  const CategoryManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: catProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: catProvider.categories.length,
              itemBuilder: (context, index) {
                final category = catProvider.categories[index];
                return _buildCategoryItem(context, category, catProvider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    CategoryEntity category,
    CategoryProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.colorValue.withValues(alpha: 0.2),
          child: Icon(category.iconData, color: category.colorValue),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          category.isSystem ? 'System Category' : 'Custom Category',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: category.isSystem
            ? null
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: AppColors.expense),
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddEditModal(context, category);
                  } else if (value == 'delete') {
                    _confirmDelete(context, category, provider);
                  }
                },
              ),
      ),
    );
  }

  void _showAddEditModal(BuildContext context, CategoryEntity? category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CategoryFormModal(category: category),
    );
  }

  void _confirmDelete(
    BuildContext context,
    CategoryEntity category,
    CategoryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category?'),
        content: Text(
          'Delete "${category.name}"? Transactions will be reassigned to "Other".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCategory(category.id);
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
}

class _CategoryFormModal extends StatefulWidget {
  final CategoryEntity? category;

  const _CategoryFormModal({this.category});

  @override
  State<_CategoryFormModal> createState() => _CategoryFormModalState();
}

class _CategoryFormModalState extends State<_CategoryFormModal> {
  late TextEditingController _nameController;
  // Simple predefined picks for MVP
  String _selectedIcon = Icons.stars.codePoint.toString();
  String _selectedColor = Colors.amber
      .toARGB32()
      .toRadixString(16)
      .padLeft(8, '0');

  final List<IconData> _iconChoices = [
    Icons.stars,
    Icons.shopping_bag,
    Icons.flight,
    Icons.restaurant,
    Icons.favorite,
    Icons.home,
    Icons.school,
    Icons.attach_money,
  ];

  final List<Color> _colorChoices = [
    Colors.amber,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) {
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.category == null ? 'New Category' : 'Edit Category',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Category Name',
              filled: true,
              fillColor: AppColors.surfaceLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pick Icon',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _iconChoices.map((icon) {
              final isSelected = icon.codePoint.toString() == _selectedIcon;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedIcon = icon.codePoint.toString()),
                child: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceLight,
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text(
            'Pick Color',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: _colorChoices.map((color) {
              final colorStr = color
                  .toARGB32()
                  .toRadixString(16)
                  .padLeft(8, '0');
              final isSelected = colorStr == _selectedColor;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = colorStr),
                child: CircleAvatar(
                  backgroundColor: color,
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                final provider = context.read<CategoryProvider>();
                if (widget.category == null) {
                  provider.addCategory(
                    CategoryEntity(
                      id: const Uuid().v4(),
                      profileId:
                          'temp', // Provider handles this internally on web or dao
                      name: name,
                      icon: _selectedIcon,
                      color: _selectedColor,
                      isSystem: false,
                    ),
                  );
                } else {
                  provider.updateCategory(
                    widget.category!.copyWith(
                      name: name,
                      icon: _selectedIcon,
                      color: _selectedColor,
                    ),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save Category'),
            ),
          ),
        ],
      ),
    );
  }
}
