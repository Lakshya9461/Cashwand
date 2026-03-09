import 'package:flutter/material.dart';
import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/domain/enums/category_type.dart';

/// Presentation-layer extensions for [CategoryType].
///
/// Icons and colors are UI concerns — they live here, NOT in the
/// domain enum. This keeps the domain layer free of Flutter imports.
extension CategoryTypeUI on CategoryType {
  IconData get icon {
    switch (this) {
      case CategoryType.food:
        return Icons.restaurant_rounded;
      case CategoryType.transport:
        return Icons.directions_bus_rounded;
      case CategoryType.shopping:
        return Icons.shopping_bag_rounded;
      case CategoryType.bills:
        return Icons.receipt_long_rounded;
      case CategoryType.entertainment:
        return Icons.movie_rounded;
      case CategoryType.health:
        return Icons.local_hospital_rounded;
      case CategoryType.education:
        return Icons.school_rounded;
      case CategoryType.salary:
        return Icons.account_balance_rounded;
      case CategoryType.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.food:
        return AppColors.categoryFood;
      case CategoryType.transport:
        return AppColors.categoryTransport;
      case CategoryType.shopping:
        return AppColors.categoryShopping;
      case CategoryType.bills:
        return AppColors.categoryBills;
      case CategoryType.entertainment:
        return AppColors.categoryEntertainment;
      case CategoryType.health:
        return AppColors.categoryHealth;
      case CategoryType.education:
        return AppColors.categoryEducation;
      case CategoryType.salary:
        return AppColors.categorySalary;
      case CategoryType.other:
        return AppColors.categoryOther;
    }
  }
}
