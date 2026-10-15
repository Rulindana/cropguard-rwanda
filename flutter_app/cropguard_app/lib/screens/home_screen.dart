import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
import '../utils/language_provider.dart';
import '../utils/rwa_map_data.dart';
import '../utils/translations.dart';
import '../widgets/risk_indicator.dart';
import 'district_detail_screen.dart';
import 'facilities_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DistrictService _districtService = DistrictService();
  final FacilityService _facilityService = FacilityService();

  List<District> _districts = [];
  List<Facility> _facilities = [];
  District? _selectedDistrict;
  bool _isLoading = true;
  String _error = '';
  List<RwaMapPolygon> _mapPolygons = const [];

  // Real weather data
  Map<String, dynamic>? _weather;
  bool _weatherLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final districts = await _districtService.getDistrictsOnce();
      final facilities = await _facilityService.getFacilitiesOnce();
      if (mounted) {
        setState(() {
          _districts = districts..sort((a, b) => a.name.compareTo(b.name));
          _facilities = facilities;
          _isLoading = false;
        });
      }
      await Future.wait([_loadMapPolygons(), _fetchWeather(-1.9441, 30.0619)]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMapPolygons() async {
    try {
      final polygons = await RwaMapPolygon.load();
      if (mounted) setState(() => _mapPolygons = polygons);
    } catch (_) {}
  }

  /// Fetch real weather from Open-Meteo for a given lat/lng
  Future<void> _fetchWeather(double lat, double lng) async {
    if (_weatherLoading) return;
    setState(() => _weatherLoading = true);
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,relative_humidity_2m,'
        'precipitation,wind_speed_10m,weather_code'
        '&wind_speed_unit=kmh&timezone=Africa%2FKigali',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (mounted) setState(() => _weather = data['current']);
      }
    } catch (_) {
      // Keep static fallback if API fails
    } finally {
      if (mounted) setState(() => _weatherLoading = false);
    }
  }

  List<Polygon> _buildPolygonList() {
    if (_mapPolygons.isEmpty) return const [];
    final byKey = {
      for (final d in _districts) normalizeDistrictName(d.name): d,
    };
    final hasSelection = _selectedDistrict != null;

    return _mapPolygons.map((p) {
      final d = byKey[normalizeDistrictName(p.name)];
      final isSelected =
          _selectedDistrict != null &&
          normalizeDistrictName(_selectedDistrict!.name) ==
              normalizeDistrictName(p.name);

      Color fill;
      Color border;
      double borderWidth;

      if (hasSelection && !isSelected) {
        // ✅ ALL non-selected districts → greyed out
        fill = Colors.grey.withOpacity(0.22);
        border = Colors.white.withOpacity(0.25);
        borderWidth = 0.8;
      } else {
        // No selection active OR this is the selected district → show full risk color
        if (d == null) {
          fill = Colors.grey.withOpacity(0.3);
          border = Colors.white.withOpacity(0.4);
          borderWidth = 1.0;
        } else {
          switch (d.riskLevel) {
            case 'red':
              fill = const Color(
                0xFFDC2626,
              ).withOpacity(isSelected ? 0.95 : 0.65);
              break;
            case 'yellow':
              fill = const Color(
                0xFFF59E0B,
              ).withOpacity(isSelected ? 0.95 : 0.60);
              break;
            default:
              fill = const Color(
                0xFF16A34A,
              ).withOpacity(isSelected ? 0.95 : 0.55);
          }
          border = isSelected ? Colors.white : Colors.white.withOpacity(0.55);
          borderWidth = isSelected ? 3.0 : 1.2;
        }
      }

      return Polygon(
        points: p.points,
        color: fill,
        borderColor: border,
        borderStrokeWidth: borderWidth,
      );
    }).toList();
  }

  void _onDistrictTap(District district) {
    setState(() {
      // Tap same district again → deselect (all colors come back)
      if (_selectedDistrict?.id == district.id) {
        _selectedDistrict = null;
      } else {
        _selectedDistrict = district;
        _fetchWeather(district.centroidLat, district.centroidLng);
      }
    });
  }

  String _weatherDesc(int? code) {
    if (code == null) return 'Partly Cloudy';
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Drizzle / Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain Showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Partly Cloudy';
  }

  String _weatherDescRw(int? code) {
    if (code == null) return 'Ibicu bike';
    if (code == 0) return 'Izuba rirahije';
    if (code <= 3) return 'Ibicu bike';
    if (code <= 48) return 'Igihu';
    if (code <= 67) return 'Imvura';
    if (code <= 77) return 'Theluji';
    if (code <= 82) return 'Imvura nyinshi';
    if (code <= 99) return 'Inkuba';
    return 'Ibicu bike';
  }

  String _weatherDescFr(int? code) {
    if (code == null) return 'Partiellement Nuageux';
    if (code == 0) return 'Ciel Dégagé';
    if (code <= 3) return 'Partiellement Nuageux';
    if (code <= 48) return 'Brouillard';
    if (code <= 67) return 'Pluie';
    if (code <= 77) return 'Neige';
    if (code <= 82) return 'Averses';
    if (code <= 99) return 'Orage';
    return 'Partiellement Nuageux';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error.isNotEmpty) {
      return Center(child: Text(_error));
    }

    if (isDesktop) {
      return _buildDesktopLayout(lang);
    }
    return _buildMobileLayout(lang);
  }

  // ── DESKTOP: map center + left district list + right detail panel ──────────
  Widget _buildDesktopLayout(AppStrings lang) {
    return Row(
      children: [
        // LEFT: scrollable district list
        Container(
          width: 200,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              right: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  lang.thirtyDistricts,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: _districts.length,
                  itemBuilder: (context, i) {
                    final d = _districts[i];
                    final isSelected = _selectedDistrict?.id == d.id;
                    return InkWell(
                      onTap: () => _onDistrictTap(d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? AppColors.primary.withOpacity(0.15)
                                  : Colors.transparent,
                          border:
                              isSelected
                                  ? const Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
                                      width: 3,
                                    ),
                                  )
                                  : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: d.riskColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // CENTER: full-height map
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(-1.9403, 29.8739),
                  initialZoom: 8.8,
                  minZoom: 7.5,
                  maxZoom: 16.0,
                  // Tap on empty area → deselect district (all colors come back)
                  onTap: (_, __) => setState(() => _selectedDistrict = null),
                  // Restrict pan to Rwanda bounds
                  cameraConstraint: CameraConstraint.containCenter(
                    bounds: LatLngBounds(
                      LatLng(-2.85, 28.85),
                      LatLng(-1.05, 31.25),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    // ✅ ESRI Satellite imagery — free, no API key required
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.cropguard.cropguard_app',
                    maxNativeZoom: 19,
                    maxZoom: 19,
                  ),
                  PolygonLayer(polygons: _buildPolygonList()),
                  MarkerLayer(
                    markers:
                        _districts.map((d) {
                          final isSelected = _selectedDistrict?.id == d.id;
                          // Build crops tooltip text
                          final cropList = d.crops
                              .take(4)
                              .map(
                                (c) =>
                                    '${c['icon']} ${c['name']}: ${NumberFormatter.tons(c['tons'] as double)}',
                              )
                              .join('\n');
                          return Marker(
                            point: LatLng(d.centroidLat, d.centroidLng),
                            width: isSelected ? 48 : 36,
                            height: isSelected ? 48 : 36,
                            child: GestureDetector(
                              onTap: () => _onDistrictTap(d),
                              child: Tooltip(
                                message:
                                    '${d.name}\nRisk: ${d.riskScore.toStringAsFixed(0)}%\n$cropList',
                                preferBelow: false,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: d.riskColor.withOpacity(0.9),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: isSelected ? 3 : 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: d.riskColor.withOpacity(0.5),
                                        blurRadius: isSelected ? 12 : 6,
                                        spreadRadius: isSelected ? 3 : 1,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      d.riskIcon,
                                      style: TextStyle(
                                        fontSize: isSelected ? 20 : 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              // Legend
              Positioned(bottom: 16, left: 16, child: _MapLegend(lang: lang)),
            ],
          ),
        ),

        // RIGHT: district detail panel
        if (_selectedDistrict != null)
          Container(
            width: 300,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                left: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: _buildDetailPanel(_selectedDistrict!, lang),
          ),
      ],
    );
  }

  // ── MOBILE: map top, district selector below ──────────────────────────────
  Widget _buildMobileLayout(AppStrings lang) {
    final screenHeight = MediaQuery.of(context).size.height;
    // Collapse map to 220px when a district is selected so the detail panel is fully visible
    final mapHeight = _selectedDistrict != null ? 220.0 : screenHeight * 0.55;

    return Column(
      children: [
        // Map — collapses when district selected
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: mapHeight,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(-1.9403, 29.8739),
                  initialZoom: 8.0,
                  minZoom: 7.5,
                  maxZoom: 16.0,
                  // Tap on empty area → deselect district
                  onTap: (_, __) => setState(() => _selectedDistrict = null),
                  cameraConstraint: CameraConstraint.containCenter(
                    bounds: LatLngBounds(
                      LatLng(-2.85, 28.85),
                      LatLng(-1.05, 31.25),
                    ),
                  ),
                ),
                children: [
                  TileLayer(
                    // ✅ ESRI Satellite imagery
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.cropguard.cropguard_app',
                    maxNativeZoom: 19,
                    maxZoom: 19,
                  ),
                  PolygonLayer(polygons: _buildPolygonList()),
                  MarkerLayer(
                    markers:
                        _districts.map((d) {
                          return Marker(
                            point: LatLng(d.centroidLat, d.centroidLng),
                            width: 36,
                            height: 36,
                            child: GestureDetector(
                              onTap: () => _onDistrictTap(d),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: d.riskColor.withOpacity(0.9),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: d.riskColor.withOpacity(0.5),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    d.riskIcon,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
              Positioned(bottom: 12, left: 12, child: _MapLegend(lang: lang)),
              // Expand/collapse hint button when district is selected
              if (_selectedDistrict != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDistrict = null),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.expand, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            lang.languageCode == 'rw' ? 'Garagaza ikarita' : lang.languageCode == 'fr' ? 'Agrandir carte' : 'Expand map',
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // District list + detail
        Expanded(
          child:
              _selectedDistrict != null
                  ? SingleChildScrollView(
                    child: _buildDetailPanel(_selectedDistrict!, lang),
                  )
                  : _buildDistrictListMobile(lang),
        ),
      ],
    );
  }

  Widget _buildDistrictListMobile(AppStrings lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            lang.selectDistrict,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _districts.length,
            itemBuilder: (context, i) {
              final d = _districts[i];
              return ListTile(
                dense: true,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: d.riskColor,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(d.name, style: TextStyle(fontSize: 13)),
                trailing: Text(
                  '${d.riskScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: d.riskColor,
                  ),
                ),
                onTap: () => _onDistrictTap(d),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── DETAIL PANEL ─────────────────────────────────────────────────────────
  Widget _buildDetailPanel(District d, AppStrings lang) {
    final code = _weather?['weather_code'] as int?;
    final temp =
        (_weather?['temperature_2m'] as num?)?.toStringAsFixed(0) ?? '22';
    final humidity =
        (_weather?['relative_humidity_2m'] as num?)?.toStringAsFixed(0) ??
        '${d.maxHumidityPct.toStringAsFixed(0)}';
    final precip =
        (_weather?['precipitation'] as num?)?.toStringAsFixed(1) ?? '0.0';
    final wind =
        (_weather?['wind_speed_10m'] as num?)?.toStringAsFixed(0) ?? '12';
    final desc =
        lang.languageCode == 'rw'
            ? _weatherDescRw(code)
            : lang.languageCode == 'fr'
            ? _weatherDescFr(code)
            : _weatherDesc(code);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Text(d.riskIcon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(d.province, style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              // Close button
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _selectedDistrict = null),
              ),
            ],
          ),

          const Divider(color: AppColors.divider),

          // Real weather row
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud,
                  color: AppColors.weatherCloudy,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$temp°C',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(desc, style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('💧 $humidity%', style: TextStyle(fontSize: 11)),
                    Text('🌧 $precip mm', style: TextStyle(fontSize: 11)),
                    Text('💨 $wind km/h', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Risk score
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: d.riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: d.riskColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.riskScore,
                        style: TextStyle(fontSize: 11),
                      ),
                      Text(
                        '${d.riskScore.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: d.riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: d.riskScore / 100,
                    strokeWidth: 5,
                    backgroundColor: Colors.grey.shade700,
                    valueColor: AlwaysStoppedAnimation(d.riskColor),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Crop volumes
          Text(
            lang.expectedHarvestVol,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _cropChip(
                '🌽',
                lang.languageCode == 'rw'
                    ? 'Ibigori'
                    : lang.languageCode == 'fr'
                    ? 'Maïs'
                    : 'Maize',
                d.maizeTons,
              ),
              _cropChip(
                '🫘',
                lang.languageCode == 'rw'
                    ? 'Ibishyimbo'
                    : lang.languageCode == 'fr'
                    ? 'Haricots'
                    : 'Beans',
                d.beansTons,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _cropChip(
                '🥔',
                lang.languageCode == 'rw'
                    ? 'Ibirayi'
                    : lang.languageCode == 'fr'
                    ? 'Pommes'
                    : 'Potato',
                d.irishPotatoesTons,
              ),
              _cropChip(
                '🌿',
                lang.languageCode == 'rw'
                    ? 'Imyumbati'
                    : lang.languageCode == 'fr'
                    ? 'Manioc'
                    : 'Cassava',
                d.cassavaTons,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAdvisoryDialog(context, d, lang),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: Text(
                    lang.languageCode == 'rw'
                        ? 'Inama'
                        : lang.languageCode == 'fr'
                        ? 'Conseil'
                        : 'Advisory',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: d.riskColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => FacilitiesListScreen(
                              district: d,
                              facilities:
                                  _facilities
                                      .where((f) => f.district == d.name)
                                      .toList(),
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.storage_outlined, size: 16),
                  label: Text(lang.navFacilities),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: d.riskColor),
                    foregroundColor: d.riskColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // View full detail button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DistrictDetailScreen(district: d),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_new, size: 14),
              label: Text(
                lang.languageCode == 'rw'
                    ? 'Reba Byose'
                    : lang.languageCode == 'fr'
                    ? 'Voir Tout'
                    : 'View Full Detail',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cropChip(String icon, String label, double tons) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '$label: ${NumberFormatter.tons(tons)}',
                style: TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fixed: takes BuildContext explicitly so dialog always closes correctly
  void _showAdvisoryDialog(BuildContext context, District d, AppStrings lang) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Text(d.riskIcon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang.languageCode == 'rw'
                        ? 'Inama y\'Ingaruka: ${d.name}'
                        : lang.languageCode == 'fr'
                        ? 'Conseil de Risque: ${d.name}'
                        : 'Risk Advisory: ${d.name}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: d.riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: d.riskColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      d.advisory,
                      style: TextStyle(
                        color: d.riskColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.languageCode == 'rw'
                        ? 'Isuzuma Ryimbitse'
                        : lang.languageCode == 'fr'
                        ? 'Évaluation Détaillée'
                        : 'Detailed Assessment',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _advisoryRow(
                    lang.languageCode == 'rw'
                        ? 'Indice y\'Imvura'
                        : lang.languageCode == 'fr'
                        ? 'Indice Pluie'
                        : 'Rainfall Index',
                    '${d.rainfallIndex.toStringAsFixed(1)} / 100',
                  ),
                  _advisoryRow(
                    lang.languageCode == 'rw'
                        ? 'Indice y\'Ubuhehere'
                        : lang.languageCode == 'fr'
                        ? 'Indice Humidité'
                        : 'Humidity Index',
                    '${d.humidityIndex.toStringAsFixed(1)} / 100',
                  ),
                  _advisoryRow(
                    lang.languageCode == 'rw'
                        ? 'Indice y\'Gutakaza'
                        : lang.languageCode == 'fr'
                        ? 'Indice Perte'
                        : 'Loss Rate Index',
                    '${d.lossRateIndex.toStringAsFixed(1)} / 100',
                  ),
                  _advisoryRow(
                    lang.languageCode == 'rw'
                        ? 'Ubunyihu bw\'Ubutaka'
                        : lang.languageCode == 'fr'
                        ? 'Humidité Sol'
                        : 'Soil Moisture',
                    '${d.soilMoistureIndex.toStringAsFixed(1)} / 100',
                  ),
                  _advisoryRow(
                    lang.rainfall14d,
                    '${d.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
                  ),
                  _advisoryRow(
                    lang.languageCode == 'rw'
                        ? 'Ubuhehere Bwisumbuye'
                        : lang.languageCode == 'fr'
                        ? 'Humidité Max'
                        : 'Peak Humidity',
                    '${d.maxHumidityPct.toStringAsFixed(0)}%',
                  ),
                ],
              ),
            ),
            actions: [
              // ✅ Fixed: uses dialogContext so it always closes
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  lang.languageCode == 'rw'
                      ? 'Funga'
                      : lang.languageCode == 'fr'
                      ? 'Fermer'
                      : 'Close',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
    );
  }

  Widget _advisoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Text(
            value,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── MAP LEGEND ────────────────────────────────────────────────────────────────

class _MapLegend extends StatelessWidget {
  final AppStrings lang;
  const _MapLegend({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xDD0B1617),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _LegendRow(color: const Color(0xFF16A34A), label: lang.mapLowRisk),
          const SizedBox(height: 4),
          _LegendRow(
            color: const Color(0xFFF59E0B),
            label: lang.mapModerateRisk,
          ),
          const SizedBox(height: 4),
          _LegendRow(color: const Color(0xFFDC2626), label: lang.mapHighRisk),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}
