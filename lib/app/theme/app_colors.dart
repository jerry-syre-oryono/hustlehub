import 'package:flutter/material.dart';

class AppColors {
  // Light Palette
  static const Color primaryLight = Color(0xFF7C3AED); // Royal Purple
  static const Color secondaryLight = Color(0xFFF472B6); // Soft Pink
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  
  // Dark Palette
  static const Color primaryDark = Color(0xFFA78BFA); // Soft Purple
  static const Color secondaryDark = Color(0xFFFB7185); // Soft Rose
  static const Color backgroundDark = Color(0xFF0F0A1F);
  static const Color surfaceDark = Color(0xFF1A142D);
  static const Color cardDark = Color(0xFF241C3B);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
