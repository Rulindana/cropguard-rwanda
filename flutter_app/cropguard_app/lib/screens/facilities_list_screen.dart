import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
import '../utils/language_provider.dart';
import '../utils/translations.dart';
import 'package:url_launcher/url_launcher.dart';

class FacilitiesListScreen extends StatefulWidget {
  final District district;
  final List<Facility> facilities;

  const FacilitiesListScreen({
    super.key,
    required this.district,
    required this.facilities,
  });

  @override
  State<FacilitiesListScreen> createState() => _FacilitiesListScreenState();
}

class _FacilitiesListScreenState extends State<FacilitiesListScreen> {
  Facility? _selectedFacility;
  bool _showMap = false;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.district.name} ${lang.facilitiesTitle}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _getMyLocation,
            tooltip: 'My location',
          ),
          TextButton.icon(
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(
              _showMap ? Icons.list : Icons.map,
              color: _showMap ? AppColors.primary : AppColors.textOnPrimary,
            ),
            label: Text(
              _showMap ? lang.listView : lang.mapView,
              style: TextStyle(
                color: _showMap ? AppColors.primary : AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: _showMap ? _buildMapView() : _buildListView(lang),
      floatingActionButton:
          widget.facilities.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      _selectedFacility = widget.facilities.first;
                      _showMap = true;
                    });
                  },
                  backgroundColor: AppColors.primary,
                  icon: const Icon(Icons.map),
                  label: Text(lang.viewOnMap),
                )
              : null,
    );
  }

  Future<void> _getMyLocation() async {
    final lang = context.read<LanguageProvider>().strings;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(lang.showingAllFacilities),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildListView(AppStrings lang) {
    if (widget.facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storage_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              '${lang.noFacilitiesFound} in ${widget.district.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or contact the district agricultural office',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.facilities.length,
      itemBuilder: (context, index) {
        final facility = widget.facilities[index];
        return _buildFacilityCard(facility, lang);
      },
    );
  }

  Widget _buildMapView() {
    return Column(
      children: [
        // Legend
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: AppColors.surface,
          child: Row(
            children: [
              _buildLegendChip(
                icon: '☀️',
                label: 'Available',
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildLegendChip(
                icon: '📦',
                label: 'Partial',
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildLegendChip(
                icon: '⚠️',
                label: 'Full',
                color: Colors.red,
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-1.9446, 30.0615),
              initialZoom: 10,
              minZoom: 3,
              maxZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cropguard.app',
              ),
              MarkerLayer(
                markers: widget.facilities.map((facility) {
                  final lat = facility.lat;
                  final lng = facility.lng;
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getFacilityColor(facility.availableCapacityTons, facility.capacityTons),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.storage, size: 16, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.facilities.length} facilities in ${widget.district.name}',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getFacilityColor(double available, double capacity) {
    if (capacity <= 0) return Colors.grey;
    final pct = available / capacity;
    if (pct > 0.5) return Colors.green;
    if (pct > 0.2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLegendChip({required String icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        ],
      ),
    );
  }

  void _makePhoneCall(String phone) async {
    final uri = 'tel:$phone';
    if (await canLaunch(uri)) {
      await launch(uri);
    }
  }

  void _sendEmail(String email) async {
    if (email.isNotEmpty) {
      final uri = 'mailto:$email';
      if (await canLaunch(uri)) {
        await launch(uri);
      }
    }
  }

  Widget _buildFacilityCard(Facility facility, AppStrings lang) {
    final isFull = facility.capacityTons > 0 &&
        facility.availableCapacityTons / facility.capacityTons < 0.2;
    final isPartial = facility.capacityTons > 0 &&
        facility.availableCapacityTons / facility.capacityTons < 0.5;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFacility = facility),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getFacilityColor(facility.availableCapacityTons, facility.capacityTons).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.storage, size: 22, color: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          facility.district ?? 'District unknown',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getFacilityColor(facility.availableCapacityTons, facility.capacityTons).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isFull ? Icons.folder_off : (isPartial ? Icons.warning : Icons.check),
                          size: 14,
                          color: _getFacilityColor(facility.availableCapacityTons, facility.capacityTons),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isFull ? lang.facilityFull : (
                            isPartial ? lang.facilityPartial : lang.facilityAvailable
                          ),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getFacilityColor(facility.availableCapacityTons, facility.capacityTons),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Capacity
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${facility.availableCapacityTons.toStringAsFixed(0)} tons available',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${facility.utilizationPct.toStringAsFixed(0)}% full',
                      style: TextStyle(
                        fontSize: 12,
                        color: isFull ? Colors.red : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Contact info
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(facility.contactPhone),
                      icon: const Icon(Icons.phone, size: 16),
                      label: Text(
                        facility.contactPhone.isNotEmpty ? facility.contactPhone : 'No phone',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _sendEmail(facility.contactEmail),
                      icon: const Icon(Icons.email, size: 16),
                      label: Text(
                        facility.contactEmail.isNotEmpty ? facility.contactEmail : 'No email',
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        side: const BorderSide(color: Color(0xFF78909C)),
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
