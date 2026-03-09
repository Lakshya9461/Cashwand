import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/domain/entities/account_entity.dart';
import 'package:expense_tracker/presentation/providers/account_provider.dart';
import 'package:expense_tracker/core/extensions/account_entity_extensions.dart';

class AccountManagerScreen extends StatelessWidget {
  const AccountManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accProvider = context.watch<AccountProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Accounts')),
      body: accProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accProvider.accounts.length,
              itemBuilder: (context, index) {
                final account = accProvider.accounts[index];
                return _buildAccountItem(context, account, accProvider);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditModal(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    AccountEntity account,
    AccountProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: account.isDefault
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.surfaceLight,
          child: Icon(account.iconData, color: AppColors.primary),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          account.isDefault ? 'Default Account' : 'Custom Account',
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: account.isDefault
            ? const Icon(Icons.star, color: Colors.amber)
            : PopupMenuButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textMuted),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'make_default',
                    child: Text('Make Default'),
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
                  if (value == 'edit') {
                    _showAddEditModal(context, account);
                  } else if (value == 'make_default') {
                    provider.setDefaultAccount(account.id);
                  } else if (value == 'delete') {
                    _confirmDelete(context, account, provider);
                  }
                },
              ),
      ),
    );
  }

  void _showAddEditModal(BuildContext context, AccountEntity? account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _AccountFormModal(account: account),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AccountEntity account,
    AccountProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Text(
          'Delete "${account.name}"? Transactions will be reassigned to your default account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAccount(account.id);
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

class _AccountFormModal extends StatefulWidget {
  final AccountEntity? account;

  const _AccountFormModal({this.account});

  @override
  State<_AccountFormModal> createState() => _AccountFormModalState();
}

class _AccountFormModalState extends State<_AccountFormModal> {
  late TextEditingController _nameController;
  String _selectedIcon = Icons.account_balance_wallet.codePoint.toString();

  final List<IconData> _iconChoices = [
    Icons.account_balance_wallet,
    Icons.wallet,
    Icons.credit_card,
    Icons.business_center,
    Icons.money,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name ?? '');
    if (widget.account != null) {
      _selectedIcon = widget.account!.icon;
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
            widget.account == null ? 'New Account' : 'Edit Account',
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
              labelText: 'Account Name',
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
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;

                final provider = context.read<AccountProvider>();
                if (widget.account == null) {
                  provider.addAccount(
                    AccountEntity(
                      id: const Uuid().v4(),
                      profileId: 'temp',
                      name: name,
                      type: 'custom',
                      icon: _selectedIcon,
                      isDefault: false,
                    ),
                  );
                } else {
                  provider.updateAccount(
                    widget.account!.copyWith(name: name, icon: _selectedIcon),
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Save Account'),
            ),
          ),
        ],
      ),
    );
  }
}
