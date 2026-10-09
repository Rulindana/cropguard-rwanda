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
  final String advisory;
  final DateTime updatedAt;

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
    required this.advisory,
    required this.updatedAt,
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
      advisory: data['advisory'] ?? '',
      updatedAt: data['updated_at'] != null
          ? DateTime.tryParse(data['updated_at']) ?? DateTime.now()
          : DateTime.now(),
    );
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
