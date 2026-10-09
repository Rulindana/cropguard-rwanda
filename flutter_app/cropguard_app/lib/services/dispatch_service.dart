import 'dart:math' as math;

import '../models/district_model.dart';
import '../models/facility_model.dart';

/// Innovation #2: Facility Dispatch Matching (client side)
///
/// Mirrors the pipeline's `dispatch_matcher.py`: ranks facilities by
/// haversine distance from the district centroid and remaining capacity
/// so high-risk districts get an actionable "dispatch here now" list.
class DispatchMatch {
  final Facility facility;
  final double distanceKm;
  final int etaMinutes;
  final double matchScore;
  final String priority; // emergency | recommended | available

  const DispatchMatch({
    required this.facility,
    required this.distanceKm,
    required this.etaMinutes,
    required this.matchScore,
    required this.priority,
  });
}

class DispatchService {
  /// Average rural road speed (km/h) and loading overhead (minutes).
  static const double avgRoadSpeedKmh = 35.0;
  static const int handlingMinutes = 10;

  /// Great-circle distance between two points in kilometres.
  static double haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;
    final phi1 = lat1 * math.pi / 180.0;
    final phi2 = lat2 * math.pi / 180.0;
    final dPhi = (lat2 - lat1) * math.pi / 180.0;
    final dLambda = (lng2 - lng1) * math.pi / 180.0;

    final a = math.sin(dPhi / 2) * math.sin(dPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(dLambda / 2) * math.sin(dLambda / 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(a));
  }

  static int estimateTravelMinutes(double distanceKm) {
    final drivingMinutes = (distanceKm / avgRoadSpeedKmh) * 60;
    return (drivingMinutes + handlingMinutes).round();
  }

  static String _priorityForLevel(String level) {
    switch (level) {
      case 'red':
        return 'emergency';
      case 'yellow':
        return 'recommended';
      default:
        return 'available';
    }
  }

  /// Rank [facilities] for [district]: nearest + most free capacity first.
  static List<DispatchMatch> rank({
    required District district,
    required List<Facility> facilities,
    int topN = 5,
  }) {
    final priority = _priorityForLevel(district.riskLevel);
    final matches = <DispatchMatch>[];

    for (final facility in facilities) {
      if (facility.availableCapacityTons <= 0) continue; // full - skip

      final distanceKm = haversineKm(
        district.centroidLat,
        district.centroidLng,
        facility.lat,
        facility.lng,
      );
      final capacityRatio = facility.capacityTons > 0
          ? facility.availableCapacityTons / facility.capacityTons
          : 0.0;

      // Composite score (higher is better): near + lots of free space
      final proximity = (1.0 - math.min(distanceKm, 120.0) / 120.0) * 60.0;
      final score = math.max(0.0, proximity + capacityRatio * 40.0);

      matches.add(DispatchMatch(
        facility: facility,
        distanceKm: distanceKm,
        etaMinutes: estimateTravelMinutes(distanceKm),
        matchScore: score,
        priority: priority,
      ));
    }

    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return matches.take(topN).toList();
  }
}
