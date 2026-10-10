import 'dart:async';
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
import '../utils/year_provider.dart';
import '../widgets/holographic_card.dart';
import 'main_scaffold.dart';
import 'district_detail_screen.dart';

// ── Widget ──────────────────────────────────────────────────────────────────

class DashboardScreen extends StatefulWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final District? selectedDistrict;
  final ValueChanged<NavItem>? onNavigate;

  const DashboardScreen({
    super.key,
    required this.districts,
    required this.facilities,
    this.selectedDistrict,
    this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Live clock
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  // Map polygons
  List<RwaMapPolygon> _mapPolygons = [];
  District? _hoveredDistrict;

  // Auto-refresh: listen to Firestore stream
  late StreamSubscription<List<District>> _districtSub;
  List<District> _liveDistricts = [];

  @override
  void initState() {
    super.initState();
    _liveDistricts = widget.districts;

    // Real-time clock — updates every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    // Subscribe to Firestore live stream for auto-refresh
    _districtSub = DistrictService().getDistrictsStream().listen((districts) {
      if (mounted && districts.isNotEmpty) {
        setState(() => _liveDistricts = districts);
      }
    });

    _loadPolygons();
  }

  Future<void> _loadPolygons() async {
    try {
      final polygons = await RwaMapPolygon.load();
      if (mounted) setState(() => _mapPolygons = polygons);
    } catch (_) {}
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _districtSub.cancel();
    super.dispose();
  }

  List<Polygon> _buildPolygons() {
    if (_mapPolygons.isEmpty) return [];
    final byKey = {
      for (final d in _liveDistricts) normalizeDistrictName(d.name): d
    };
    return _mapPolygons.map((p) {
      final d = byKey[normalizeDistrictName(p.name)];
      final isHovered = _hoveredDistrict?.name == p.name;
      Color fill;
      if (d == null) {
        fill = Colors.grey.withOpacity(0.25);
      } else {
        switch (d.riskLevel) {
          case 'red':
            fill = const Color(0xFFDC2626).withOpacity(isHovered ? 0.85 : 0.65);
            break;
          case 'yellow':
            fill = const Color(0xFFF59E0B).withOpacity(isHovered ? 0.85 : 0.60);
            break;
          default:
            fill = const Color(0xFF16A34A).withOpacity(isHovered ? 0.75 : 0.50);
        }
      }
      return Polygon(
        points: p.points,
        color: fill,
        borderColor: Colors.white.withOpacity(0.6),
        borderStrokeWidth: isHovered ? 2.5 : 1.2,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    if (_liveDistricts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    return isDesktop
        ? _DesktopDashboard(
            districts: _liveDistricts,
            facilities: widget.facilities,
            polygons: _buildPolygons(),
            now: _now,
            onNavigate: widget.onNavigate,
            onDistrictHover: (d) => setState(() => _hoveredDistrict = d),
          )
        : _MobileDashboard(
            districts: _liveDistricts,
            facilities: widget.facilities,
            polygons: _buildPolygons(),
            now: _now,
            onNavigate: widget.onNavigate,
          );
  }
}

// ── DESKTOP ─────────────────────────────────────────────────────────────────

class _DesktopDashboard extends StatelessWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final List<Polygon> polygons;
  final DateTime now;
  final ValueChanged<NavItem>? onNavigate;
  final ValueChanged<District?> onDistrictHover;

  const _DesktopDashboard({
    required this.districts,
    required this.facilities,
    required this.polygons,
    required this.now,
    required this.onDistrictHover,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...districts]
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Row 1: Weather + Map (center) + Right Panel ──────────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── CENTER: Weather on top, Map below ──────────────────────
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      // Weather card
                      _WeatherCard(district: districts.first, now: now),
                      const SizedBox(height: 12),
                      // ✅ Taller map — fixed 560px height
                      SizedBox(
                        height: 560,
                        child: _MapCard(
                          districts: districts,
                          polygons: polygons,
                          onNavigate: onNavigate,
                          onDistrictHover: onDistrictHover,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── RIGHT PANEL: Crop Yield + Risk Indicators ──────────────
                SizedBox(
                  width: 320,
                  child: Column(
                    children: [
                      _CropYieldCard(districts: districts),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 380,
                        child: _RiskIndicatorsCard(
                          districts: districts,
                          onNavigate: onNavigate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Row 2: Recent Alerts bar ──────────────────────────────────────
          _AlertsBar(districts: sorted, onNavigate: onNavigate),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── MOBILE ───────────────────────────────────────────────────────────────────

class _MobileDashboard extends StatelessWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final List<Polygon> polygons;
  final DateTime now;
  final ValueChanged<NavItem>? onNavigate;

  const _MobileDashboard({
    required this.districts,
    required this.facilities,
    required this.polygons,
    required this.now,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...districts]
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    final highRisk = sorted.firstOrNull;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Post-harvest alert banner
          if (highRisk != null && highRisk.riskLevel == 'red')
            _MobileAlertBanner(district: highRisk, onNavigate: onNavigate),

          const SizedBox(height: 12),
          _WeatherCard(district: districts.first, now: now, isMobile: true),
          const SizedBox(height: 12),

          // Map
          SizedBox(
            height: 380,
            child: _MapCard(
              districts: districts,
              polygons: polygons,
              onNavigate: onNavigate,
              isMobile: true,
              onDistrictHover: (_) {},
            ),
          ),

          const SizedBox(height: 12),
          _CropYieldCard(districts: districts, isMobile: true),
          const SizedBox(height: 12),
          _RiskIndicatorsCard(districts: districts, onNavigate: onNavigate, isMobile: true),
          const SizedBox(height: 12),

          // Alerts horizontal scroll
          _AlertsBar(districts: sorted, onNavigate: onNavigate, isMobile: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── WEATHER CARD ─────────────────────────────────────────────────────────────

class _WeatherCard extends StatefulWidget {
  final District district;
  final DateTime now;
  final bool isMobile;

  const _WeatherCard(
      {required this.district, required this.now, this.isMobile = false});

  @override
  State<_WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<_WeatherCard> {
  Map<String, dynamic>? _weather;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final lat = widget.district.centroidLat;
      final lng = widget.district.centroidLng;
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,relative_humidity_2m,'
        'precipitation,wind_speed_10m,weather_code'
        '&wind_speed_unit=kmh&timezone=Africa%2FKigali',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200 && mounted) {
        final data = jsonDecode(resp.body);
        setState(() {
          _weather = data['current'];
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _weatherDesc(int? code, String langCode) {
    String en, rw, fr;
    if (code == null || (code >= 0 && code <= 3)) {
      en = 'Partly Cloudy'; rw = 'Ibicu bike'; fr = 'Partiellement Nuageux';
    } else if (code <= 48) {
      en = 'Foggy'; rw = 'Igihu'; fr = 'Brouillard';
    } else if (code <= 67) {
      en = 'Rainy'; rw = 'Imvura'; fr = 'Pluvieux';
    } else if (code <= 82) {
      en = 'Rain Showers'; rw = 'Imvura nyinshi'; fr = 'Averses';
    } else {
      en = 'Thunderstorm'; rw = 'Inkuba'; fr = 'Orage';
    }
    return langCode == 'rw' ? rw : langCode == 'fr' ? fr : en;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String get _time {
    final n = widget.now;
    return '${_pad(n.hour)}:${_pad(n.minute)}:${_pad(n.second)}';
  }
  String get _date {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final n = widget.now;
    return '${months[n.month - 1]} ${n.day}, ${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final temp = (_weather?['temperature_2m'] as num?)?.toStringAsFixed(0) ?? '--';
    final humidity = (_weather?['relative_humidity_2m'] as num?)?.toStringAsFixed(0)
        ?? widget.district.maxHumidityPct.toStringAsFixed(0);
    final precip = (_weather?['precipitation'] as num?)?.toStringAsFixed(1) ?? '0.0';
    final wind = (_weather?['wind_speed_10m'] as num?)?.toStringAsFixed(0) ?? '12';
    final code = _weather?['weather_code'] as int?;
    final desc = _weatherDesc(code, lang.languageCode);

    return HolographicCard(
      accentColor: AppColors.weatherCloudy,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 14 : 16),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.weatherCloudy.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? const Center(child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.weatherCloudy)))
                  : const Icon(Icons.cloud, color: AppColors.weatherCloudy, size: 32),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.district.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$temp°C',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('H: 26°  L: 16°', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(width: 16),
            if (!widget.isMobile) ...[
              _WItem(icon: Icons.water_drop, label: lang.weatherHumidity, value: '$humidity%'),
              const SizedBox(width: 12),
              _WItem(icon: Icons.umbrella, label: lang.weatherPrecip, value: '$precip mm'),
              const SizedBox(width: 12),
              _WItem(icon: Icons.air, label: lang.weatherWind, value: '$wind km/h'),
              const SizedBox(width: 16),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(_date, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textDim)),
      ],
    );
  }
}

// ── MAP CARD ──────────────────────────────────────────────────────────────────

class _MapCard extends StatefulWidget {
  final List<District> districts;
  final List<Polygon> polygons;
  final ValueChanged<NavItem>? onNavigate;
  final ValueChanged<District?> onDistrictHover;
  final bool isMobile;

  const _MapCard({
    required this.districts,
    required this.polygons,
    required this.onDistrictHover,
    this.onNavigate,
    this.isMobile = false,
  });

  @override
  State<_MapCard> createState() => _MapCardState();
}

class _MapCardState extends State<_MapCard> {
  // District whose popup is currently shown (tapped on mobile, hovered on desktop)
  District? _popupDistrict;
  Offset _popupOffset = Offset.zero;

  // Build polygons — no highlight logic needed here (dashboard shows all colored)
  List<Polygon> _buildPolygons(BuildContext context) {
    final byKey = {
      for (final d in widget.districts) normalizeDistrictName(d.name): d
    };
    // Rebuild polygons from RwaMapPolygon shape + district risk color
    // We use the pre-built polygons passed in (already colored by risk)
    return widget.polygons;
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    return HolographicCard(
      accentColor: AppColors.primary,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // ── Interactive map: polygons ONLY, no dots ──────────────────
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(-1.9403, 29.8739),
                initialZoom: widget.isMobile ? 8.2 : 8.8,
                minZoom: 7.5,
                maxZoom: 16.0,
                cameraConstraint: CameraConstraint.containCenter(
                  bounds: LatLngBounds(
                    const LatLng(-2.85, 28.85),
                    const LatLng(-1.05, 31.25),
                  ),
                ),
                onTap: (_, __) {
                  // Tap on empty map area → close popup
                  setState(() => _popupDistrict = null);
                },
              ),
              children: [
                // ✅ Satellite imagery — ESRI World Imagery (free, no API key)
                TileLayer(
                  urlTemplate:
                      'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                  userAgentPackageName: 'com.cropguard.cropguard_app',
                  maxNativeZoom: 19,
                  maxZoom: 19,
                ),
                // ✅ Colored district polygons — NO dots/markers
                PolygonLayer(polygons: _buildPolygons(context)),
                // ✅ Invisible tap targets over each district centroid
                // so user can tap a district to see details
                MarkerLayer(
                  markers: widget.districts.map((d) {
                    return Marker(
                      point: LatLng(d.centroidLat, d.centroidLng),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown: (details) {
                          setState(() {
                            _popupDistrict = d;
                            _popupOffset = details.localPosition;
                          });
                          widget.onDistrictHover(d);
                        },
                        // Invisible — no visual dot shown
                        child: const SizedBox.expand(),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // ── Hover/tap popup showing district details ─────────────────
            if (_popupDistrict != null)
              _DistrictPopup(
                district: _popupDistrict!,
                onClose: () => setState(() => _popupDistrict = null),
                onViewDetails: () {
                  setState(() => _popupDistrict = null);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        DistrictDetailScreen(district: _popupDistrict!),
                  ));
                },
              ),

            // ── Legend overlay ───────────────────────────────────────────
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xCC0B1617),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _LegendRow(color: Color(0xFF16A34A), label: lang.mapLowRisk),
                    SizedBox(height: 4),
                    _LegendRow(color: Color(0xFFF59E0B), label: lang.mapModerateRisk),
                    SizedBox(height: 4),
                    _LegendRow(color: Color(0xFFDC2626), label: lang.mapHighRisk),
                  ],
                ),
              ),
            ),

            // ── Open full map button ─────────────────────────────────────
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => widget.onNavigate?.call(NavItem.map),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0B1617),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4)),
                  ),
                  child: const Icon(Icons.open_in_full,
                      color: AppColors.primary, size: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── District popup (shown when user taps a district on dashboard map) ─────────

class _DistrictPopup extends StatelessWidget {
  final District district;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const _DistrictPopup({
    required this.district,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = district.riskColor;
    final crops = district.crops.take(4).toList();

    return Positioned(
      top: 12,
      left: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xF00B1617),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: riskColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: riskColor.withOpacity(0.25),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: riskColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      district.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(Icons.close,
                        color: Colors.white54, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Risk badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: riskColor.withOpacity(0.5)),
                ),
                child: Text(
                  '${district.riskIcon}  ${district.riskScore.toStringAsFixed(0)}% ${district.riskLabel}',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: riskColor),
                ),
              ),
              const SizedBox(height: 8),

              // Province
              Text(
                district.province,
                style: const TextStyle(
                    fontSize: 10, color: Colors.white54),
              ),
              const SizedBox(height: 6),

              // Crops grown
              if (crops.isNotEmpty) ...[
                const Text(
                  'Crops:',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.white54,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: crops.map((c) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${c['icon'] ?? ''} ${c['name'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white70),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // View details button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: onViewDetails,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'View Details →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0B1617),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white70)),
      ],
    );
  }
}

// ── CROP YIELD CARD ───────────────────────────────────────────────────────────

class _CropYieldCard extends StatelessWidget {
  final List<District> districts;
  final bool isMobile;
  const _CropYieldCard(
      {required this.districts, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final yearProvider = context.watch<YearProvider>();
    final m = yearProvider.yieldMultiplier;
    final totalMaize = districts.fold(0.0, (s, d) => s + d.maizeTons) * m;
    final totalBeans = districts.fold(0.0, (s, d) => s + d.beansTons) * m;
    final totalPotatoes = districts.fold(0.0, (s, d) => s + d.irishPotatoesTons) * m;
    final totalCassava = districts.fold(0.0, (s, d) => s + d.cassavaTons) * m;
    final totalSorghum = districts.fold(0.0, (s, d) => s + d.sorghumTons) * m;
    final totalWheat = districts.fold(0.0, (s, d) => s + d.wheatTons) * m;
    final totalGroundnuts = districts.fold(0.0, (s, d) => s + d.groundnutsTons) * m;
    final totalSweetPotato = districts.fold(0.0, (s, d) => s + d.sweetPotatoTons) * m;
    final totalPeas = districts.fold(0.0, (s, d) => s + d.peasTons) * m;
    final total = totalMaize + totalBeans + totalPotatoes + totalCassava +
        totalSorghum + totalWheat + totalGroundnuts + totalSweetPotato + totalPeas;

    final growthLabel = yearProvider.isHistorical
        ? '-${((1 - yearProvider.yieldMultiplier) * 100).toStringAsFixed(1)}%'
        : '+12.5%';
    final growthColor = yearProvider.isHistorical ? AppColors.alertRed : AppColors.success;
    final growthIcon = yearProvider.isHistorical ? Icons.arrow_downward : Icons.arrow_upward;

    String _n(String en, String rw, String fr) =>
        lang.languageCode == 'rw' ? rw : lang.languageCode == 'fr' ? fr : en;

    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle),
                child: const Icon(Icons.grass, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.cropYieldTitle,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    if (yearProvider.isHistorical)
                      Text(yearProvider.seasonLabel,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 8),
            Text(lang.cropYieldTotal,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Row(children: [
              Expanded(child: Text(NumberFormatter.tonsFull(total),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: growthColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(growthIcon, color: growthColor, size: 14),
                  const SizedBox(width: 4),
                  Text(growthLabel, style: TextStyle(fontSize: 12,
                      fontWeight: FontWeight.w800, color: growthColor)),
                ]),
              ),
            ]),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 8),
            _CropRow(icon: '🌽', name: _n('Maize','Ibigori','Maïs'), tons: totalMaize, growth: '+14.2%'),
            _CropRow(icon: '🫘', name: _n('Beans','Ibishyimbo','Haricots'), tons: totalBeans, growth: '+10.8%'),
            _CropRow(icon: '🌿', name: _n('Cassava','Imyumbati','Manioc'), tons: totalCassava, growth: '+9.7%'),
            _CropRow(icon: '🥔', name: _n('Irish Potato','Ibirayi','Pomme de Terre'), tons: totalPotatoes, growth: '+8.9%'),
            if (totalSorghum > 0) _CropRow(icon: '🌾', name: _n('Sorghum','Amasaka','Sorgho'), tons: totalSorghum, growth: '+6.1%'),
            if (totalWheat > 0) _CropRow(icon: '🌾', name: _n('Wheat','Ingano','Blé'), tons: totalWheat, growth: '+5.3%'),
            if (totalGroundnuts > 0) _CropRow(icon: '🥜', name: _n('Groundnuts','Amandarashara','Arachides'), tons: totalGroundnuts, growth: '+7.2%'),
            if (totalSweetPotato > 0) _CropRow(icon: '🍠', name: _n('Sweet Potato','Ibijumba','Patate Douce'), tons: totalSweetPotato, growth: '+4.8%'),
            if (totalPeas > 0) _CropRow(icon: '🟢', name: _n('Peas','Amashaza','Pois'), tons: totalPeas, growth: '+3.9%'),
          ],
        ),
      ),
    );
  }
}

class _CropRow extends StatelessWidget {
  final String icon;
  final String name;
  final double tons;
  final String growth;
  const _CropRow(
      {required this.icon,
      required this.name,
      required this.tons,
      required this.growth});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(name,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary))),
          Text(NumberFormatter.tons(tons),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Text(growth,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
        ],
      ),
    );
  }
}

// ── RISK INDICATORS CARD ──────────────────────────────────────────────────────

class _RiskIndicatorsCard extends StatelessWidget {
  final List<District> districts;
  final ValueChanged<NavItem>? onNavigate;
  final bool isMobile;
  const _RiskIndicatorsCard(
      {required this.districts,
      this.onNavigate,
      this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final avgRainfall = districts
            .map((d) => d.rainfallIndex)
            .reduce((a, b) => a + b) /
        districts.length;
    final avgHumidity = districts
            .map((d) => d.humidityIndex)
            .reduce((a, b) => a + b) /
        districts.length;

    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.shield,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(lang.riskTitle,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                ),
              ]),
              const SizedBox(height: 10),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),
              _RiskRow(
                icon: Icons.bug_report,
                label: 'Plant Disease Risk',
                level: avgHumidity > 70
                    ? 'High'
                    : (avgHumidity > 50 ? 'Moderate' : 'Low'),
                isHigh: avgHumidity > 70,
                isModerate: avgHumidity > 50 && avgHumidity <= 70,
              ),
              const SizedBox(height: 8),
              _RiskRow(
                icon: Icons.wb_sunny,
                label: 'Drought Risk',
                level: avgRainfall < 30
                    ? 'High'
                    : (avgRainfall < 50 ? 'Moderate' : 'Low'),
                isHigh: avgRainfall < 30,
                isModerate: avgRainfall >= 30 && avgRainfall < 50,
              ),
              const SizedBox(height: 8),
              _RiskRow(
                icon: Icons.umbrella,
                label: 'Flood Risk',
                level: avgRainfall > 70
                    ? 'High'
                    : (avgRainfall > 50 ? 'Moderate' : 'Low'),
                isHigh: avgRainfall > 70,
                isModerate: avgRainfall > 50 && avgRainfall <= 70,
              ),
              const SizedBox(height: 8),
              _RiskRow(
                icon: Icons.pest_control,
                label: 'Pest Infestation',
                level: 'Low',
                isHigh: false,
                isModerate: false,
              ),
              const SizedBox(height: 16),
              // ✅ FIXED: No Spacer — button always visible
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onNavigate?.call(NavItem.summary),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.assessment,
                      color: AppColors.textOnPrimary, size: 16),
                  label: const Text('View Detailed Analytics →',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String level;
  final bool isHigh;
  final bool isModerate;
  const _RiskRow(
      {required this.icon,
      required this.label,
      required this.level,
      required this.isHigh,
      required this.isModerate});

  @override
  Widget build(BuildContext context) {
    final color = isHigh
        ? AppColors.alertRed
        : (isModerate ? AppColors.alertYellow : AppColors.success);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: color.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary))),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(level,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ),
      ],
    );
  }
}

