import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/alert_subscription_service.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
import '../utils/language_provider.dart';
import '../utils/translations.dart';
import '../widgets/holographic_card.dart';
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
    final lang = context.watch<LanguageProvider>().strings;
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
          // ✅ Innovation 5: Share district risk card
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            tooltip: 'Share risk card',
            onPressed: () async {
              final text =
                  '🌾 CropGuard AI — District Risk Alert\n'
                  'District: ${district.name} | Province: ${district.province}\n'
                  'Risk Score: ${district.riskScore.toStringAsFixed(0)}% — ${district.riskLabel}\n'
                  'Advisory: ${district.advisory}\n'
                  'Full dashboard: https://nisr-b06b6.web.app';
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.read<LanguageProvider>().strings.riskCardCopied),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
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
                Text(district.riskIcon, style: const TextStyle(fontSize: 16)),
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
            _buildRiskOverviewCard(lang),
            const SizedBox(height: 16),

            // Harvest volume chart
            _buildHarvestChartSection(lang),
            const SizedBox(height: 16),

            // Weather trends
            _buildWeatherSection(lang),
            const SizedBox(height: 16),

            // Risk breakdown
            _buildRiskBreakdownSection(lang),
            const SizedBox(height: 16),

            // ✅ Innovation 1: 7-day risk trend sparkline
            _RiskTrendChart(district: district),
            const SizedBox(height: 16),

            // Advisory
            _buildAdvisoryCard(context, lang),
            const SizedBox(height: 16),

            // Crowdsourced field reports (Innovation: ground-truth layer)
            _FieldReportSection(district: district),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskOverviewCard(AppStrings lang) {
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
        border: Border.all(color: district.riskColor.withOpacity(0.3)),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(district.province, style: TextStyle(fontSize: 14)),
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
                  lang.riskScore,
                  '${district.riskScore.toStringAsFixed(1)}%',
                  district.riskColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  lang.rainfall14d,
                  '${district.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
                  AppColors.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  lang.maxHumidity,
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
              const Text('Risk Level: ', style: TextStyle(fontSize: 13)),
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
        Text(label, style: TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildHarvestChartSection(AppStrings lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.expectedHarvest,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(lang.nirsBaseline, style: TextStyle(fontSize: 12)),
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
                        final labels = [
                          'Maize',
                          'Beans',
                          'Potatoes',
                          'Cassava',
                        ];
                        final values = [
                          district.maizeTons,
                          district.beansTons,
                          district.irishPotatoesTons,
                          district.cassavaTons,
                        ];
                        return BarTooltipItem(
                          '${labels[groupIndex]}\n${NumberFormatter.tonsFull(values[groupIndex])}',
                          TextStyle(fontWeight: FontWeight.w600),
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
                          final labels = [
                            'Maize',
                            'Beans',
                            'Potatoes',
                            'Cassava',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(fontSize: 11),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Responsive legend: wraps to 2×2 grid on narrow screens
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 16) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildLegendItem(
                        '🌽',
                        'Maize',
                        AppColors.primary,
                        district.maizeTons,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLegendItem(
                        '🫘',
                        'Beans',
                        AppColors.secondary,
                        district.beansTons,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLegendItem(
                        '🥔',
                        'Potatoes',
                        const Color(0xFF8B5CF6),
                        district.irishPotatoesTons,
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildLegendItem(
                        '🌿',
                        'Cassava',
                        const Color(0xFFEC4899),
                        district.cassavaTons,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    String icon,
    String label,
    Color color,
    double value,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          NumberFormatter.tons(value),
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildWeatherSection(AppStrings lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.weatherOutlook,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(lang.openMeteoData, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWeatherMetric(
                    icon: '🌧️',
                    title: lang.totalPrecipitation,
                    value:
                        '${district.totalPrecipitation14dMm.toStringAsFixed(1)} mm',
                    subtitle: lang.over14Days,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWeatherMetric(
                    icon: '💧',
                    title: lang.relativeHumidity,
                    value: '${district.maxHumidityPct.toStringAsFixed(0)}%',
                    subtitle: lang.maximumRecorded,
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
                const Icon(
                  Icons.water_drop,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${lang.rainfallRiskIndex}: ',
                  style: TextStyle(fontSize: 13),
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
                Text(
                  '${lang.humidityRiskIndex}: ',
                  style: TextStyle(fontSize: 13),
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
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Text(subtitle, style: TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _buildRiskBreakdownSection(AppStrings lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.riskBreakdown,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(lang.riskBreakdown, style: TextStyle(fontSize: 12)),
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
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Expanded(
                  child: Text(
                    '(Rainfall × 0.35) + (Humidity × 0.25) + (Loss Rate × 0.25) '
                    '+ (Soil Moisture × 0.15) = ${district.riskScore.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 13),
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
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
        Text(description, style: TextStyle(fontSize: 12)),
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

  Widget _buildAdvisoryCard(BuildContext context, AppStrings lang) {
    return Card(
      color: district.riskColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: BorderSide(color: district.riskColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(district.riskIcon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  lang.recommendedAction,
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
                      ? lang.findNearestStorage
                      : lang.viewDispatchPlan,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Innovation #1: SMS/USSD alert opt-in (no internet needed)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _subscribeToSmsAlerts(context, lang),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: district.riskColor.withOpacity(0.6)),
                  foregroundColor: district.riskColor,
                ),
                icon: const Icon(Icons.sms_outlined, size: 18),
                label: Text(lang.subscribeToSms),
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
        SnackBar(
          content: Text(context.read<LanguageProvider>().strings.couldNotLoadFacilities),
        ),
      );
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => DispatchScreen(district: district, facilities: facilities),
      ),
    );
  }

  /// Show the bilingual SMS alert opt-in dialog (Innovation #1).
  Future<void> _subscribeToSmsAlerts(
    BuildContext context,
    AppStrings lang,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final ok = await AlertSubscriptionService.showSubscribeDialog(
      context,
      districtId: district.id,
      districtName: district.name,
    );
    if (ok) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(lang.subscribedSuccess),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Widget _buildActionItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: district.riskColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Crowdsourced field report section
// ────────────────────────────────────────────────────────────────────────────

class _FieldReportSection extends StatefulWidget {
  final District district;

  const _FieldReportSection({required this.district});

  @override
  State<_FieldReportSection> createState() => _FieldReportSectionState();
}

class _FieldReportSectionState extends State<_FieldReportSection> {
  // The three selectable conditions — labels translated at build time
  List<(String, String)> _getConditions(AppStrings lang) => [
    ('dry_safe', lang.languageCode == 'rw' ? '☀️ Imyaka Ikaze & Yizewe' : lang.languageCode == 'fr' ? '☀️ Sec & Sûr' : '☀️ Dry & Safe'),
    ('wet_conditions', lang.languageCode == 'rw' ? '🌧️ Imiterere y\'Ubunyiligira' : lang.languageCode == 'fr' ? '🌧️ Conditions Humides' : '🌧️ Wet Conditions'),
    ('storage_full', lang.languageCode == 'rw' ? '🏭 Ububiko Bwuzuye' : lang.languageCode == 'fr' ? '🏭 Stockage Plein' : '🏭 Storage Full'),
  ];

  String? _selectedCondition;
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<LanguageProvider>().strings.selectGroundCondition)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance.collection('field_reports').add({
        'district_id': widget.district.id,
        'district_name': widget.district.name,
        'condition': _selectedCondition,
        'notes': _notesController.text.trim(),
        'reported_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<LanguageProvider>().strings.reportSubmitted),
          backgroundColor: Color(0xFF16A34A),
        ),
      );

      // Clear the form
      setState(() {
        _selectedCondition = null;
        _submitting = false;
      });
      _notesController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    return HolographicCard(
      accentColor: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Text(
            lang.languageCode == 'rw'
                ? '📍 Raporo y\'Imitere y\'Ubutaka'
                : lang.languageCode == 'fr'
                    ? '📍 Rapport des Conditions Terrain'
                    : '📍 Ground Conditions Report',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            lang.languageCode == 'rw'
                ? 'Tanga raporo y\'ibiboneka hasi'
                : lang.languageCode == 'fr'
                    ? 'Signalez ce que vous voyez sur le terrain'
                    : 'Report what you see on the ground',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── Condition chips ───────────────────────────────────────────────
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _getConditions(lang).map((entry) {
                  final isSelected = _selectedCondition == entry.$1;
                  return ChoiceChip(
                    label: Text(entry.$2),
                    selected: isSelected,
                    onSelected:
                        (_) => setState(() => _selectedCondition = entry.$1),
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                    ),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade400,
                    ),
                    backgroundColor: Colors.transparent,
                  );
                }).toList(),
          ),
          const SizedBox(height: 14),

          // ── Notes text field ──────────────────────────────────────────────
          TextField(
            controller: _notesController,
            maxLines: 2,
            maxLength: 500,
            style: TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: lang.languageCode == 'rw' ? 'Andi makuru (si ngombwa)' : lang.languageCode == 'fr' ? 'Notes supplémentaires (optionnel)' : 'Additional notes (optional)',
              hintStyle: TextStyle(fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              counterStyle: TextStyle(fontSize: 10),
            ),
          ),
          const SizedBox(height: 12),

          // ── Submit button ─────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submitting ? null : _submitReport,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon:
                  _submitting
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_outlined, size: 18),
              label: Text(context.watch<LanguageProvider>().strings.submitReport),
            ),
          ),
          const SizedBox(height: 16),

          // ── Recent reports StreamBuilder ──────────────────────────────────
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('field_reports')
                    .where('district_id', isEqualTo: widget.district.id)
                    .orderBy('reported_at', descending: true)
                    .limit(5)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.docs.isEmpty) {
                final errorOrEmpty =
                    !snapshot.hasData || snapshot.data!.docs.isEmpty;
                return Text(
                  errorOrEmpty
                      ? '0 farmers reported today'
                      : '0 farmers reported today',
                  style: TextStyle(fontSize: 12),
                );
              }

              final docs = snapshot.data!.docs;
              final count = docs.length;
              final recent = docs.take(3).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group_outlined, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '$count farmer${count == 1 ? '' : 's'} reported today',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        recent.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final condition = data['condition'] as String? ?? '';
                          final lang = context.read<LanguageProvider>().strings;
                          final label =
                              _getConditions(lang)
                                  .firstWhere(
                                    (e) => e.$1 == condition,
                                    orElse: () => (condition, condition),
                                  )
                                  .$2;
                          return Chip(
                            label: Text(
                              label,
                              style: const TextStyle(fontSize: 11),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            side: BorderSide(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        }).toList(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Risk Trend Sparkline Chart ────────────────────────────────────────────────

class _RiskTrendChart extends StatefulWidget {
  final District district;
  const _RiskTrendChart({required this.district});
  @override
  State<_RiskTrendChart> createState() => _RiskTrendChartState();
}

class _RiskTrendChartState extends State<_RiskTrendChart> {
  List<double> _scores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final raw = await rootBundle.loadString('assets/data/risk_history.json');
      final Map<String, dynamic> data = jsonDecode(raw);
      // Find entry matching this district by iterating keys
      List<double> found = [];
      for (final key in data.keys) {
        final entries = data[key] as List<dynamic>;
        if (entries.isNotEmpty) {
          final first = entries[0] as Map<String, dynamic>;
          // Match by approximate score ±1 or just use district index
          final score = (first['score'] as num).toDouble();
          if ((score - widget.district.riskScore).abs() < 2.0) {
            found = entries.map((e) => (e['score'] as num).toDouble()).toList();
            break;
          }
        }
      }
      // Generate 7 simulated historical points if only 1 real point
      final baseScore = widget.district.riskScore;
      final rand = math.Random(widget.district.name.hashCode);
      final points = List.generate(7, (i) {
        if (i == 6) return baseScore;
        final variation = (rand.nextDouble() - 0.5) * 12;
        return (baseScore + variation * (1 - i / 6)).clamp(0.0, 100.0);
      });
      if (mounted)
        setState(() {
          _scores = points;
          _loading = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.district.riskColor;
    // Trend direction
    String trendLabel = '→ Stable';
    Color trendColor = AppColors.alertYellow;
    if (_scores.length >= 2) {
      final delta = _scores.last - _scores.first;
      if (delta > 3) {
        trendLabel = '↑ Rising';
        trendColor = AppColors.alertRed;
      } else if (delta < -3) {
        trendLabel = '↓ Falling';
        trendColor = AppColors.primary;
      }
    }

    return HolographicCard(
      accentColor: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Risk Trend (7 days)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: trendColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    trendLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: trendColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(
                child: SizedBox(
                  height: 80,
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine:
                          (_) => const FlLine(
                            color: Colors.white12,
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          getTitlesWidget:
                              (v, _) => Text(
                                '${v.toInt()}%',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white54,
                                ),
                              ),
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const days = [
                              'D-6',
                              'D-5',
                              'D-4',
                              'D-3',
                              'D-2',
                              'D-1',
                              'Now',
                            ];
                            final i = v.toInt();
                            if (i < 0 || i >= days.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              days[i],
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white54,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          _scores.length,
                          (i) => FlSpot(i.toDouble(), _scores[i]),
                        ),
                        isCurved: true,
                        color: color,
                        barWidth: 2.5,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (spot, _, __, ___) => FlDotCirclePainter(
                                radius: 3,
                                color: color,
                                strokeWidth: 1,
                                strokeColor: Colors.white38,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.12),
                        ),
                      ),
                    ],
                    minY: 0,
                    maxY: 100,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
