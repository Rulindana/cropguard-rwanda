import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'models/district_model.dart';
import 'screens/landing_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/summary_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const CropGuardApp());
}

class CropGuardApp extends StatelessWidget {
  const CropGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropGuard AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textOnPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.textOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
          bodySmall: TextStyle(color: AppColors.textDim),
        ),
      ),
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
        }
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      },
      initialRoute: '/',
      home: const LandingScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  NavItem _currentNav = NavItem.dashboard;

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      currentNav: _currentNav,
      onMenuToggle: () {},
      child: _buildPage(),
    );
  }

  Widget _buildPage() {
    return StreamBuilder<List<District>>(
      stream: DistrictService().getDistrictsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final districts = snapshot.data ?? [];

        if (districts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: AppColors.textDim),
                const SizedBox(height: 16),
                const Text('Loading district data...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return DashboardScreen(districts: districts, facilities: []);
      },
    );
  }
}
