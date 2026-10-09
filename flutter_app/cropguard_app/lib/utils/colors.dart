import 'package:flutter/material.dart';

class AppColors {
  // Risk level colors
  static const Color green = Color(0xFF16A34A);
  static const Color yellow = Color(0xFFF59E0B);
  static const Color red = Color(0xFFDC2626);

  // App primary colors
  static const Color primary = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF047857);
  static const Color secondary = Color(0xFFD97706);

  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Province colors for map
  static const Color northern = Color(0xFF3B82F6);
  static const Color eastern = Color(0xFF10B981);
  static const Color western = Color(0xFF8B5CF6);
  static const Color southern = Color(0xFFEC4899);
  static const Color kigali = Color(0xFFF97316);
}

class AppRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double circular = 999.0;
}

class AppShadows {
  static BoxShadow get small => const BoxShadow(
        color: Color(0xFF00000008),
        blurRadius: 4,
        offset: Offset(0, 2),
      );

  static BoxShadow get medium => const BoxShadow(
        color: Color(0xFF00000012),
        blurRadius: 8,
        offset: Offset(0, 4),
      );

  static BoxShadow get card => const BoxShadow(
        color: Color(0xFF0000000A),
        blurRadius: 12,
        offset: Offset(0, 4),
      );
}
