import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Section header
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SECURITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
          ),

          // App Lock toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Lock',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Require fingerprint or PIN to open',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: authProvider.isAppLockEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) => authProvider.toggleAppLock(value),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Set / Change / Remove PIN
          ListTile(
            onTap: () => context.push('/set-pin'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(Icons.pin_outlined, color: AppColors.primary),
            title: Text(
              authProvider.hasPinSet ? 'Change PIN' : 'Set PIN',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              authProvider.hasPinSet
                  ? 'PIN is active'
                  : 'Add an in-app PIN lock',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: authProvider.hasPinSet
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.expense,
                    ),
                    tooltip: 'Remove PIN',
                    onPressed: () {
                      authProvider.removePin();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PIN removed')),
                      );
                    },
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
          ),

          const SizedBox(height: 32),

          // General section
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
          ),

          ListTile(
            onTap: () => context.push('/about'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'About CashWand',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: () => context.push('/profile-manager'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(Icons.wallet_rounded, color: AppColors.primary),
            title: const Text(
              'Manage Spaces',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text(
              'Switch, create, or delete financial spaces',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: () => context.push('/category-manager'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(
              Icons.category_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Manage Categories',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: () => context.push('/account-manager'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.primary,
            ),
            title: const Text(
              'Manage Accounts',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            onTap: () => context.push('/recurring'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            tileColor: AppColors.surface,
            leading: const Icon(Icons.repeat_rounded, color: AppColors.primary),
            title: const Text(
              'Recurring Transactions',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
