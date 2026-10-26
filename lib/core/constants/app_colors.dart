import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Branding Colors
  static const Color primaryRed = Color(0xFFD71920);
  static const Color primaryRedDark = Color(0xFFB9141A);
  static const Color primaryRedLight = Color(0xFFFFECEE);
  static const Color primaryRedBorder = Color(0xFFFFD5D8);

  // Backgrounds & Surface
  static const Color background = Color(0xFFF6F7F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8FAFC);

  // Text Colors
  static const Color textDark = Color(0xFF1E293B);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Functional & Semantic Colors
  // Green (Visited, Collection, Positive)
  static const Color green = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFDCFCE7);
  static const Color greenBorder = Color(0xFFBBF7D0);
  static const Color greenCardBg = Color(0xFFF0FDF4);

  // Blue (Pending, Info, Outlets Visited)
  static const Color blue = Color(0xFF2563EB);
  static const Color blueLight = Color(0xFFDBEAFE);
  static const Color blueBorder = Color(0xFFBFDBFE);
  static const Color blueCardBg = Color(0xFFEFF6FF);

  // Purple (Pending Outlets, Ledger action)
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color purpleBorder = Color(0xFFDDD6FE);
  static const Color purpleCardBg = Color(0xFFFAF5FF);

  // Orange / Yellow (Rank 1, Warning)
  static const Color orange = Color(0xFFD97706);
  static const Color orangeLight = Color(0xFFFEF3C7);
  static const Color silver = Color(0xFF64748B);
  static const Color bronze = Color(0xFFB45309);

  // Neutral Grays (Not Visited, Borders, Dividers)
  static const Color gray = Color(0xFF6B7280);
  static const Color grayLight = Color(0xFFF1F5F9);
  static const Color grayBorder = Color(0xFFE2E8F0);
  static const Color grayInputBg = Color(0xFFF8FAFC);

  // Box Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(10),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withAlpha(8),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
}
