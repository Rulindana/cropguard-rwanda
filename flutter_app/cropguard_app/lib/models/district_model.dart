import 'dart:ui'; // For Color

class District {
  final String id;
  final String name;
  final String province;
  final double centroidLat;
  final double centroidLng;
  final Map<String, dynamic> nirsBaseline;
  final double riskScore;
  final String riskLevel;
  final double rainfallIndex;
  final double humidityIndex;
  final double lossRateIndex;
  final double totalPrecipitation14dMm;
  final double maxHumidityPct;
  final double soilMoistureIndex;
  final String advisory;
  final DateTime updatedAt;

  /// Risk momentum vs the previous pipeline run (Criterion 3 trend layer).
  final double riskDelta;
  final String riskTrend; // rising | falling | stable | baseline
  final double? previousRiskScore;

  District({
    required this.id,
    required this.name,
    required this.province,
    required this.centroidLat,
    required this.centroidLng,
    required this.nirsBaseline,
    required this.riskScore,
    required this.riskLevel,
    required this.rainfallIndex,
    required this.humidityIndex,
    required this.lossRateIndex,
    required this.totalPrecipitation14dMm,
    required this.maxHumidityPct,
    this.soilMoistureIndex = 0.0,
    required this.advisory,
    required this.updatedAt,
    this.riskDelta = 0.0,
    this.riskTrend = 'baseline',
    this.previousRiskScore,
  });

  double get maizeTons => nirsBaseline['maize_tons'] ?? 0.0;
  double get beansTons => nirsBaseline['beans_tons'] ?? 0.0;
  double get irishPotatoesTons => nirsBaseline['irish_potatoes_tons'] ?? 0.0;
  double get cassavaTons => nirsBaseline['cassava_tons'] ?? 0.0;
  double get historicalLossRatePct => nirsBaseline['historical_loss_rate_pct'] ?? 0.0;

  factory District.fromFirestore(Map<String, dynamic> data, String id) {
    return District(
      id: id,
      name: data['name'] ?? '',
      province: data['province'] ?? '',
      centroidLat: (data['centroid_lat'] as num).toDouble(),
      centroidLng: (data['centroid_lng'] as num).toDouble(),
      nirsBaseline: data['nirs_baseline'] ?? {},
      riskScore: (data['risk_score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: data['risk_level'] ?? 'green',
      rainfallIndex: (data['rainfall_index'] as num?)?.toDouble() ?? 0.0,
      humidityIndex: (data['humidity_index'] as num?)?.toDouble() ?? 0.0,
      lossRateIndex: (data['loss_rate_index'] as num?)?.toDouble() ?? 0.0,
      totalPrecipitation14dMm:
          (data['total_precipitation_14d_mm'] as num?)?.toDouble() ?? 0.0,
      maxHumidityPct: (data['max_humidity_pct'] as num?)?.toDouble() ?? 0.0,
      soilMoistureIndex:
          (data['soil_moisture_index'] as num?)?.toDouble() ?? 0.0,
      advisory: data['advisory'] ?? '',
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at']) ?? DateTime.now()
          : DateTime.now(),
      riskDelta: (data['risk_delta'] as num?)?.toDouble() ?? 0.0,
      riskTrend: data['risk_trend'] ?? 'baseline',
      previousRiskScore: (data['previous_risk_score'] as num?)?.toDouble(),
    );
  }

  /// Momentum label for UI chips, e.g. "▲ +6.2 since last run".
  String get trendLabel {
    switch (riskTrend) {
      case 'rising':
        return '▲ +${riskDelta.toStringAsFixed(1)} since last run';
      case 'falling':
        return '▼ ${riskDelta.toStringAsFixed(1)} since last run';
      case 'stable':
        return '→ stable (${riskDelta >= 0 ? '+' : ''}${riskDelta.toStringAsFixed(1)})';
      default:
        return 'First reading';
    }
  }

  Color get trendColor {
    switch (riskTrend) {
      case 'rising':
        return const Color(0xFFDC2626);
      case 'falling':
        return const Color(0xFF16A34A);
      case 'stable':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF78909C);
    }
  }

  Color get riskColor {
    switch (riskLevel) {
      case 'red':
        return const Color(0xFFDC2626);
      case 'yellow':
        return const Color(0xFFF59E0B);
      case 'green':
      default:
        return const Color(0xFF16A34A);
    }
  }

  String get riskIcon {
    switch (riskLevel) {
      case 'red':
        return '🔴';
      case 'yellow':
        return '🟡';
      case 'green':
      default:
        return '🟢';
    }
  }
}
