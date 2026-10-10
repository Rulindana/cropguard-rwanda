import 'package:flutter/material.dart';

class AppColors {
  // ── Primary green (same in both themes) ──────────────────────
  static const Color primary = Color(0xFF00E676);
  static const Color primaryDark = Color(0xFF00C853);
  static const Color primaryLight = Color(0xFF69F0AE);
  static const Color primaryDim = Color(0xFF004D25);

  // ── Dark theme (default) ──────────────────────────────────────
  static const Color background = Color(0xFF0B1617);
  static const Color backgroundSecondary = Color(0xFF112225);
  static const Color surface = Color(0xFF152629);
  static const Color cardBackground = Color(0xFF1A3035);
  static const Color cardHolographic = Color(0xFF0D1F23);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textDim = Color(0xFF78909C);
  static const Color textOnPrimary = Color(0xFF0B1617);
  static const Color border = Color(0xFF263338);
  static const Color divider = Color(0xFF1E2D31);
  static const Color inputBorder = Color(0xFF263338);

  // ── Light theme colors ────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF0F7F4);
  static const Color lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0B2010);
  static const Color lightTextSecondary = Color(0xFF37474F);
  static const Color lightTextDim = Color(0xFF78909C);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFEEEEEE);

  // ── Dynamic colors (read from context) ───────────────────────
  static Color bg(BuildContext context) =>
      _isDark(context) ? background : lightBackground;
  static Color bgSecondary(BuildContext context) =>
      _isDark(context) ? backgroundSecondary : lightBackgroundSecondary;
  static Color surfaceColor(BuildContext context) =>
      _isDark(context) ? surface : lightSurface;
  static Color text(BuildContext context) =>
      _isDark(context) ? textPrimary : lightTextPrimary;
  static Color textSub(BuildContext context) =>
      _isDark(context) ? textSecondary : lightTextSecondary;
  static Color textFaded(BuildContext context) =>
      _isDark(context) ? textDim : lightTextDim;
  static Color borderColor(BuildContext context) =>
      _isDark(context) ? border : lightBorder;
  static Color dividerColor(BuildContext context) =>
      _isDark(context) ? divider : lightDivider;
  static Color cardBg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF112225) : Colors.white;
  static Color sidebarBg(BuildContext context) =>
      _isDark(context) ? surface : Colors.white;

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Alert colors (same both themes) ──────────────────────────
  static const Color alertRed = Color(0xFFFF5252);
  static const Color alertYellow = Color(0xFFFFB300);
  static const Color alertGreen = Color(0xFF00E676);
  static const Color riskGreen = Color(0xFF00E676);
  static const Color riskYellow = Color(0xFFFFB300);
  static const Color riskRed = Color(0xFFFF5252);
  static const Color green = Color(0xFF00E676);
  static const Color yellow = Color(0xFFFFB300);
  static const Color red = Color(0xFFFF5252);
  static const Color secondary = Color(0xFF00E676);
  static const Color secondaryDark = Color(0xFF00C853);
  static const Color holographicBorder = Color(0xFF00E676);
  static const Color holographicGlow = Color(0x3300E676);
  static const Color northern = Color(0xFF00E676);
  static const Color eastern = Color(0xFF69F0AE);
  static const Color western = Color(0xFF00BCD4);
  static const Color southern = Color(0xFF7C4DFF);
  static const Color kigali = Color(0xFFFFB300);
  static const Color weatherSunny = Color(0xFFFFD54F);
  static const Color weatherCloudy = Color(0xFF90A4AE);
  static const Color weatherRainy = Color(0xFF4FC3F7);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF4FC3F7);
}


class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xlarge = 24.0;
  static const double circular = 999.0;
}

class AppShadows {
  // Holographic glow shadow
  static BoxShadow get holographic => BoxShadow(
        color: AppColors.holographicGlow,
        blurRadius: 20,
        spreadRadius: 2,
        offset: const Offset(0, 0),
      );

  static BoxShadow get card => BoxShadow(
        color: const Color(0xFF00000030),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );

  static BoxShadow get medium => BoxShadow(
        color: const Color(0xFF00000030),
        blurRadius: 14,
        offset: const Offset(0, 6),
      );

  static BoxShadow get elevated => BoxShadow(
        color: const Color(0xFF00000040),
        blurRadius: 16,
        offset: const Offset(0, 8),
      );

  static BoxShadow get glowGreen => BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 16,
        spreadRadius: 1,
      );
}

class AppGradients {
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF152629),
      Color(0xFF112225),
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient holographicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A3035),
      Color(0xFF0D1F23),
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient greenGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00E676),
      Color(0xFF00C853),
    ],
    stops: [0.0, 1.0],
  );

  static const RadialGradient holographicGlow = RadialGradient(
    center: Alignment.topLeft,
    colors: [
      Color(0x2200E676),
      Color(0x0000E676),
    ],
    stops: [0.0, 1.0],
  );
}
