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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/dashboard':
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
