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

  double get maizeTons =>
      (nirsBaseline['maize_tons'] as num?)?.toDouble() ?? 0.0;
  double get beansTons =>
      (nirsBaseline['beans_tons'] as num?)?.toDouble() ?? 0.0;
  double get irishPotatoesTons =>
      (nirsBaseline['irish_potatoes_tons'] as num?)?.toDouble() ?? 0.0;
  double get cassavaTons =>
      (nirsBaseline['cassava_tons'] as num?)?.toDouble() ?? 0.0;
  double get sorghumTons =>
      (nirsBaseline['sorghum_tons'] as num?)?.toDouble() ?? 0.0;
  double get wheatTons =>
      (nirsBaseline['wheat_tons'] as num?)?.toDouble() ?? 0.0;
  double get groundnutsTons =>
      (nirsBaseline['groundnuts_tons'] as num?)?.toDouble() ?? 0.0;
  double get sweetPotatoTons =>
      (nirsBaseline['sweet_potato_tons'] as num?)?.toDouble() ?? 0.0;
  double get peasTons => (nirsBaseline['peas_tons'] as num?)?.toDouble() ?? 0.0;
  double get historicalLossRatePct =>
      (nirsBaseline['historical_loss_rate_pct'] as num?)?.toDouble() ?? 0.0;

  /// Returns all crops with non-zero tonnage for this district
  List<Map<String, dynamic>> get crops {
    final all = [
      {
        'icon': '🌽',
        'name': 'Maize',
        'name_rw': 'Ibigori',
        'name_fr': 'Maïs',
        'tons': maizeTons,
      },
      {
        'icon': '🫘',
        'name': 'Beans',
        'name_rw': 'Ibishyimbo',
        'name_fr': 'Haricots',
        'tons': beansTons,
      },
      {
        'icon': '🥔',
        'name': 'Irish Potato',
        'name_rw': 'Ibirayi',
        'name_fr': 'Pomme de Terre',
        'tons': irishPotatoesTons,
      },
      {
        'icon': '🌿',
        'name': 'Cassava',
        'name_rw': 'Imyumbati',
        'name_fr': 'Manioc',
        'tons': cassavaTons,
      },
      {
        'icon': '🌾',
        'name': 'Sorghum',
        'name_rw': 'Amasaka',
        'name_fr': 'Sorgho',
        'tons': sorghumTons,
      },
      {
        'icon': '🌾',
        'name': 'Wheat',
        'name_rw': 'Ingano',
        'name_fr': 'Blé',
        'tons': wheatTons,
      },
      {
        'icon': '🥜',
        'name': 'Groundnuts',
        'name_rw': 'Amandarashara',
        'name_fr': 'Arachides',
        'tons': groundnutsTons,
      },
      {
        'icon': '🍠',
        'name': 'Sweet Potato',
        'name_rw': 'Ibijumba',
        'name_fr': 'Patate Douce',
        'tons': sweetPotatoTons,
      },
      {
        'icon': '🟢',
        'name': 'Peas',
        'name_rw': 'Amashaza',
        'name_fr': 'Pois',
        'tons': peasTons,
      },
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
      updatedAt:
          data['updated_at'] != null
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

  // ── Cause-specific alert description ─────────────────────────────────────

  /// Returns the single biggest contributing factor as a short label.
  /// e.g. "Rainfall", "Humidity", "Soil Moisture", "Multiple factors"
  String get primaryCauseLabel {
    // Each sensor normalised to 0-100 contribution score
    final rainScore = (totalPrecipitation14dMm / 150.0 * 100).clamp(0.0, 100.0);
    final humScore = maxHumidityPct.clamp(0.0, 100.0);
    final soilScore = (soilMoistureIndex * 100).clamp(0.0, 100.0);

    final max = [
      rainScore,
      humScore,
      soilScore,
    ].reduce((a, b) => a > b ? a : b);
    if (max == rainScore && rainScore > 30) return 'Heavy Rainfall';
    if (max == humScore && humScore > 60) return 'High Humidity';
    if (max == soilScore && soilScore > 50) return 'Saturated Soil';
    return 'Combined Conditions';
  }

  /// Builds a concise, cause-specific alert description in the given language.
  /// Includes actual sensor values so the reader knows *why* risk is raised.
  String alertDescription(String languageCode) {
    final rain = totalPrecipitation14dMm.toStringAsFixed(0);
    final humid = maxHumidityPct.toStringAsFixed(0);
    final soil = (soilMoistureIndex * 100).toStringAsFixed(0);

    // Determine which sensors are in the danger zone
    final highRain = totalPrecipitation14dMm > 80;
    final highHumid = maxHumidityPct > 75;
    final highSoil = soilMoistureIndex > 0.65;

    // ── English ─────────────────────────────────────────────────────────────
    if (languageCode == 'en') {
      if (riskLevel == 'red') {
        if (highRain && highHumid && highSoil) {
          return 'Emergency: $rain mm rain (14d) + $humid% humidity + $soil% soil moisture — move crops to covered storage now.';
        } else if (highRain && highHumid) {
          return 'Critical: $rain mm rain over 14 days, humidity at $humid% — immediate covered storage required.';
        } else if (highRain) {
          return 'Critical: $rain mm of rain over 14 days — crops exposed to severe moisture damage. Move to storage.';
        } else if (highHumid && highSoil) {
          return 'Critical: $humid% humidity + $soil% soil moisture — fungal risk is very high. Store crops immediately.';
        } else if (highHumid) {
          return 'Critical: Humidity spiked to $humid% — risk of mold and post-harvest loss. Emergency storage needed.';
        } else {
          return 'High post-harvest risk ($riskScore.toStringAsFixed(0)%). Rain: $rain mm, Humidity: $humid%, Soil: $soil%. Move crops to covered storage.';
        }
      } else if (riskLevel == 'yellow') {
        if (highRain) {
          return 'Caution: $rain mm rain in last 14 days — arrange drying or covered storage within 48 hours.';
        } else if (highHumid) {
          return 'Caution: Humidity at $humid% — plan drying within 48 hours to prevent mold.';
        } else if (highSoil) {
          return 'Caution: Soil moisture at $soil% — harvest and dry crops promptly to avoid loss.';
        } else {
          return 'Moderate risk. Rain: $rain mm, Humidity: $humid%, Soil: $soil%. Arrange drying within 48 hours.';
        }
      } else {
        return 'Conditions safe. Rain: $rain mm (14d), Humidity: $humid%, Soil: $soil%. Normal harvesting conditions.';
      }
    }

    // ── Kinyarwanda ──────────────────────────────────────────────────────────
    if (languageCode == 'rw') {
      if (riskLevel == 'red') {
        if (highRain && highHumid) {
          return 'Impamvu: Imvura $rain mm (iminsi 14) + ubuhehere $humid% — ohereza ibihingwa mu bubiko ubu.';
        } else if (highRain) {
          return 'Impamvu: Imvura $rain mm mu minsi 14 — ohereza ibihingwa mu bubiko bwegeranye ubu.';
        } else if (highHumid) {
          return 'Impamvu: Ubuhehere bugeze ku $humid% — inzoka n\'ubora bya fungusi biteye ubwoba. Bubiko burakenewe.';
        } else {
          return 'Ingaruka nini. Imvura: $rain mm, Ubuhehere: $humid%, Ubutaka: $soil%. Ohereza ibihingwa mu bubiko.';
        }
      } else if (riskLevel == 'yellow') {
        if (highRain) {
          return 'Imenyetso: Imvura $rain mm mu minsi 14 — teekera icyuma cy\'ongera umuvandu mu masaa 48.';
        } else if (highHumid) {
          return 'Imenyetso: Ubuhehere bugeze ku $humid% — kama ibihingwa mu masaa 48 kugira ngo wirinde ubora bwa fungusi.';
        } else {
          return 'Ingaruka hagati. Imvura: $rain mm, Ubuhehere: $humid%, Ubutaka: $soil%. Teganya gukama mu masaa 48.';
        }
      } else {
        return 'Imyaka iri mu bihe byiza. Imvura: $rain mm, Ubuhehere: $humid%, Ubutaka: $soil%. Birashoboka gutsinda.';
      }
    }

    // ── French ───────────────────────────────────────────────────────────────
    if (riskLevel == 'red') {
      if (highRain && highHumid) {
        return 'Urgence: $rain mm pluie (14j) + $humid% humidité — transfert en stockage couvert immédiatement.';
      } else if (highRain) {
        return 'Critique: $rain mm de pluie en 14 jours — dommages sévères aux récoltes. Stockage immédiat requis.';
      } else if (highHumid) {
        return 'Critique: Humidité à $humid% — risque élevé de moisissure. Stockage d\'urgence nécessaire.';
      } else {
        return 'Risque élevé. Pluie: $rain mm, Humidité: $humid%, Sol: $soil%. Transférer en stockage couvert.';
      }
    } else if (riskLevel == 'yellow') {
      if (highRain) {
        return 'Attention: $rain mm de pluie ces 14 derniers jours — organiser le séchage sous 48h.';
      } else if (highHumid) {
        return 'Attention: Humidité à $humid% — planifier le séchage sous 48h pour éviter la moisissure.';
      } else {
        return 'Risque modéré. Pluie: $rain mm, Humidité: $humid%, Sol: $soil%. Séchage recommandé sous 48h.';
      }
    } else {
      return 'Conditions saines. Pluie: $rain mm, Humidité: $humid%, Sol: $soil%. Récolte normale.';
    }
  }
}
