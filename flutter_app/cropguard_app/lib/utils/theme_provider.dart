import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // ── DARK THEME (dark blue + green neon) ──────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: null,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF00C853),
          surface: Color(0xFF112225),
          error: Color(0xFFDC2626),
          onPrimary: Color(0xFF0B1617),
          onSecondary: Color(0xFF0B1617),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B1617),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF112225),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        textTheme: _buildTextTheme(Colors.white, const Color(0xFFB0BEC5)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: const Color(0xFF0B1617),
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        dividerTheme: const DividerThemeData(
            color: Color(0xFF263338), thickness: 1),
        iconTheme: const IconThemeData(color: Color(0xFF78909C)),
      );

  // ── LIGHT THEME (white + green neon) ─────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00C853),
          secondary: Color(0xFF00E676),
          surface: Colors.white,
          error: Color(0xFFDC2626),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF0B2010),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F7F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0B2010),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF0B2010),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        textTheme:
            _buildTextTheme(const Color(0xFF0B2010), const Color(0xFF37474F)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        dividerTheme: const DividerThemeData(
            color: Color(0xFFE0E0E0), thickness: 1),
        iconTheme: const IconThemeData(color: Color(0xFF37474F)),
      );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
          color: primary, fontWeight: FontWeight.w900, fontSize: 32),
      displayMedium: TextStyle(
          color: primary, fontWeight: FontWeight.w800, fontSize: 28),
      headlineLarge: TextStyle(
          color: primary, fontWeight: FontWeight.w800, fontSize: 24),
      headlineMedium: TextStyle(
          color: primary, fontWeight: FontWeight.w700, fontSize: 20),
      titleLarge: TextStyle(
          color: primary, fontWeight: FontWeight.w700, fontSize: 18),
      titleMedium: TextStyle(
          color: primary, fontWeight: FontWeight.w600, fontSize: 16),
      titleSmall: TextStyle(
          color: secondary, fontWeight: FontWeight.w600, fontSize: 14),
      bodyLarge: TextStyle(
          color: primary, fontWeight: FontWeight.w500, fontSize: 16),
      bodyMedium: TextStyle(
          color: secondary, fontWeight: FontWeight.w500, fontSize: 14),
      bodySmall: TextStyle(
          color: secondary, fontWeight: FontWeight.w400, fontSize: 12),
      labelLarge: TextStyle(
          color: primary, fontWeight: FontWeight.w700, fontSize: 14),
    );
  }
}
