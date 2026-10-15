import 'package:flutter_test/flutter_test.dart';

import 'package:cropguard_app/models/district_model.dart';
import 'package:cropguard_app/models/facility_model.dart';
import 'package:cropguard_app/services/dispatch_service.dart';

District _district({double riskScore = 80.0, String riskLevel = 'red'}) {
  return District(
    id: 'dist_01',
    name: 'Burera',
    province: 'Northern',
    centroidLat: -1.660,
    centroidLng: 29.570,
    nirsBaseline: const {},
    riskScore: riskScore,
    riskLevel: riskLevel,
    rainfallIndex: 90,
    humidityIndex: 85,
    lossRateIndex: 24,
    soilMoistureIndex: 70,
    totalPrecipitation14dMm: 95,
    maxHumidityPct: 96,
    advisory: 'test',
    updatedAt: DateTime.utc(2026, 10, 9),
  );
}

Facility _facility({
  required String id,
  required String name,
  required double lat,
  required double lng,
  double capacity = 500,
  double available = 200,
}) {
  return Facility(
    id: id,
    name: name,
    district: 'Burera',
    type: 'silo',
    lat: lat,
    lng: lng,
    capacityTons: capacity,
    availableCapacityTons: available,
    contactName: 'Manager',
    contactPhone: '+250780000000',
    contactEmail: 'manager@agri.rw',
    operationalHours: '06:00-18:00',
  );
}

void main() {
  group('DispatchService (Innovation #2 - facility dispatch matching)', () {
    test('haversineKm returns ~0 for identical points', () {
      expect(
        DispatchService.haversineKm(-1.66, 29.57, -1.66, 29.57),
        closeTo(0.0, 0.001),
      );
    });

    test('haversineKm matches known Musanze-Kigali distance (~70 km)', () {
      final km = DispatchService.haversineKm(-1.501, 29.638, -1.94, 30.085);
      expect(km, inInclusiveRange(55.0, 100.0));
    });

    test('travel time includes driving plus handling overhead', () {
      // 35 km at 35 km/h = 60 min + 10 min handling
      expect(DispatchService.estimateTravelMinutes(35.0), 70);
    });

    test('ranks nearest facility with free capacity first', () {
      final district = _district();
      final near = _facility(id: 'f1', name: 'Near', lat: -1.661, lng: 29.571);
      final far = _facility(id: 'f2', name: 'Far', lat: -2.5, lng: 30.5);
      final full = _facility(
        id: 'f3',
        name: 'Full',
        lat: -1.660,
        lng: 29.570,
        available: 0,
      );

      final matches = DispatchService.rank(
        district: district,
        facilities: [far, full, near],
      );

      expect(matches.length, 2); // full facility excluded
      expect(matches.first.facility.id, 'f1');
      expect(matches.first.distanceKm, lessThan(5.0));
      expect(matches.first.priority, 'emergency'); // red district
    });

    test('respects topN limit', () {
      final district = _district(riskLevel: 'yellow');
      final facilities = List.generate(
        8,
        (i) => _facility(
          id: 'f$i',
          name: 'Facility $i',
          lat: -1.60 - i * 0.01,
          lng: 29.50 + i * 0.01,
        ),
      );

      final matches = DispatchService.rank(
        district: district,
        facilities: facilities,
        topN: 3,
      );

      expect(matches.length, 3);
      expect(matches.first.priority, 'recommended'); // yellow district
    });
  });
}
