import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/summary_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/translations.dart';
import '../widgets/holographic_card.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    // ✅ No Scaffold/AppBar here — SummaryScreen lives inside ResponsiveScaffold
    // which already provides the header. Adding an AppBar here created a
    // rogue back button that popped the whole scaffold.
    return StreamBuilder<RiskSummary?>(
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

          return _buildSummaryUI(context, summary, lang);
        },
      );
  }

  Widget _buildFromDistricts(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
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

        return _buildSummaryUI(context, calcSummary, lang);
      },
    );
  }

  Widget _buildSummaryUI(BuildContext context, RiskSummary summary, AppStrings lang) {
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
                  _buildHeaderStats(summary, lang),
                  const SizedBox(height: 24),

                  // Risk distribution chart
                  _buildRiskDistribution(summary, lang),
                  const SizedBox(height: 24),

                  // High risk alert section
                  if (highRiskDistricts.isNotEmpty) ...[
                    _buildHighRiskAlert(highRiskDistricts, lang),
                    const SizedBox(height: 24),
                  ],

                  // Province breakdown
                  _buildProvinceBreakdown(districtSnapshot.data ?? [], lang),
                  const SizedBox(height: 24),

                  // Policy recommendations
                  _buildPolicyRecommendations(summary, lang),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(RiskSummary summary, AppStrings lang) {
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
          Text(
            lang.nationalDashboard,
            style: const TextStyle(
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
                  lang.totalDistricts,
                  '${summary.totalDistricts}',
                  lang.monitored,
                  AppColors.textOnPrimary,
                  Icons.location_city,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  lang.avgRiskScore,
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
                  lang.atRisk,
                  summary.totalAtRisk.toString(),
                  'districts (Yellow + Red)',
                  Colors.amber.shade300,
                  Icons.warning_amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  lang.highAlert,
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
            '${lang.lastUpdated} ${DateTime.now().toString().substring(0, 16)}',
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

  Widget _buildRiskDistribution(RiskSummary summary, AppStrings lang) {
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
            Text(
              lang.riskDistribution,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.realTimeClassification,
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

  Widget _buildHighRiskAlert(List<District> highRiskDistricts, AppStrings lang) {
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
              Text(
                lang.highRiskDistricts,
                style: const TextStyle(
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

  Widget _buildProvinceBreakdown(List<District> districts, AppStrings lang) {
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
            Text(
              lang.provincialBreakdown,
              style: const TextStyle(
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

  Widget _buildPolicyRecommendations(RiskSummary summary, AppStrings lang) {
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
                Text(
                  lang.policyRecommendations,
                  style: const TextStyle(
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
                title: lang.standardOperations,
                description:
                    'All districts show low risk. Continue routine harvesting and sun-drying protocols. '
                    'Monitor weather forecasts daily.',
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              lang.nst2Alignment,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            // ✅ Innovation 2: Download Policy Brief
            _DownloadPolicyBriefButton(),
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

// ── Innovation 2: Download Policy Brief ──────────────────────────────────────

class _DownloadPolicyBriefButton extends StatefulWidget {
  @override
  State<_DownloadPolicyBriefButton> createState() =>
      _DownloadPolicyBriefButtonState();
}

class _DownloadPolicyBriefButtonState
    extends State<_DownloadPolicyBriefButton> {
  bool _loading = false;

  Future<void> _download() async {
    setState(() => _loading = true);
    try {
      final content =
          await rootBundle.loadString('assets/data/policy_brief.md');
      // Copy to clipboard — works on all platforms including web
      await Clipboard.setData(ClipboardData(text: content));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Policy brief copied to clipboard — paste into any text editor to save'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: AppColors.alertRed,
        ));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.description_outlined,
                  color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text('Policy Brief Export',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 6),
            const Text(
              'Export national risk brief for MINAGRI planners and development partners',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _download,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0B1617)))
                    : const Icon(Icons.download, size: 18),
                label: Text(
                    _loading ? 'Preparing...' : 'Download Policy Brief'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF0B1617),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}