import 'package:flutter/material.dart';
import 'package:expense_tracker/domain/entities/account_entity.dart';

extension AccountEntityUI on AccountEntity {
  IconData get iconData {
    try {
      final codePoint = int.parse(icon);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.account_balance_wallet;
    }
  }
}
