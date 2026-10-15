import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../models/summary_model.dart';

/// Production Firebase config for project nisr-b06b6 (copied from the Firebase
/// Web console). Kept in this service so dart2js can resolve it at compile
/// time without relying on app-root generated files.
const FirebaseOptions _webConfig = FirebaseOptions(
  apiKey: 'AIzaSyAGmqQfvWTGZfRSEd3oMB0Lhl-iGUJ76',
  authDomain: 'nisr-b06b6.firebaseapp.com',
  projectId: 'nisr-b06b6',
  storageBucket: 'nisr-b06b6.firebasestorage.app',
  messagingSenderId: '741567324628',
  appId: '1:741567324628:web:50d00b28f343014447f641',
  measurementId: 'G-KZ536EGN76',
);

class FirebaseService {
  static Future<void> initialize() async {
    // Firebase is optional: without a valid config the app runs fully
    // offline using the local seed data (no crash, no user-facing error).
    try {
      await Firebase.initializeApp(options: _webConfig);
    } catch (e) {
      debugPrint('CropGuard: Firebase not configured, running offline: $e');
    }
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

class DistrictService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load districts from bundled risk_scores.json (offline fallback).
  /// risk_scores.json uses different key names than Firestore, so we remap them.
  static Future<List<District>> _loadLocalDistricts() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/risk_scores.json',
      );
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final List<dynamic> districts = data['districts'] ?? [];
      return districts.map((raw) {
        final d = raw as Map<String, dynamic>;
        final risk = d['risk'] as Map<String, dynamic>? ?? {};
        final weather = d['weather'] as Map<String, dynamic>? ?? {};
        final nb = d['nirs_baseline'] as Map<String, dynamic>? ?? {};

        // risk_trend can be a flat String OR a Map{trend, risk_delta, previous_risk_score}
        final rtRaw = d['risk_trend'];
        String riskTrendStr = 'baseline';
        double riskDelta = 0.0;
        double? prevScore;
        if (rtRaw is String) {
          riskTrendStr = rtRaw;
          riskDelta = (d['risk_delta'] as num?)?.toDouble() ?? 0.0;
          prevScore = (d['previous_risk_score'] as num?)?.toDouble();
        } else if (rtRaw is Map) {
          final rt = rtRaw as Map<String, dynamic>;
          riskTrendStr = rt['trend'] ?? rt['risk_trend'] ?? 'baseline';
          riskDelta = (rt['risk_delta'] as num?)?.toDouble() ?? 0.0;
          prevScore = (rt['previous_risk_score'] as num?)?.toDouble();
        }

        // precipitation & humidity: try risk{} first (newer format), fall back to weather{}
        final precip =
            (risk['total_precipitation_14d_mm'] as num?)?.toDouble() ??
            (weather['total_precipitation_14d_mm'] as num?)?.toDouble() ??
            0.0;
        final maxHumid =
            (risk['max_humidity_pct'] as num?)?.toDouble() ??
            (weather['max_humidity_pct'] as num?)?.toDouble() ??
            0.0;

        final mapped = <String, dynamic>{
          'name': d['district_name'] ?? d['name'] ?? '',
          'province': d['province'] ?? '',
          'centroid_lat': d['centroid_lat'] ?? 0.0,
          'centroid_lng': d['centroid_lng'] ?? 0.0,
          'nirs_baseline': nb,
          'risk_score': (risk['risk_score'] as num?)?.toDouble() ?? 0.0,
          'risk_level': risk['level'] ?? risk['risk_level'] ?? 'green',
          'rainfall_index': (risk['rainfall_index'] as num?)?.toDouble() ?? 0.0,
          'humidity_index': (risk['humidity_index'] as num?)?.toDouble() ?? 0.0,
          'loss_rate_index':
              (risk['loss_rate_index'] as num?)?.toDouble() ?? 0.0,
          'soil_moisture_index':
              (risk['soil_moisture_index'] as num?)?.toDouble() ?? 0.0,
          'total_precipitation_14d_mm': precip,
          'max_humidity_pct': maxHumid,
          'advisory': d['advisory'] ?? '',
          'updated_at': d['updated_at'] ?? DateTime.now().toIso8601String(),
          'risk_delta': riskDelta,
          'risk_trend': riskTrendStr,
          'previous_risk_score': prevScore,
        };
        final id = d['district_id'] ?? d['id'] ?? mapped['name'];
        return District.fromFirestore(mapped, id as String);
      }).toList();
    } catch (e) {
      debugPrint('CropGuard: failed to load local districts: $e');
      return [];
    }
  }

  Stream<List<District>> getDistrictsStream() {
    return _firestore.collection('districts').snapshots().asyncMap((
      snapshot,
    ) async {
      if (snapshot.docs.isEmpty) {
        return _loadLocalDistricts();
      }
      return snapshot.docs
          .map((doc) => District.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  /// Load districts from bundled JSON immediately (no network needed).
  Future<List<District>> getDistrictsLocal() => _loadLocalDistricts();

  Future<List<District>> getDistrictsOnce() async {
    final snapshot = await _firestore.collection('districts').get();
    if (snapshot.docs.isEmpty) {
      return _loadLocalDistricts();
    }
    return snapshot.docs
        .map((doc) => District.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<District?> getDistrictById(String id) async {
    final doc = await _firestore.collection('districts').doc(id).get();
    if (doc.exists) {
      return District.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<District?> watchDistrictById(String id) {
    return _firestore.collection('districts').doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return District.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }
}

class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load facilities from bundled JSON immediately (no network needed).
  static Future<List<Facility>> _loadLocalFacilities() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/facilities.json',
      );
      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      return list.map((raw) {
        final d = raw as Map<String, dynamic>;
        final id = d['id'] ?? d['name'] ?? '';
        return Facility.fromFirestore(d, id as String);
      }).toList();
    } catch (e) {
      debugPrint('CropGuard: failed to load local facilities: $e');
      return [];
    }
  }

  Future<List<Facility>> getFacilitiesLocal() => _loadLocalFacilities();

  Stream<List<Facility>> getFacilitiesStream() {
    return _firestore
        .collection('facilities')
        .snapshots()
        .asyncMap((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs
                .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
                .toList();
          }
          return _loadLocalFacilities();
        });
  }

  Future<List<Facility>> getFacilitiesOnce() async {
    try {
      final snapshot = await _firestore.collection('facilities').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint('CropGuard: Firestore facilities fetch failed, using local: $e');
    }
    // Fall back to bundled local JSON
    return _loadLocalFacilities();
  }

  Future<List<Facility>> getFacilitiesByDistrict(String districtName) async {
    try {
      final snapshot =
          await _firestore
              .collection('facilities')
              .where('district', isEqualTo: districtName)
              .get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint('CropGuard: Firestore facilities by district failed, using local: $e');
    }
    // Fall back to local JSON and filter by district name
    final all = await _loadLocalFacilities();
    return all
        .where((f) => f.district.toLowerCase() == districtName.toLowerCase())
        .toList();
  }

  Stream<List<Facility>> watchFacilitiesByDistrict(String districtName) {
    return _firestore
        .collection('facilities')
        .where('district', isEqualTo: districtName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
                  .toList(),
        );
  }
}

class SummaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<RiskSummary?> getSummaryStream() {
    return _firestore
        .collection('metadata')
        .doc('risk_summary')
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return RiskSummary.fromFirestore(doc.data()!);
          }
          return null;
        });
  }

  Future<RiskSummary?> getSummaryOnce() async {
    final doc =
        await _firestore.collection('metadata').doc('risk_summary').get();
    if (doc.exists) {
      return RiskSummary.fromFirestore(doc.data()!);
    }
    return null;
  }
}

class SeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seed initial data into Firestore from local JSON files.
  /// Run this once when setting up the app for the first time.
  static Future<void> seedData({
    required List<Map<String, dynamic>> districts,
    required List<Map<String, dynamic>> facilities,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // Seed districts
    final districtsBatch = firestore.batch();
    for (final district in districts) {
      final docRef = firestore.collection('districts').doc(district['id']);
      districtsBatch.set(docRef, district);
    }
    await districtsBatch.commit();

    // Seed facilities
    final facilitiesBatch = firestore.batch();
    for (final facility in facilities) {
      final docRef = firestore.collection('facilities').doc(facility['id']);
      facilitiesBatch.set(docRef, facility);
    }
    await facilitiesBatch.commit();

    debugPrint(
      'Seeded ${districts.length} districts and ${facilities.length} facilities',
    );
  }
}
