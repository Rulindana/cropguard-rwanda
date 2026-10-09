import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:cropguard_app/utils/rwa_map_data.dart';

void main() {
  group('RwaMapPolygon (unit)', () {
    test('normalizeDistrictName strips case and whitespace', () {
      expect(normalizeDistrictName('  Kayonza Rural  '), 'kayonzarural');
      expect(normalizeDistrictName('  Gabiro '), 'gabiro');
      expect(normalizeDistrictName('Ngororero'), 'ngororero');
    });

    test('loadFromJson parses Polygon + MultiPolygon rings to LatLng', () async {
      final data = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {'shapeName': 'Test District'},
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [[-28.0, -1.0], [29.0, -1.0], [29.0, -2.0], [-28.0, -2.0], [-28.0, -1.0]]
              ]
            }
          },
          {
            'type': 'Feature',
            'properties': {'shapeName': 'Test District 2'},
            'geometry': {
              'type': 'MultiPolygon',
              'coordinates': [
                [[-30.0, 0.0], [-29.0, 0.0], [-29.5, 1.0], [-30.0, 0.0]],
                [[-28.0, 0.0], [-27.0, 0.0], [-27.5, 1.0], [-28.0, 0.0]]
              ]
            }
          }
        ]
      };
      final polys = RwaMapPolygon.loadFromJson(data as Map<String, dynamic>);
      expect(polys.length, 2);
      expect(polys[0].name, 'Test District');
      expect(polys[0].matched, true);
      expect(polys[0].points.length, 5); // closed ring
      expect(polys[1].name, 'Test District 2');
      expect(polys[1].matched, true);
      expect(polys[1].points.length, 8); // 2 rings x 3 points
      expect(polys[1].points[0], const LatLng(0.0, -30.0));
      expect(polys[1].points[4], const LatLng(0.0, -28.0));
    });

    test('loadFromJson ignores unknown geom types', () {
      final data = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {'shapeName': 'Bad Territory'},
            'geometry': {'type': 'Unknown', 'coordinates': []}
          }
        ]
      };
      final polys = RwaMapPolygon.loadFromJson(data as Map<String, dynamic>);
      expect(polys.length, 1);
      expect(polys[0].points.length, 0);
    });
  });
}
