import 'package:flutter/material.dart';
import 'package:expense_tracker/domain/enums/account_type.dart';

/// Maps [AccountType] to UI-specific properties.
extension AccountTypeUI on AccountType {
  IconData get icon {
    switch (this) {
      case AccountType.salary:
        return Icons.account_balance_rounded;
      case AccountType.cash:
        return Icons.payments_rounded;
      case AccountType.bank:
        return Icons.account_balance_wallet_rounded;
      case AccountType.freelance:
        return Icons.laptop_mac_rounded;
      case AccountType.business:
        return Icons.business_center_rounded;
      case AccountType.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case AccountType.salary:
        return const Color(0xFF4CAF50);
      case AccountType.cash:
        return const Color(0xFFFFC107);
      case AccountType.bank:
        return const Color(0xFF2196F3);
      case AccountType.freelance:
        return const Color(0xFF9C27B0);
      case AccountType.business:
        return const Color(0xFFFF9800);
      case AccountType.other:
        return const Color(0xFF78909C);
    }
  }
}
