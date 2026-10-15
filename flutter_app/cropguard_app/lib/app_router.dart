import 'package:flutter/material.dart';
import 'screens/landing_screen.dart';
import 'screens/main_scaffold.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const ResponsiveScaffold());
      default:
        return MaterialPageRoute(builder: (_) => const LandingScreen());
    }
  }
}
