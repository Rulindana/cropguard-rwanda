import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Normalizes district names (lowercase, no whitespace) so our mock district
/// list and the GeoJSON names can be matched reliably.
String normalizeDistrictName(String name) {
  return name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

/// A simplified Rwanda ADM2 (district) polygon loaded from GeoJSON.
///
/// `matched` is true when the polygon's [name] exists in the app's district
/// list; unmatched polygons (mock-data artifacts) keep their marker only.
class RwaMapPolygon {
  final String name;
  final List<LatLng> points;
  final bool matched;

  const RwaMapPolygon({required this.name, required this.points, this.matched = true});

  /// Loads simplified district boundaries and converts lon/lat coordinates
  /// into [LatLng] pairs.
  static Future<List<RwaMapPolygon>> load() async {
    final raw = await rootBundle.loadString('assets/geo/rwa_adm2_simplified.geojson');
    final data = json.decode(raw) as Map<String, dynamic>;
    return loadFromJson(data as Map<String, dynamic>);
  }

  /// Parses a GeoJSON FeatureCollection directly (pure, no asset lookup) so
  /// the geometry can be unit-tested without Flutter bindings.
  static List<RwaMapPolygon> loadFromJson(Map<String, dynamic> data) {
    final features = data['features'] as List<dynamic>;
    return features.map((feature) {
      final props = feature['properties'] as Map<String, dynamic>;
      final coordinates = feature['geometry']['coordinates'] as List<dynamic>;
      final geomType = (feature['geometry']['type'] as String).toLowerCase();
      return RwaMapPolygon(
        name: props['shapeName'] as String,
        points: _decodeCoordinates(coordinates, geomType),
      );
    }).toList();
  }

  /// Unwraps GeoJSON coordinates ([Polygon] ring or [MultiPolygon] parts)
  /// into [LatLng] points. Longitude first, latitude second.
  static List<LatLng> _decodeCoordinates(List<dynamic> coordinates, String geomType) {
    if (geomType == 'polygon' && coordinates.isNotEmpty) {
      final ring = coordinates[0] as List<dynamic>;
      return ring
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();
    }
    if (geomType == 'multipolygon') {
      return coordinates
          .expand((ring) => (ring as List<dynamic>).map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())))
          .toList();
    }
    return const [];
  }
}
