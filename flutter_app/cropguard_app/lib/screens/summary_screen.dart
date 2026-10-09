import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/summary_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('National Overview'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<RiskSummary?>(
        stream: SummaryService().getSummaryStream(),
        builder: (context, summarySnapshot) {
          if (summarySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = summarySnapshot.data;
          if (summary == null) {
            // Fallback: Calculate from districts stream
            return _buildFromDistricts(context);
          }

          return _buildSummaryUI(context, summary);
        },
      ),
    );
  }

  Widget _buildFromDistricts(BuildContext context) {
    return StreamBuilder<List<District>>(
      stream: DistrictService().getDistrictsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final districts = snapshot.data ?? [];
        if (districts.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final green = districts.where((d) => d.riskLevel == 'green').length;
        final yellow = districts.where((d) => d.riskLevel == 'yellow').length;
        final red = districts.where((d) => d.riskLevel == 'red').length;
        final avgRisk = districts
            .map((d) => d.riskScore)
            .reduce((a, b) => a + b) /
            districts.length;

        final calcSummary = RiskSummary(
          totalDistricts: districts.length,
          greenCount: green,
          yellowCount: yellow,
          redCount: red,
          avgRiskScore: avgRisk,
        );

        return _buildSummaryUI(context, calcSummary);
      },
    );
  }

  Widget _buildSummaryUI(BuildContext context, RiskSummary summary) {
    final highRiskDistricts = <District>[];

    return Scaffold(
      body: StreamBuilder<List<District>>(
        stream: DistrictService().getDistrictsStream(),
        builder: (context, districtSnapshot) {
          if (districtSnapshot.hasData) {
            highRiskDistricts.addAll(
              districtSnapshot.data!
                  .where((d) => d.riskLevel == 'red')
                  .toList()
                ..sort((a, b) => b.riskScore.compareTo(a.riskScore)),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Trigger refresh
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header stats
                  _buildHeaderStats(summary),
                  const SizedBox(height: 24),

                  // Risk distribution chart
                  _buildRiskDistribution(summary),
                  const SizedBox(height: 24),

                  // High risk alert section
                  if (highRiskDistricts.isNotEmpty) ...[
                    _buildHighRiskAlert(highRiskDistricts),
                    const SizedBox(height: 24),
                  ],

                  // Province breakdown
                  _buildProvinceBreakdown(districtSnapshot.data ?? []),
                  const SizedBox(height: 24),

                  // Policy recommendations
                  _buildPolicyRecommendations(summary),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(RiskSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xlarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CROPGUARD AI',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'National Post-Harvest Risk Dashboard',
            style: TextStyle(
              color: AppColors.textOnPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Districts',
                  '${summary.totalDistricts}',
                  'Monitored',
                  AppColors.textOnPrimary,
                  Icons.location_city,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Avg Risk Score',
                  summary.avgRiskScore.toStringAsFixed(1),
                  '%',
                  AppColors.textOnPrimary,
                  Icons.analytics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'At Risk',
                  summary.totalAtRisk.toString(),
                  'districts (Yellow + Red)',
                  Colors.amber.shade300,
                  Icons.warning_amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'High Alert',
                  summary.redCount.toString(),
                  'districts (Red)',
                  Colors.red.shade300,
                  Icons.error_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateTime.now().toString().substring(0, 16)}',
            style: TextStyle(
              color: AppColors.textOnPrimary.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String unit,
    Color valueColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          Text(
            '$label $unit',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistribution(RiskSummary summary) {
    final total = summary.totalDistricts.toDouble();
    final greenPct = summary.greenCount / total;
    final yellowPct = summary.yellowCount / total;
    final redPct = summary.redCount / total;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '30 Districts - Real-time Classification',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Pie chart
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: (greenPct * 100),
                                title: '${summary.greenCount}',
                                color: AppColors.green,
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (yellowPct > 0)
                                PieChartSectionData(
                                  value: (yellowPct * 100),
                                  title: '${summary.yellowCount}',
                                  color: AppColors.yellow,
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              if (redPct > 0)
                                PieChartSectionData(
                                  value: (redPct * 100),
                                  title: '${summary.redCount}',
                                  color: AppColors.red,
                                  radius: 50,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Districts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              summary.totalDistricts.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        color: AppColors.green,
                        label: 'Low Risk (Green)',
                        count: summary.greenCount,
                        range: '0-39%',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: AppColors.yellow,
                        label: 'Moderate Risk (Yellow)',
                        count: summary.yellowCount,
                        range: '40-69%',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: AppColors.red,
                        label: 'High Risk (Red)',
                        count: summary.redCount,
                        range: '70-100%',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required int count,
    required String range,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
            range,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighRiskAlert(List<District> highRiskDistricts) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: AppColors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber,
                color: AppColors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'HIGH RISK DISTRICTS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Text(
                  '${highRiskDistricts.length > 0 ? (highRiskDistricts.length / (highRiskDistricts.length + 27) * 100).toStringAsFixed(0) : 0}% of districts',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...highRiskDistricts.take(5).map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      d.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${d.riskScore.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      d.province,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )),
          if (highRiskDistricts.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... and ${highRiskDistricts.length - 5} more districts',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProvinceBreakdown(List<District> districts) {
    // Group by province
    final Map<String, List<District>> provinceMap = {};
    for (final d in districts) {
      provinceMap.putIfAbsent(d.province, () => []).add(d);
    }

    final provinceStats = provinceMap.entries.map((entry) {
      final provinces = entry.value;
      final redCount = provinces.where((d) => d.riskLevel == 'red').length;
      final yellowCount = provinces.where((d) => d.riskLevel == 'yellow').length;
      final avgRisk = provinces.map((d) => d.riskScore).reduce((a, b) => a + b) / provinces.length;
      return {
        'name': entry.key,
        'total': provinces.length,
        'red': redCount,
        'yellow': yellowCount,
        'green': provinces.length - redCount - yellowCount,
        'avgRisk': avgRisk,
      };
    }).toList()
      ..sort((a, b) => (b['avgRisk'] as double).compareTo(a['avgRisk'] as double));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Provincial Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...provinceStats.map((stat) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          stat['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      // Mini bars
                      ...[
                        _buildMiniBar(
                          'G',
                          stat['green'] as int,
                          stat['total'] as int,
                          AppColors.green,
                        ),
                        const SizedBox(width: 4),
                        _buildMiniBar(
                          'Y',
                          stat['yellow'] as int,
                          stat['total'] as int,
                          AppColors.yellow,
                        ),
                        const SizedBox(width: 4),
                        _buildMiniBar(
                          'R',
                          stat['red'] as int,
                          stat['total'] as int,
                          AppColors.red,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        '${(stat['avgRisk'] as double).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _getColorForRisk(stat['avgRisk'] as double),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBar(
    String label,
    int count,
    int total,
    Color color,
  ) {
    final pct = total > 0 ? count / total : 0.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Container(
              height: 8,
              color: color.withOpacity(0.2),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: pct.clamp(0, 1),
                child: Container(
                  color: color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 2),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getColorForRisk(double risk) {
    if (risk >= 70) return AppColors.red;
    if (risk >= 40) return AppColors.yellow;
    return AppColors.green;
  }

  Widget _buildPolicyRecommendations(RiskSummary summary) {
    return Card(
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
        side: const BorderSide(
          color: AppColors.primary,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.policy,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'POLICY RECOMMENDATIONS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (summary.redCount > 0) ...[
              _buildRecommendation(
                icon: Icons.warning_amber,
                title: 'Emergency Resource Deployment',
                description:
                    'Deploy mobile grain dryers to ${summary.redCount} high-risk districts immediately. '
                    'Prioritize districts with peak harvest windows and rainfall forecast >30mm.',
              ),
              const SizedBox(height: 12),
              _buildRecommendation(
                icon: Icons.storage,
                title: 'Storage Capacity Check',
                description:
                    'Verify available capacity at cooperative storage facilities in red-zone districts. '
                    'Redirect harvest to covered storage before rain causes crop rot.',
              ),
            ],
            if (summary.yellowCount > 0) ...[
              _buildRecommendation(
                icon: Icons.schedule,
                title: 'Precautionary Drying Schedule',
                description:
                    'Arrange mechanical drying services for ${summary.yellowCount} moderate-risk districts. '
                    'Ensure drying equipment is available within 48 hours.',
              ),
            ],
            if (summary.greenCount == summary.totalDistricts) ...[
              _buildRecommendation(
                icon: Icons.check_circle,
                title: 'Standard Operations',
                description:
                    'All districts show low risk. Continue routine harvesting and sun-drying protocols. '
                    'Monitor weather forecasts daily.',
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'NST2 Alignment: Post-harvest loss reduction',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
