class RiskSummary {
  final int totalDistricts;
  final int greenCount;
  final int yellowCount;
  final int redCount;
  final double avgRiskScore;

  RiskSummary({
    required this.totalDistricts,
    required this.greenCount,
    required this.yellowCount,
    required this.redCount,
    required this.avgRiskScore,
  });

  factory RiskSummary.fromFirestore(Map<String, dynamic> data) {
    return RiskSummary(
      totalDistricts: data['total_districts'] ?? 0,
      greenCount: data['green_count'] ?? 0,
      yellowCount: data['yellow_count'] ?? 0,
      redCount: data['red_count'] ?? 0,
      avgRiskScore: (data['avg_risk_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  double get highRiskPercentage {
    if (totalDistricts == 0) return 0.0;
    return (redCount / totalDistricts) * 100;
  }

  int get totalAtRisk => yellowCount + redCount;

  /// Serialize for the offline cache.
  Map<String, dynamic> toJson() => {
    'total_districts': totalDistricts,
    'green_count': greenCount,
    'yellow_count': yellowCount,
    'red_count': redCount,
    'avg_risk_score': avgRiskScore,
  };

  /// Deserialize from the offline cache.
  factory RiskSummary.fromJson(Map<String, dynamic> data) => RiskSummary(
    totalDistricts: data['total_districts'] ?? 0,
    greenCount: data['green_count'] ?? 0,
    yellowCount: data['yellow_count'] ?? 0,
    redCount: data['red_count'] ?? 0,
    avgRiskScore: (data['avg_risk_score'] as num?)?.toDouble() ?? 0.0,
  );
}
