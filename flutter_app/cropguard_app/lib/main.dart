import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/landing_screen.dart';
import 'screens/main_scaffold.dart';
import 'services/firebase_service.dart';
import 'utils/language_provider.dart';
import 'utils/theme_provider.dart';
import 'utils/year_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't await Firebase — run the app immediately, Firebase initializes
  // in the background and falls back to local seed data if not ready.
  FirebaseService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => YearProvider()),
      ],
      child: const CropGuardApp(),
    ),
  );
}

class CropGuardApp extends StatelessWidget {
  const CropGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'CropGuard AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
      // ── Font scaling guard ──────────────────────────────────────────────
      // The app uses the device's own font style (Samsung One, Tecno, etc.)
      // automatically — no fontFamily is forced.
      //
      // However we clamp text scaling to 1.15× max so that users who set
      // "Large" or "Extra-Large" fonts in System Settings don't cause nav
      // labels to overflow or content to be cut off. Content areas (scrollable
      // screens) are NOT affected — only fixed-height UI chrome is protected.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScaler = mediaQuery.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: 1.15,
        );
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: clampedScaler),
          // Wrap in DefaultTextStyle so every Text() that doesn't explicitly
          // set fontWeight inherits bold (w700) as the app-wide default.
          child: DefaultTextStyle(
            style: DefaultTextStyle.of(context).style.copyWith(
              fontWeight: FontWeight.w700,
            ),
            child: child!,
          ),
        );
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
            return MaterialPageRoute(
                builder: (_) => const ResponsiveScaffold());
          case '/scan':
            return MaterialPageRoute(
                builder: (_) => const ResponsiveScaffold());
          default:
            return MaterialPageRoute(
                builder: (_) => const LandingScreen());
        }
      },
      initialRoute: '/',
      home: const LandingScreen(),
    );
  }
}
