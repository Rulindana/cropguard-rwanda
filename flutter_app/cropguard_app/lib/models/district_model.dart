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

  double get maizeTons => (nirsBaseline['maize_tons'] as num?)?.toDouble() ?? 0.0;
  double get beansTons => (nirsBaseline['beans_tons'] as num?)?.toDouble() ?? 0.0;
  double get irishPotatoesTons => (nirsBaseline['irish_potatoes_tons'] as num?)?.toDouble() ?? 0.0;
  double get cassavaTons => (nirsBaseline['cassava_tons'] as num?)?.toDouble() ?? 0.0;
  double get sorghumTons => (nirsBaseline['sorghum_tons'] as num?)?.toDouble() ?? 0.0;
  double get wheatTons => (nirsBaseline['wheat_tons'] as num?)?.toDouble() ?? 0.0;
  double get groundnutsTons => (nirsBaseline['groundnuts_tons'] as num?)?.toDouble() ?? 0.0;
  double get sweetPotatoTons => (nirsBaseline['sweet_potato_tons'] as num?)?.toDouble() ?? 0.0;
  double get peasTons => (nirsBaseline['peas_tons'] as num?)?.toDouble() ?? 0.0;
  double get historicalLossRatePct => (nirsBaseline['historical_loss_rate_pct'] as num?)?.toDouble() ?? 0.0;

  /// Returns all crops with non-zero tonnage for this district
  List<Map<String, dynamic>> get crops {
    final all = [
      {'icon': '🌽', 'name': 'Maize',        'name_rw': 'Ibigori',     'name_fr': 'Maïs',           'tons': maizeTons},
      {'icon': '🫘', 'name': 'Beans',         'name_rw': 'Ibishyimbo',  'name_fr': 'Haricots',        'tons': beansTons},
      {'icon': '🥔', 'name': 'Irish Potato',  'name_rw': 'Ibirayi',     'name_fr': 'Pomme de Terre',  'tons': irishPotatoesTons},
      {'icon': '🌿', 'name': 'Cassava',       'name_rw': 'Imyumbati',   'name_fr': 'Manioc',          'tons': cassavaTons},
      {'icon': '🌾', 'name': 'Sorghum',       'name_rw': 'Amasaka',     'name_fr': 'Sorgho',          'tons': sorghumTons},
      {'icon': '🌾', 'name': 'Wheat',         'name_rw': 'Ingano',      'name_fr': 'Blé',             'tons': wheatTons},
      {'icon': '🥜', 'name': 'Groundnuts',    'name_rw': 'Amandarashara','name_fr': 'Arachides',      'tons': groundnutsTons},
      {'icon': '🍠', 'name': 'Sweet Potato',  'name_rw': 'Ibijumba',    'name_fr': 'Patate Douce',    'tons': sweetPotatoTons},
      {'icon': '🟢', 'name': 'Peas',          'name_rw': 'Amashaza',    'name_fr': 'Pois',            'tons': peasTons},
    ];
    return all.where((c) => (c['tons'] as double) > 0).toList();
  }

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

  String get riskLabel {
    switch (riskLevel) {
      case 'red':
        return 'High Risk';
      case 'yellow':
        return 'Moderate Risk';
      case 'green':
      default:
        return 'Low Risk';
    }
  }
}
