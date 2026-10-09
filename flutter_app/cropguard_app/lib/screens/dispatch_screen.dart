import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/dispatch_service.dart';
import '../utils/colors.dart';

/// Innovation #2: Facility Dispatch Matching screen.
///
/// Shows the ranked "dispatch plan" for a district: nearest facilities
/// with free capacity, estimated travel time, and one-tap contact -
/// turning a risk score into last-mile action.
class DispatchScreen extends StatelessWidget {
  final District district;
  final List<Facility> facilities;

  const DispatchScreen({
    super.key,
    required this.district,
    required this.facilities,
  });

  @override
  Widget build(BuildContext context) {
    final matches = DispatchService.rank(
      district: district,
      facilities: facilities,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Dispatch Plan - ${district.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: matches.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPriorityBanner(),
                const SizedBox(height: 16),
                for (var i = 0; i < matches.length; i++) ...[
                  _buildMatchCard(context, matches[i], rank: i + 1),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No facility with free capacity found nearby',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Contact the district agricultural office directly',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDim,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBanner() {
    final isEmergency = district.riskLevel == 'red';
    final isRecommended = district.riskLevel == 'yellow';
    final color = district.riskColor;

    final message = isEmergency
        ? 'EMERGENCY: ${district.riskScore.toStringAsFixed(0)}% risk - '
            'dispatch crops to the nearest facility NOW'
        : isRecommended
            ? 'CAUTION: ${district.riskScore.toStringAsFixed(0)}% risk - '
                'schedule dispatch within 48 hours'
            : 'LOW RISK: ${district.riskScore.toStringAsFixed(0)}% - '
                'dispatch available if needed';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isEmergency
                ? Icons.warning_amber
                : isRecommended
                    ? Icons.schedule
                    : Icons.check_circle_outline,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, DispatchMatch match,
      {required int rank}) {
    final facility = match.facility;
    final isEmergency = match.priority == 'emergency';
    final accentColor = isEmergency
        ? AppColors.alertRed
        : match.priority == 'recommended'
            ? AppColors.alertYellow
            : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.6)),
                  ),
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  facility.typeIcon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    facility.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    match.priority.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildChip(Icons.near_me, '${match.distanceKm.toStringAsFixed(1)} km'),
                const SizedBox(width: 8),
                _buildChip(Icons.directions_car, '~${match.etaMinutes} min'),
                const SizedBox(width: 8),
                _buildChip(
                  Icons.inventory_2_outlined,
                  '${facility.availableCapacityTons.toStringAsFixed(0)}t free',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${facility.typeLabel} - ${facility.operationalHours} - '
              'Match ${match.matchScore.toStringAsFixed(0)}/100',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeCall(facility.contactPhone),
                    icon: const Icon(Icons.phone, size: 16),
                    label: Text(facility.contactPhone),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _makeEmail(facility),
                    icon: const Icon(Icons.mail_outline, size: 16),
                    label: const Text('Reserve'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: AppColors.textSecondary),
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _makeEmail(Facility facility) async {
    final subject = Uri.encodeComponent(
        'Storage reservation - ${facility.district} district');
    final body = Uri.encodeComponent(
      'Hello ${facility.contactName},\n\n'
      'I would like to reserve storage/drying capacity at '
      '${facility.name} following a CropGuard post-harvest risk alert '
      'for ${facility.district}.\n\n'
      'Please confirm availability.\n',
    );
    final uri = Uri(
      scheme: 'mailto',
      path: facility.contactEmail,
      queryParameters: {'subject': subject, 'body': body},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
