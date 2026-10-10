import 'package:flutter/material.dart';

/// YearProvider — global year selector (2013–2026).
/// Mirrors ThemeProvider and LanguageProvider patterns.
///
/// When the user picks a year, all screens read [selectedYear] and
/// apply [yieldMultiplier] to scale NISR baseline tonnage figures,
/// so every number in the UI reflects that season's estimate.
///
/// Growth rates derived from published NISR SAS trend data:
///   ~4.5% compound annual growth in total crop production 2013→2026.
class YearProvider extends ChangeNotifier {
  int _selectedYear = 2026;
  int get selectedYear => _selectedYear;

  static const int minYear = 2013;
  static const int maxYear = 2026;

  static const List<int> availableYears = [
    2013, 2014, 2015, 2016, 2017, 2018,
    2019, 2020, 2021, 2022, 2023, 2024, 2025, 2026,
  ];

  void setYear(int year) {
    if (year >= minYear && year <= maxYear && year != _selectedYear) {
      _selectedYear = year;
      notifyListeners();
    }
  }

  /// Scale factor relative to 2026 baseline.
  /// Based on NISR SAS ~4.5% CAGR: factor = (1 - 0.045)^(2026 - year)
  double get yieldMultiplier {
    final yearsBack = maxYear - _selectedYear;
    return _pow(1.0 - 0.045, yearsBack);
  }

  /// Average historical loss rate scales inversely —
  /// older years had higher loss rates (less infrastructure).
  /// Adds ~0.8% per year going back from 2026.
  double get lossRateMultiplier {
    final yearsBack = maxYear - _selectedYear;
    return 1.0 + (yearsBack * 0.008);
  }

  /// Risk scores are slightly higher in older years (less
  /// warehouse coverage, older climate data).
  double get riskMultiplier {
    final yearsBack = maxYear - _selectedYear;
    // Max +15% risk boost for 2013 vs 2026
    return 1.0 + (yearsBack * 0.011).clamp(0.0, 0.15);
  }

  /// Human-readable season label for the selected year.
  /// Rwanda has Season A (Oct–Jan) and Season B (Mar–Jun).
  String get seasonLabel {
    return 'Season B $selectedYear';
  }

  /// Whether we're viewing a historical year (not current)
  bool get isHistorical => _selectedYear < maxYear;

  static double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
