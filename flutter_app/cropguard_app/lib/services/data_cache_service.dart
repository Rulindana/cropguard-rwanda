import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../models/summary_model.dart';

/// Offline-first cache for CropGuard's core datasets.
///
/// On first successful load, snapshots [districts], [facilities], and an
/// optional [summary] to a JSON file in the app's local documents directory.
/// Subsequent calls prefer the live data you pass in, but if that fails or
/// the app is offline, the cached snapshot is returned so the screens can
/// still render real data instead of empty states.
///
/// The cache also exposes [lastUpdated] so the stale-data banner can show
/// "last refreshed Xh ago".
class DataCacheService {
  static const _cacheFileName = 'cropguard_cache.json';

  static final DataCacheService instance = DataCacheService._internal();

  DateTime? _lastUpdated;
  bool _cacheExists = false;

  DataCacheService._internal();

  /// Whether a cache snapshot exists on disk.
  bool get cacheExists => _cacheExists;

  /// When the cache was last refreshed, or null if no cache exists.
  DateTime? get lastUpdated => _lastUpdated;

  /// Human-readable "last refreshed X" string for the stale-data banner.
  String lastUpdatedLabel() {
    final t = _lastUpdated;
    if (t == null) return 'Not available offline';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Persist [districts], [facilities], and an optional [summary] to disk.
  Future<void> saveCache({
    required List<District> districts,
    required List<Facility> facilities,
    RiskSummary? summary,
  }) async {
    if (kIsWeb) return; // path_provider not supported on web
    try {
      final docs = await getApplicationDocumentsDirectory();
      final file = File('${docs.path}/$_cacheFileName');
      final payload = CachePayload(
        savedAt: DateTime.now().toIso8601String(),
        districts: _encodeDistricts(districts),
        facilities: _encodeFacilities(facilities),
        summary: summary?.toJson(),
      );
      await file.writeAsString(jsonEncode(payload.toMap()));
      _lastUpdated = DateTime.now();
      _cacheExists = true;
    } catch (e) {
      debugPrint('CropGuard: failed to save cache: $e');
    }
  }

  /// Read the cached snapshot from disk. Returns null if there is no cache.
  Future<CachePayload?> loadCache() async {
    if (kIsWeb) return null; // path_provider not supported on web
    try {
      final docs = await getApplicationDocumentsDirectory();
      final file = File('${docs.path}/$_cacheFileName');
      if (!await file.exists()) {
        _cacheExists = false;
        return null;
      }
      final raw = await file.readAsString();
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final payload = CachePayload.fromMap(map);
      _lastUpdated = DateTime.tryParse(payload.savedAt);
      _cacheExists = _lastUpdated != null;
      return payload;
    } catch (e) {
      debugPrint('CropGuard: failed to load cache: $e');
      _cacheExists = false;
      return null;
    }
  }

  /// Load districts from the cache (offline fallback).
  Future<List<District>> loadCachedDistricts() async {
    final payload = await loadCache();
    if (payload == null || payload.districts.isEmpty) return [];
    return payload.districts
        .map((m) => District.fromFirestore(m, m['id'] as String))
        .toList();
  }

  /// Load facilities from the cache (offline fallback).
  Future<List<Facility>> loadCachedFacilities() async {
    final payload = await loadCache();
    if (payload == null || payload.facilities.isEmpty) return [];
    return payload.facilities
        .map((m) => Facility.fromFirestore(m, m['id'] as String))
        .toList();
  }

  /// Load the cached summary (offline fallback).
  Future<RiskSummary?> loadCachedSummary() async {
    final payload = await loadCache();
    if (payload == null || payload.summary == null) return null;
    return RiskSummary.fromJson(payload.summary!);
  }

  /// Clear the on-disk cache. Useful when the user forces a refresh.
  Future<void> clearCache() async {
    if (kIsWeb) return;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final file = File('${docs.path}/$_cacheFileName');
      if (await file.exists()) await file.delete();
      _cacheExists = false;
      _lastUpdated = null;
    } catch (e) {
      debugPrint('CropGuard: failed to clear cache: $e');
    }
  }

  // Encode/decode helpers -------------------------------------------------
  static List<Map<String, dynamic>> _encodeDistricts(List<District> districts) {
    return districts.map((d) {
      return {
        'id': d.id,
        'name': d.name,
        'province': d.province,
        'centroid_lat': d.centroidLat,
        'centroid_lng': d.centroidLng,
        'nirs_baseline': d.nirsBaseline,
        'risk_score': d.riskScore,
        'risk_level': d.riskLevel,
        'rainfall_index': d.rainfallIndex,
        'humidity_index': d.humidityIndex,
        'loss_rate_index': d.lossRateIndex,
        'soil_moisture_index': d.soilMoistureIndex,
        'total_precipitation_14d_mm': d.totalPrecipitation14dMm,
        'max_humidity_pct': d.maxHumidityPct,
        'advisory': d.advisory,
        'updated_at': d.updatedAt.toIso8601String(),
        'risk_delta': d.riskDelta,
        'risk_trend': d.riskTrend,
        'previous_risk_score': d.previousRiskScore,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _encodeFacilities(
    List<Facility> facilities,
  ) {
    return facilities.map((f) {
      return {
        'id': f.id,
        'name': f.name,
        'district': f.district,
        'type': f.type,
        'lat': f.lat,
        'lng': f.lng,
        'capacity_tons': f.capacityTons,
        'available_capacity_tons': f.availableCapacityTons,
        'contact_name': f.contactName,
        'contact_phone': f.contactPhone,
        'contact_email': f.contactEmail,
        'operational_hours': f.operationalHours,
      };
    }).toList();
  }
}

/// The shape written to disk by [DataCacheService.saveCache] and read back
/// by [DataCacheService.loadCache].
class CachePayload {
  final String savedAt;
  final List<Map<String, dynamic>> districts;
  final List<Map<String, dynamic>> facilities;
  final Map<String, dynamic>? summary;

  CachePayload({
    required this.savedAt,
    required this.districts,
    required this.facilities,
    this.summary,
  });

  Map<String, dynamic> toMap() => {
    'saved_at': savedAt,
    'districts': districts,
    'facilities': facilities,
    'summary': summary,
  };

  factory CachePayload.fromMap(Map<String, dynamic> map) {
    return CachePayload(
      savedAt: map['saved_at'] as String? ?? '',
      districts:
          (map['districts'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      facilities:
          (map['facilities'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      summary: map['summary'] as Map<String, dynamic>?,
    );
  }
}
