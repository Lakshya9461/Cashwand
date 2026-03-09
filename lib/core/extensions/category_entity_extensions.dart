import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/domain/entities/category_entity.dart';

extension CategoryEntityUI on CategoryEntity {
  Color get colorValue {
    try {
      String hex = color.trim();

      // Strip any prefix
      if (hex.startsWith('#')) {
        hex = hex.substring(1);
      } else if (hex.toLowerCase().startsWith('0x')) {
        hex = hex.substring(2);
      }

      // Ensure 8 hex chars (AARRGGBB)
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      // Parse to int and construct Color
      final value = int.parse(hex, radix: 16);
      return Color(value);
    } catch (_) {
      return AppColors.primary;
    }
  }

  IconData get iconData {
    try {
      final codePoint = int.parse(icon);
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (_) {
      return Icons.category;
    }
  }
}
