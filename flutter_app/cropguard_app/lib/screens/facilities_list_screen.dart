import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.district.name} Facilities'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(
              _showMap ? Icons.list : Icons.map,
              color: _showMap ? AppColors.primary : AppColors.textOnPrimary,
            ),
            label: Text(
              _showMap ? 'List View' : 'Map View',
              style: TextStyle(
                color: _showMap ? AppColors.primary : AppColors.textOnPrimary,
              ),
            ),
          ),
        ],
      ),
      body: _showMap ? _buildMapView() : _buildListView(),
      floatingActionButton: widget.facilities.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  _selectedFacility = widget.facilities.first;
                  _showMap = true;
                });
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.map),
              label: const Text('View on Map'),
            )
          : null,
    );
  }

  Widget _buildListView() {
    if (widget.facilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.storage_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No facilities found in ${widget.district.name}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later or contact the district agricultural office',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
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
        return _FacilityCard(
          facility: facility,
          onTap: () => setState(() => _selectedFacility = facility),
          onCall: () => _makePhoneCall(facility.contactPhone),
          onEmail: () => _sendEmail(facility.contactEmail),
        );
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
                label: 'Drying Ground',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _buildLegendChip(
                icon: '🏛️',
                label: 'Silo',
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              _buildLegendChip(
                icon: '❄️',
                label: 'Cold Storage',
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              _buildLegendChip(
                icon: '🚛',
                label: 'Mobile Dryer',
                color: Colors.orange,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => setState(() => _showMap = false),
                icon: const Icon(Icons.list),
                color: AppColors.textSecondary,
                tooltip: 'Back to list',
              ),
            ],
          ),
        ),
        // Map
        Expanded(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(
                widget.district.centroidLat,
                widget.district.centroidLng,
              ),
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cropguard.cropguard_app',
              ),
              // District center marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(
                      widget.district.centroidLat,
                      widget.district.centroidLng,
                    ),
                    width: 48,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              // Facility markers
              MarkerLayer(
                markers: widget.facilities.map((f) {
                  final isSelected = _selectedFacility?.id == f.id;
                  return Marker(
                    point: LatLng(f.lat, f.lng),
                    width: isSelected ? 56 : 44,
                    height: isSelected ? 56 : 44,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFacility = f),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : _getFacilityColor(f.type).withOpacity(0.9),
                          border: Border.all(
                            color: Colors.white,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected
                                      ? AppColors.primary
                                      : _getFacilityColor(f.type))
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            f.typeIcon,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        // Selected facility detail
        if (_selectedFacility != null)
          _buildSelectedFacilitySheet(),
      ],
    );
  }

  Widget _buildLegendChip({
    required String icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedFacilitySheet() {
    final f = _selectedFacility!;
    return Container(
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getFacilityColor(f.type).withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    f.typeIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      f.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      f.typeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedFacility = null),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                icon: '📍',
                label: f.district,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: '📦',
                label: NumberFormatter.capacity(
                  f.usedCapacity,
                  f.capacityTons,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(f.contactPhone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendEmail(f.contactEmail),
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '📞 ${f.contactName}  |  🕐 ${f.operationalHours}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFacilityColor(String type) {
    switch (type) {
      case 'drying_ground':
        return AppColors.primary;
      case 'silo':
        return AppColors.secondary;
      case 'cold_storage':
        return Colors.blue;
      case 'storage_center':
        return const Color(0xFF8B5CF6);
      case 'mobile_dryer':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _FacilityCard extends StatelessWidget {
  final Facility facility;
  final VoidCallback onTap;
  final VoidCallback onCall;
  final VoidCallback onEmail;

  const _FacilityCard({
    required this.facility,
    required this.onTap,
    required this.onCall,
    required this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isHighUtilization =
        facility.utilizationPct > 75;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        facility.typeIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          facility.typeLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          facility.district,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isHighUtilization)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 14,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'High usage',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatItem(
                    '📦 Capacity',
                    '${facility.availableCapacityTons.toStringAsFixed(0)}/${facility.capacityTons.toStringAsFixed(0)} tons',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    '📊 Used',
                    '${facility.utilizationPct.toStringAsFixed(0)}%',
                    valueColor: isHighUtilization
                        ? Colors.orange
                        : AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.phone, size: 16),
                      label: Text(facility.contactPhone),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(
                          color: AppColors.primary,
                        ),
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEmail,
                      icon: const Icon(Icons.email, size: 16),
                      label: Text(
                        facility.contactEmail.isNotEmpty
                            ? facility.contactEmail
                            : 'No email',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(
                          color: AppColors.textSecondary,
                        ),
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

  Widget _buildStatItem(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