// ── ALERTS BAR ────────────────────────────────────────────────────────────────

class _AlertsBar extends StatelessWidget {
  final List<District> districts;
  final ValueChanged<NavItem>? onNavigate;
  final bool isMobile;
  const _AlertsBar(
      {required this.districts,
      this.onNavigate,
      this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final alerts = districts.take(3).toList();
    final hours = [2, 4, 6];

    return HolographicCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active,
                    color: AppColors.alertRed, size: 18),
                const SizedBox(width: 8),
                Text(lang.recentAlerts,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const Spacer(),
                // ✅ FIXED: View All navigates to alerts/summary
                TextButton(
                  onPressed: () => onNavigate?.call(NavItem.alerts),
                  child: Text(lang.viewAll,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: alerts.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final d = alerts[i];
                  final isRed = d.riskLevel == 'red';
                  final isYellow = d.riskLevel == 'yellow';
                  final color = isRed
                      ? AppColors.alertRed
                      : (isYellow
                          ? AppColors.alertYellow
                          : AppColors.success);
                  final msg = isRed
                      ? 'High risk of post-harvest loss. Emergency storage required.'
                      : isYellow
                          ? 'Moderate risk. Plan drying within 48h.'
                          : 'Healthy crop conditions. Safe to harvest.';

                  return GestureDetector(
                    // ✅ FIXED: View Details navigates to district detail
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            DistrictDetailScreen(district: d),
                      ));
                    },
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: color.withOpacity(0.3), width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isRed
                                    ? Icons.warning_amber
                                    : (isYellow
                                        ? Icons.warning
                                        : Icons.check_circle),
                                color: color,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(d.name,
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: color),
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text('${hours[i]}h ago',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textDim)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(msg,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 4),
                          Text(lang.viewDetails,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color)),
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
    );
  }
}

// ── MOBILE ALERT BANNER ───────────────────────────────────────────────────────

class _MobileAlertBanner extends StatelessWidget {
  final District district;
  final ValueChanged<NavItem>? onNavigate;
  const _MobileAlertBanner(
      {required this.district, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    return HolographicAlertCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.2),
                  shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber,
                  color: AppColors.alertRed, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.postHarvestAlert,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  Text(
                    '${district.name} is at risk of quality loss due to high humidity.',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // ✅ FIXED: View Details navigates to district detail
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      DistrictDetailScreen(district: district),
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(lang.viewDetails,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
