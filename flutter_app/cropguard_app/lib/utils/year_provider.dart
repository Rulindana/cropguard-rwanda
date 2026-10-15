import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/district_model.dart';

class YearProvider extends ChangeNotifier {
  static const _prefKey = 'selected_year';
  int _selectedYear = 2026;
  static const int minYear = 2013;
  static const int maxYear = 2026;
  static const List<int> availableYears = [
    2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,2026,
  ];

  List<District>? _yearDistricts;
  bool get hasYearData => _yearDistricts != null;
  List<District>? get yearDistricts => _yearDistricts;

  int get selectedYear => _selectedYear;
  bool get isHistorical => _selectedYear < maxYear;
  String get seasonLabel => 'Season B $_selectedYear';

  // Keep these for backward compat with crop yield scaling in UI
  double get yieldMultiplier {
    final y = maxYear - _selectedYear;
    return _pow(1.0 - 0.045, y);
  }
  double get riskMultiplier {
    final y = maxYear - _selectedYear;
    return 1.0 + (y * 0.011).clamp(0.0, 0.15);
  }
  double get lossRateMultiplier {
    final y = maxYear - _selectedYear;
    return 1.0 + (y * 0.008);
  }

  YearProvider() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedYear = prefs.getInt(_prefKey) ?? maxYear;
    notifyListeners();
  }

  Future<void> setYear(int year) async {
    if (year == _selectedYear) return;
    _selectedYear = year;
    _yearDistricts = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, year);
    await _loadYearDistricts();
  }

  Future<void> _loadYearDistricts() async {
    try {
      final raw = await rootBundle.loadString('assets/data/risk_history.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final yearData = data[_selectedYear.toString()] as Map<String, dynamic>?;
      if (yearData == null) return;
      final list = yearData['districts'] as List<dynamic>;
      _yearDistricts = list.map((d) {
        final m = d as Map<String, dynamic>;
        final risk = m['risk'] as Map<String, dynamic>? ?? {};
        final nb   = m['nirs_baseline'] as Map<String, dynamic>? ?? {};
        return District.fromFirestore({
          'name':                       m['district_name'] ?? '',
          'province':                   m['province'] ?? '',
          'centroid_lat':               m['centroid_lat'] ?? 0.0,
          'centroid_lng':               m['centroid_lng'] ?? 0.0,
          'nirs_baseline':              nb,
          'risk_score':                 (risk['risk_score'] as num?)?.toDouble() ?? 0.0,
          'risk_level':                 risk['level'] ?? 'green',
          'rainfall_index':             (risk['rainfall_index'] as num?)?.toDouble() ?? 0.0,
          'humidity_index':             (risk['humidity_index'] as num?)?.toDouble() ?? 0.0,
          'loss_rate_index':            (risk['loss_rate_index'] as num?)?.toDouble() ?? 0.0,
          'soil_moisture_index':        (risk['soil_moisture_index'] as num?)?.toDouble() ?? 0.0,
          'total_precipitation_14d_mm': (risk['total_precipitation_14d_mm'] as num?)?.toDouble() ?? 0.0,
          'max_humidity_pct':           (risk['max_humidity_pct'] as num?)?.toDouble() ?? 0.0,
          'advisory':                   m['advisory'] ?? '',
          'updated_at':                 m['updated_at'] ?? '',
          'risk_delta':                 (m['risk_delta'] as num?)?.toDouble() ?? 0.0,
          'risk_trend':                 m['risk_trend'] is String ? m['risk_trend'] : 'baseline',
          'previous_risk_score':        null,
        }, m['district_id'] ?? m['district_name'] ?? '');
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('YearProvider: failed to load year data: $e');
    }
  }

  static double _pow(double base, int exp) {
    double r = 1.0;
    for (int i = 0; i < exp; i++) r *= base;
    return r;
  }
}
