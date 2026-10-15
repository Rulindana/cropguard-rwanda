import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark_mode';
  bool _isDark = true;
  bool get isDark => _isDark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to dark mode if never set
    _isDark = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDark);
  }

  // ── DARK THEME (dark blue + green neon) ──────────────────────
  // fontFamily is intentionally NOT set — Flutter will use the device's
  // native system font (Samsung One, Tecno, Roboto, etc.) automatically.
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: _buildTextTheme(Colors.white, const Color(0xFFE0E8EA)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: const Color(0xFF0B1617),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF263338),
      thickness: 1,
    ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: _buildTextTheme(
      const Color(0xFF050E08),
      const Color(0xFF111E15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00C853),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: Color(0xFF37474F)),
  );

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    // Every text style is w700 (bold) by default so ALL words in the app are bold.
    // Individual widgets can still override with a heavier weight (w800/w900) for
    // headings, but nothing will ever be lighter than bold unless explicitly set.
    return TextTheme(
      displayLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      displayMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      headlineMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      titleLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
      titleMedium: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      labelLarge: TextStyle(
        color: primary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      labelSmall: TextStyle(
        color: secondary,
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
  }
}
