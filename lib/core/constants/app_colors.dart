import 'package:flutter/material.dart';

/// App color palette — cohesive, premium feel for a finance app.
///
/// Uses a deep teal primary with warm accent colors. Dark surfaces
/// create a premium, focused experience suitable for financial data.
class AppColors {
  AppColors._();

  // Primary
  static const primary = Color(0xFF00BFA6);
  static const primaryLight = Color(0xFF5DF2D6);
  static const primaryDark = Color(0xFF008E76);

  // Background & Surface
  static const background = Color(0xFF0F1B2D);
  static const surface = Color(0xFF162236);
  static const surfaceLight = Color(0xFF1E2D45);
  static const card = Color(0xFF1A2840);

  // Text
  static const textPrimary = Color(0xFFF0F4F8);
  static const textSecondary = Color(0xFF8899A8);
  static const textMuted = Color(0xFF5A6B7D);

  // Semantic
  static const income = Color(0xFF4ADE80);
  static const expense = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFBBF24);

  // Category colors
  static const categoryFood = Color(0xFFFF8A65);
  static const categoryTransport = Color(0xFF42A5F5);
  static const categoryShopping = Color(0xFFAB47BC);
  static const categoryBills = Color(0xFFFFCA28);
  static const categoryEntertainment = Color(0xFFEC407A);
  static const categoryHealth = Color(0xFF66BB6A);
  static const categoryEducation = Color(0xFF26C6DA);
  static const categorySalary = Color(0xFF4ADE80);
  static const categoryOther = Color(0xFF78909C);
}
