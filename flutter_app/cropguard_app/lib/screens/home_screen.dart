import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
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

  // Rwanda bounding box for map view
  static const LatLngBounds rwandaBounds = LatLngBounds(
    LatLng(-2.85, 28.85),
    LatLng(-1.05, 31.25),
  );

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
          _districts = districts;
          _facilities = facilities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _onDistrictTap(District district) {
    setState(() {
      _selectedDistrict = district;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error))
              : _buildMapWithPanel(),
      floatingActionButton: _selectedDistrict != null
          ? FloatingActionButton(
              heroTag: 'facilities',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FacilitiesListScreen(
                      district: _selectedDistrict!,
                      facilities: _facilities
                          .where((f) => f.district == _selectedDistrict!.name)
                          .toList(),
                    ),
                  ),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.storage_two_outlined),
            )
          : null,
    );
  }

  Widget _buildMapWithPanel() {
    return Stack(
      children: [
        // Map
        FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(-1.94, 29.87),
            initialZoom: 7.5,
            bounds: rwandaBounds,
            onTap: (tap) {
              // Check if tapped on a district marker area
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.cropguard.cropguard_app',
            ),
            // District markers
            MarkerLayer(
              markers: _districts.map((d) {
                return Marker(
                  point: LatLng(d.centroidLat, d.centroidLng),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _onDistrictTap(d),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: d.riskColor,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: d.riskColor.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          d.riskIcon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Selected district highlight
            if (_selectedDistrict != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      _selectedDistrict!.centroidLat,
                      _selectedDistrict!.centroidLng,
                    ),
                    width: 56,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),

        // Bottom detail panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _selectedDistrict != null
              ? _buildDetailPanel()
              : _buildDistrictSelector(),
        ),

        // Loading indicator overlay
        if (_isLoading)
          const Positioned(
            top: 16,
            right: 16,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _buildDistrictSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: [AppShadows.card],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select a District',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _districts.length,
              itemBuilder: (context, index) {
                final d = _districts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d.name),
                    selected: _selectedDistrict?.id == d.id,
                    onSelected: (_) => _onDistrictTap(d),
                    backgroundColor: AppColors.background,
                    selectedColor: d.riskColor.withOpacity(0.2),
                    checkmarkColor: d.riskColor,
                    side: BorderSide(
                      color: d.riskColor.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPanel() {
    final d = _selectedDistrict!;
    return Draggable(
      // ignore: deprecated_member_use
      childWhenDragging: Container(
        height: 0,
        color: Colors.transparent,
      ),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            boxShadow: [AppShadows.medium],
          ),
          width: MediaQuery.of(context).size.width - 32,
          child: _buildPanelContent(d),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: [AppShadows.card],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.drag_indicator,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            _buildPanelContent(d),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelContent(District d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: d.riskColor.withOpacity(0.15),
              ),
              child: Text(
                d.riskIcon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    d.province,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            RiskIndicator(level: d.riskLevel),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),

        // Risk score gauge
        _buildRiskScoreCard(d),

        const SizedBox(height: 12),

        // Crop volumes
        _buildCropVolumesCard(d),

        const SizedBox(height: 12),

        // Weather summary
        _buildWeatherCard(d),

        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.info_outline,
                label: 'Advisory',
                onTap: () => _showAdvisoryDialog(d),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                icon: Icons.storage_two_outlined,
                label: 'Facilities',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FacilitiesListScreen(
                        district: d,
                        facilities: _facilities
                            .where((f) => f.district == d.name)
                            .toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiskScoreCard(District d) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: d.riskColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: d.riskColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Risk Score',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${d.riskScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: d.riskColor,
                  ),
                ),
                Text(
                  d.advisory.split(' - ').last,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Mini gauge visualization
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: d.riskScore / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(d.riskColor),
                ),
                Text(
                  '${d.riskScore.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: d.riskColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropVolumesCard(District d) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expected Harvest Volume',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCropChip(
                  icon: '🌽',
                  label: 'Maize',
                  value: d.maizeTons,
                ),
                const SizedBox(width: 8),
                _buildCropChip(
                  icon: '🫘',
                  label: 'Beans',
                  value: d.beansTons,
                ),
                const SizedBox(width: 8),
                _buildCropChip(
                  icon: '🥔',
                  label: 'Potatoes',
                  value: d.irishPotatoesTons,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildCropChip(
                  icon: '🌿',
                  label: 'Cassava',
                  value: d.cassavaTons,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historical loss: ${d.historicalLossRatePct.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropChip({
    required String icon,
    required String label,
    required double value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '$label: ',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
            Text(
              NumberFormatter.tons(value),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(District d) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildWeatherItem(
              icon: '🌧️',
              label: 'Rain (14d)',
              value: '${d.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
            ),
            const SizedBox(width: 12),
            _buildWeatherItem(
              icon: '💧',
              label: 'Max Humidity',
              value: '${d.maxHumidityPct.toStringAsFixed(0)}%',
            ),
            const SizedBox(width: 12),
            _buildWeatherItem(
              icon: '📊',
              label: 'Rain Index',
              value: d.rainfallIndex.toStringAsFixed(0),
            ),
            const SizedBox(width: 12),
            _buildWeatherItem(
              icon: '🌡️',
              label: 'Humidity Index',
              value: d.humidityIndex.toStringAsFixed(0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvisoryDialog(District d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(d.riskIcon),
            const SizedBox(width: 8),
            Text('Risk Advisory: ${d.name}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: d.riskColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.small),
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
            const Text(
              'Detailed Assessment',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _buildAdvisoryRow('Rainfall Index', '${d.rainfallIndex.toStringAsFixed(1)} / 100'),
            _buildAdvisoryRow('Humidity Index', '${d.humidityIndex.toStringAsFixed(1)} / 100'),
            _buildAdvisoryRow('Loss Rate Index', '${d.lossRateIndex.toStringAsFixed(1)} / 100'),
            _buildAdvisoryRow('14-Day Rainfall', '${d.totalPrecipitation14dMm.toStringAsFixed(1)} mm'),
            _buildAdvisoryRow('Peak Humidity', '${d.maxHumidityPct.toStringAsFixed(0)}%'),
            _buildAdvisoryRow('Historical Loss Rate', '${d.historicalLossRatePct.toStringAsFixed(1)}%'),
            _buildAdvisoryRow('Maize Harvest', NumberFormatter.tonsFull(d.maizeTons)),
            _buildAdvisoryRow('Beans Harvest', NumberFormatter.tonsFull(d.beansTons)),
            _buildAdvisoryRow('Potatoes Harvest', NumberFormatter.tonsFull(d.irishPotatoesTons)),
            const SizedBox(height: 12),
            Text(
              'Risk Formula: (Rainfall × 0.40) + (Humidity × 0.30) + (Loss Rate × 0.30)',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvisoryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
