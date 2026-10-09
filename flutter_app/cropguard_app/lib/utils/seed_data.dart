import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/firebase_service.dart';

class SeedData {
  /// Load and seed NISR district data from assets
  static Future<void> seedDistricts() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/nisr_sas_districts.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final districts = data['districts'] as List<dynamic>;

      await SeedService.seedData(
        districts: districts
            .map((d) => {
                  'id': d['id'],
                  'name': d['name'],
                  'province': d['province'],
                  'centroid_lat': d['centroid_lat'],
                  'centroid_lng': d['centroid_lng'],
                  'nirs_baseline': d['nirs_baseline'],
                  'facilities_count': d['facilities_count'],
                })
            .toList(),
        facilities: [], // Will be seeded separately
      );

      debugPrint('Seeded ${districts.length} districts');
    } catch (e) {
      debugPrint('Error seeding districts: $e');
    }
  }

  /// Load and seed facility data from assets
  static Future<void> seedFacilities() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/facilities.json');
      final facilities = jsonDecode(jsonString) as List<dynamic>;

      final firestore = FirebaseService.firestore;
      final batch = firestore.batch();

      for (final f in facilities) {
        batch.set(
          firestore.collection('facilities').doc(f['id']),
          {
            'id': f['id'],
            'name': f['name'],
            'district': f['district'],
            'type': f['type'],
            'lat': f['lat'],
            'lng': f['lng'],
            'capacity_tons': f['capacity_tons'],
            'available_capacity_tons': f['available_capacity_tons'],
            'contact_name': f['contact_name'],
            'contact_phone': f['contact_phone'],
            'contact_email': f['contact_email'],
            'operational_hours': f['operational_hours'],
          },
        );
      }

      await batch.commit();
      debugPrint('Seeded ${facilities.length} facilities');
    } catch (e) {
      debugPrint('Error seeding facilities: $e');
    }
  }

  /// Seed all data at once
  static Future<void> seedAll() async {
    await seedDistricts();
    await seedFacilities();
  }
}
