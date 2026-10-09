import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../models/summary_model.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

class DistrictService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<District>> getDistrictsStream() {
    return _firestore
        .collection('districts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => District.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<List<District>> getDistrictsOnce() async {
    final snapshot = await _firestore.collection('districts').get();
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
    return _firestore
        .collection('districts')
        .doc(id)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return District.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    });
  }
}

class FacilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Facility>> getFacilitiesStream() {
    return _firestore
        .collection('facilities')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<List<Facility>> getFacilitiesOnce() async {
    final snapshot = await _firestore.collection('facilities').get();
    return snapshot.docs
        .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Future<List<Facility>> getFacilitiesByDistrict(String districtName) async {
    final snapshot = await _firestore
        .collection('facilities')
        .where('district', isEqualTo: districtName)
        .get();
    return snapshot.docs
        .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  Stream<List<Facility>> watchFacilitiesByDistrict(String districtName) {
    return _firestore
        .collection('facilities')
        .where('district', isEqualTo: districtName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Facility.fromFirestore(doc.data(), doc.id))
            .toList());
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
    final doc = await _firestore.collection('metadata').doc('risk_summary').get();
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

    debugPrint('Seeded ${districts.length} districts and ${facilities.length} facilities');
  }
}
