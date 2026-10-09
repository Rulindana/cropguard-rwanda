import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/district_detail_screen.dart';
import 'screens/facilities_list_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String summary = '/summary';
  static const String districtDetail = '/district/:id';
  static const String facilities = '/district/:id/facilities';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case summary:
        return MaterialPageRoute(
          builder: (_) => const SummaryScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Convenience methods for navigation
  static void navigateToDistrictDetail(
    BuildContext context,
    dynamic district, {
    List<Map<String, dynamic>>? weatherTrend,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DistrictDetailScreen(
          district: district,
          weatherTrend: weatherTrend,
        ),
      ),
    );
  }

  static void navigateToFacilities(
    BuildContext context, {
    required dynamic district,
    required List<dynamic> facilities,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FacilitiesListScreen(
          district: district,
          facilities: facilities,
        ),
      ),
    );
  }
}
