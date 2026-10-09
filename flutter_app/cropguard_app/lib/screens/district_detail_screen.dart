import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/alert_subscription_service.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
import 'dispatch_screen.dart';

class DistrictDetailScreen extends StatelessWidget {
  final District district;
  final List<Map<String, dynamic>>? weatherTrend;

  const DistrictDetailScreen({
    super.key,
    required this.district,
    this.weatherTrend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(district.name),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: district.riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  district.riskIcon,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  '${district.riskScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: district.riskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk overview card
            _buildRiskOverviewCard(),
            const SizedBox(height: 16),

            // Harvest volume chart
            _buildHarvestChartSection(),
            const SizedBox(height: 16),

            // Weather trends
            _buildWeatherSection(),
            const SizedBox(height: 16),

            // Risk breakdown
            _buildRiskBreakdownSection(),
            const SizedBox(height: 16),

            // Advisory
            _buildAdvisoryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            district.riskColor.withOpacity(0.15),
            district.riskColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: district.riskColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: district.riskColor,
                  boxShadow: [
                    BoxShadow(
                      color: district.riskColor.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    district.riskIcon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      district.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      district.province,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      district.advisory.split(' - ').last,
                      style: TextStyle(
                        fontSize: 13,
                        color: district.riskColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Risk Score',
                  '${district.riskScore.toStringAsFixed(1)}%',
                  district.riskColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Rainfall (14d)',
                  '${district.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Max Humidity',
                  '${district.maxHumidityPct.toStringAsFixed(0)}%',
                  AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mini risk meter
          Row(
            children: [
              const Text(
                'Risk Level: ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: LinearProgressIndicator(
                  value: district.riskScore / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(district.riskColor),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                district.riskLevel.toUpperCase(),
                style: TextStyle(
                  color: district.riskColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Risk momentum vs previous pipeline run (trend layer)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: district.trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: district.trendColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  district.riskTrend == 'rising'
                      ? Icons.trending_up
                      : district.riskTrend == 'falling'
                          ? Icons.trending_down
                          : district.riskTrend == 'stable'
                              ? Icons.trending_flat
                              : Icons.show_chart,
                  size: 14,
                  color: district.trendColor,
                ),
                const SizedBox(width: 6),
                Text(
                  district.trendLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: district.trendColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expected Harvest Volume',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NISR SAS Baseline Estimates',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: district.maizeTons * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final labels = ['Maize', 'Beans', 'Potatoes', 'Cassava'];
                        final values = [
                          district.maizeTons,
                          district.beansTons,
                          district.irishPotatoesTons,
                          district.cassavaTons,
                        ];
                        return BarTooltipItem(
                          '${labels[groupIndex]}\n${NumberFormatter.tonsFull(values[groupIndex])}',
                          const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Maize', 'Beans', 'Potatoes', 'Cassava'];
                          if (value.toInt() >= 0 && value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: district.maizeTons,
                          color: AppColors.primary,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: district.beansTons,
                          color: AppColors.secondary,
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: district.irishPotatoesTons,
                          color: const Color(0xFF8B5CF6),
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: district.cassavaTons,
                          color: const Color(0xFFEC4899),
                          width: 24,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem('🌽', 'Maize', AppColors.primary, district.maizeTons),
                const SizedBox(width: 16),
                _buildLegendItem('🫘', 'Beans', AppColors.secondary, district.beansTons),
                const SizedBox(width: 16),
                _buildLegendItem('🥔', 'Potatoes', const Color(0xFF8B5CF6), district.irishPotatoesTons),
                const SizedBox(width: 16),
                _buildLegendItem('🌿', 'Cassava', const Color(0xFFEC4899), district.cassavaTons),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String icon, String label, Color color, double value) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 4),
          Text(
            NumberFormatter.tons(value),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '14-Day Weather Outlook',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Open-Meteo Forecast Data',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherMetric(
                    icon: '🌧️',
                    title: 'Total Precipitation',
                    value: '${district.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
                    subtitle: 'Over 14 days',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeatherMetric(
                    icon: '💧',
                    title: 'Relative Humidity',
                    value: '${district.maxHumidityPct.toStringAsFixed(0)}%',
                    subtitle: 'Maximum recorded',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // Rainfall index indicator
            Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Rainfall Risk Index: ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: district.rainfallIndex / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${district.rainfallIndex.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Humidity index indicator
            Row(
              children: [
                const Icon(Icons.air, color: AppColors.secondary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Humidity Risk Index: ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: district.humidityIndex / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${district.humidityIndex.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherMetric({
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskBreakdownSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Score Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Post-Harvest Risk Formula Components',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownRow(
              'Rainfall Index',
              district.rainfallIndex,
              'Weight: 35%',
              AppColors.primary,
              'Evaluates 7-14 day precipitation during peak harvest',
            ),
            const SizedBox(height: 12),
            _buildBreakdownRow(
              'Humidity Index',
              district.humidityIndex,
              'Weight: 25%',
              AppColors.secondary,
              'Measures RH above critical 75% threshold',
            ),
            const SizedBox(height: 12),
            _buildBreakdownRow(
              'Baseline Loss Rate',
              district.lossRateIndex,
              'Weight: 25%',
              const Color(0xFF8B5CF6),
              'Historical vulnerability from NISR SAS data',
            ),
            const SizedBox(height: 12),
            _buildBreakdownRow(
              'Soil Moisture (Satellite)',
              district.soilMoistureIndex,
              'Weight: 15%',
              const Color(0xFF2DD4BF),
              'ERA5 land-surface soil moisture (Copernicus/Sentinel fusion)',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Formula: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    '(Rainfall × 0.35) + (Humidity × 0.25) + (Loss Rate × 0.25) '
                    '+ (Soil Moisture × 0.15) = ${district.riskScore.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
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

  Widget _buildBreakdownRow(
    String title,
    double value,
    String weight,
    Color color,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                weight,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey.shade100,
          valueColor: AlwaysStoppedAnimation(color.withOpacity(0.3)),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildAdvisoryCard(BuildContext context) {
    return Card(
      color: district.riskColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(
          color: district.riskColor.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  district.riskIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'RECOMMENDED ACTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: district.riskColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              district.advisory,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: district.riskColor,
              ),
            ),
            const SizedBox(height: 12),
            // Action items based on risk level
            if (district.riskLevel == 'red') ...[
              _buildActionItem(
                icon: Icons.warning_amber,
                text: 'IMMEDIATE: Dispatch crops to covered storage',
              ),
              _buildActionItem(
                icon: Icons.phone,
                text: 'Contact mobile dryer fleet for emergency deployment',
              ),
              _buildActionItem(
                icon: Icons.notifications,
                text: 'Alert cooperative managers within 2 hours',
              ),
            ] else if (district.riskLevel == 'yellow') ...[
              _buildActionItem(
                icon: Icons.schedule,
                text: 'Plan mechanical drying within 48 hours',
              ),
              _buildActionItem(
                icon: Icons.cloud_off,
                text: 'Monitor humidity levels twice daily',
              ),
              _buildActionItem(
                icon: Icons.storage,
                text: 'Prepare covered storage as backup',
              ),
            ] else ...[
              _buildActionItem(
                icon: Icons.check_circle,
                text: 'Standard harvesting conditions',
              ),
              _buildActionItem(
                icon: Icons.wb_sunny,
                text: 'Sun-drying permitted',
              ),
            ],
            const SizedBox(height: 12),

            // Innovation #2: one-tap facility dispatch matching
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openDispatchPlan(context),
                style: FilledButton.styleFrom(
                  backgroundColor: district.riskColor,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
                label: Text(
                  district.riskLevel == 'red'
                      ? 'Find nearest storage NOW'
                      : 'View dispatch plan',
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Innovation #1: SMS/USSD alert opt-in (no internet needed)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _subscribeToSmsAlerts(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: district.riskColor.withOpacity(0.6),
                  ),
                  foregroundColor: district.riskColor,
                ),
                icon: const Icon(Icons.sms_outlined, size: 18),
                label: const Text('Subscribe to SMS risk alerts'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open the ranked facility dispatch plan (Innovation #2).
  Future<void> _openDispatchPlan(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    List<Facility> facilities;
    try {
      facilities = await FacilityService().getFacilitiesOnce();
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Could not load facilities. Please try again.'),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DispatchScreen(
          district: district,
          facilities: facilities,
        ),
      ),
    );
  }

  /// Show the bilingual SMS alert opt-in dialog (Innovation #1).
  Future<void> _subscribeToSmsAlerts(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final ok = await AlertSubscriptionService.showSubscribeDialog(
      context,
      districtId: district.id,
      districtName: district.name,
    );
    if (ok) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Subscribed! You will receive SMS alerts for ${district.name}.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Widget _buildActionItem({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: district.riskColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
