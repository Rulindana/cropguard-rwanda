import 'package:flutter/material.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../utils/colors.dart';
import '../utils/formatters.dart';
import '../widgets/holographic_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final District? selectedDistrict;

  const DashboardScreen({
    super.key,
    required this.districts,
    required this.facilities,
    this.selectedDistrict,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _DesktopDashboard(
            districts: districts,
            facilities: facilities,
            selectedDistrict: selectedDistrict,
          );
        }
        return _MobileDashboard(
          districts: districts,
          facilities: facilities,
          selectedDistrict: selectedDistrict,
        );
      },
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final District? selectedDistrict;

  const _DesktopDashboard({
    required this.districts,
    required this.facilities,
    this.selectedDistrict,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _WeatherWidget(district: selectedDistrict ?? districts.first),
                    _CropYieldCard(districts: districts),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _RwandaMapCard(districts: districts),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _RiskIndicatorsCard(districts: districts),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 340,
            child: _RecentAlertsPanel(districts: districts),
          ),
        ],
      ),
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  final List<District> districts;
  final List<Facility> facilities;
  final District? selectedDistrict;

  const _MobileDashboard({
    required this.districts,
    required this.facilities,
    this.selectedDistrict,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHarvestAlertBanner(districts: districts),
          const SizedBox(height: 12),
          _WeatherWidget(district: selectedDistrict ?? districts.first),
          const SizedBox(height: 12),
          _CropYieldCard(districts: districts, isMobile: true),
          const SizedBox(height: 12),
          _RwandaMapCard(districts: districts, isMobile: true),
          const SizedBox(height: 12),
          _RiskIndicatorsCard(districts: districts, isMobile: true),
          const SizedBox(height: 12),
          _RecentAlertsPanel(districts: districts, isMobile: true),
        ],
      ),
    );
  }
}

// ── Weather Widget ──────────────────────────────────────────────

class _WeatherWidget extends StatelessWidget {
  final District district;
  const _WeatherWidget({required this.district});

  @override
  Widget build(BuildContext context) {
    return HolographicCard(
      accentColor: AppColors.weatherCloudy,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.weatherCloudy.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud, color: AppColors.weatherCloudy, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weather', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                      Text(district.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kigali', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const Text('Partly Cloudy', style: TextStyle(fontSize: 11, color: AppColors.textDim)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.cloud, color: AppColors.primary, size: 14),
                    SizedBox(width: 4),
                    Text('22°C', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _WDetail(icon: Icons.thermostat, label: 'H: 26° L: 16°'),
                const SizedBox(width: 20),
                _WDetail(icon: Icons.water_drop, label: 'Humidity', value: '68%'),
                const SizedBox(width: 20),
                _WDetail(icon: Icons.umbrella, label: 'Precipitation', value: '0 mm'),
                const SizedBox(width: 20),
                _WDetail(icon: Icons.air, label: 'Wind', value: '12 km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WDetail extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _WDetail({required this.icon, required this.label, this.value = ''});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
                if (value.isNotEmpty) Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Crop Yield Card ─────────────────────────────────────────────

class _CropYieldCard extends StatelessWidget {
  final List<District> districts;
  final bool isMobile;
  const _CropYieldCard({required this.districts, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final totalMaize = districts.fold(0.0, (s, d) => s + d.maizeTons);
    final totalBeans = districts.fold(0.0, (s, d) => s + d.beansTons);
    final totalPotatoes = districts.fold(0.0, (s, d) => s + d.irishPotatoesTons);
    final totalCassava = districts.fold(0.0, (s, d) => s + d.cassavaTons);
    final totalYield = totalMaize + totalBeans + totalPotatoes + totalCassava;

    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.grass, color: AppColors.primary, size: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Crop Yield Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (!isMobile) const Text('NISR SAS Baseline', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Yield (Rwanda)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(NumberFormatter.tonsFull(totalYield), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_upward, color: AppColors.success, size: 16),
                    SizedBox(width: 4),
                    Text('+12.5%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.success)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            _CropRow(name: 'Maize', tons: totalMaize, growth: '+14.2%', icon: Icons.eco),
            _CropRow(name: 'Beans', tons: totalBeans, growth: '+10.8%', icon: Icons.circle),
            _CropRow(name: 'Cassava', tons: totalCassava, growth: '+9.7%', icon: Icons.local_florist),
            _CropRow(name: 'Irish Potato', tons: totalPotatoes, growth: '+8.9%', icon: Icons.restaurant),
          ],
        ),
      ),
    );
  }
}

class _CropRow extends StatelessWidget {
  final String name; final double tons; final String growth; final IconData icon;
  const _CropRow({required this.name, required this.tons, required this.growth, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Text(NumberFormatter.tons(tons), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(width: 8),
          Text(growth, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
        ],
      ),
    );
  }
}

// ── Rwanda Map Card ─────────────────────────────────────────────

class _RwandaMapCard extends StatelessWidget {
  final List<District> districts;
  final bool isMobile;
  const _RwandaMapCard({required this.districts, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final highestRisk = districts.reduce((a, b) => a.riskScore > b.riskScore ? a : b);
    final isHighRisk = highestRisk.riskLevel == 'red';

    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 20)),
                const SizedBox(width: 12),
                const Text('Rwanda', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                Row(
                  children: [
                    _LegendDot(color: AppColors.riskGreen, label: 'Low'),
                    const SizedBox(width: 10),
                    _LegendDot(color: AppColors.riskYellow, label: 'Mod'),
                    const SizedBox(width: 10),
                    _LegendDot(color: AppColors.riskRed, label: 'High'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            Container(
              height: isMobile ? 200 : 300,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: const Color(0xFF0A1518),
              ),
              child: Stack(
                children: [
                  // Grid pattern for map background
                  CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _MapGridPainter(),
                  ),
                  // Risk zones (simplified - would use real map tiles in production)
                  ...districts.take(10).map((d) => _RiskZoneMarker(district: d)),
                  // Highest risk pin
                  Positioned(
                    left: 30,
                    top: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHighRisk ? AppColors.alertRed : AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: (isHighRisk ? AppColors.alertRed : AppColors.primary).withOpacity(0.4), blurRadius: 8, spreadRadius: 2)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.location_on, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(highestRisk.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _ScaleBar(),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.layers, color: AppColors.textSecondary, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]);
  }
}

class _ScaleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _Tick(), const SizedBox(width: 6), _Tick(), const SizedBox(width: 6), _Tick(),
        const SizedBox(width: 4),
        const Text('0', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
        const SizedBox(width: 4),
        const Text('50', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
        const SizedBox(width: 4),
        const Text('km', style: TextStyle(fontSize: 9, color: AppColors.textDim)),
      ]),
    );
  }
}

class _Tick extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 2, height: 8, color: AppColors.textDim);
}

class _RiskZoneMarker extends StatelessWidget {
  final District district;
  const _RiskZoneMarker({required this.district});
  @override
  Widget build(BuildContext context) {
    Color color;
    switch (district.riskLevel) {
      case 'red': color = AppColors.riskRed.withOpacity(0.4); break;
      case 'yellow': color = AppColors.riskYellow.withOpacity(0.3); break;
      default: color = AppColors.riskGreen.withOpacity(0.2);
    }
    return Positioned(
      left: (district.centroidLng + 28.85) / 2.4 * 300,
      top: (district.centroidLat + 2.85) / 1.8 * 200,
      child: Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.8), width: 2),
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A3035)
      ..strokeWidth = 0.5;
    final gridPaint = Paint()
      ..color = const Color(0xFF263338)
      ..strokeWidth = 0.5;

    // Grid lines
    for (double i = 0; i <= size.width; i += size.width / 6) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i <= size.height; i += size.height / 6) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Border
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Risk Indicators Card ────────────────────────────────────────

class _RiskIndicatorsCard extends StatelessWidget {
  final List<District> districts;
  final bool isMobile;
  const _RiskIndicatorsCard({required this.districts, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    // Aggregate risk indicators from all districts
    final avgRainfall = districts.map((d) => d.rainfallIndex).reduce((a, b) => a + b) / districts.length;
    final avgHumidity = districts.map((d) => d.humidityIndex).reduce((a, b) => a + b) / districts.length;

    return HolographicCard(
      accentColor: AppColors.primary,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.shield, color: AppColors.primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Risk Indicators', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      if (!isMobile) const Text('Nation-wide assessment', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            _RiskMetric(
              icon: Icons.bug_report,
              title: 'Plant Disease Risk',
              level: avgHumidity > 70 ? 'High' : (avgHumidity > 50 ? 'Moderate' : 'Low'),
              isHigh: avgHumidity > 70,
              isModerate: avgHumidity > 50 && avgHumidity <= 70,
            ),
            const SizedBox(height: 12),
            _RiskMetric(
              icon: Icons.wb_sunny,
              title: 'Drought Risk',
              level: avgRainfall < 30 ? 'High' : (avgRainfall < 50 ? 'Moderate' : 'Low'),
              isHigh: avgRainfall < 30,
              isModerate: avgRainfall >= 30 && avgRainfall < 50,
            ),
            const SizedBox(height: 12),
            _RiskMetric(
              icon: Icons.umbrella,
              title: 'Flood Risk',
              level: avgRainfall > 70 ? 'High' : (avgRainfall > 50 ? 'Moderate' : 'Low'),
              isHigh: avgRainfall > 70,
              isModerate: avgRainfall > 50 && avgRainfall <= 70,
            ),
            const SizedBox(height: 12),
            _RiskMetric(
              icon: Icons.pest_control,
              title: 'Pest Infestation',
              level: 'Low',
              isHigh: false,
              isModerate: false,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assessment, color: AppColors.textOnPrimary, size: 18),
                    SizedBox(width: 8),
                    Text('View Detailed Analytics', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskMetric extends StatelessWidget {
  final IconData icon; final String title; final String level;
  final bool isHigh; final bool isModerate;
  const _RiskMetric({required this.icon, required this.title, required this.level, required this.isHigh, required this.isModerate});

  @override
  Widget build(BuildContext context) {
    final levelColor = isHigh ? AppColors.alertRed : (isModerate ? AppColors.alertYellow : AppColors.success);
    return Row(
      children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: levelColor.withOpacity(0.15), shape: BoxShape.circle),
          child: Icon(icon, color: levelColor, size: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: levelColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      if (isHigh) ...[
                        const Icon(Icons.error_outline, color: AppColors.alertRed, size: 12),
                        const SizedBox(width: 4),
                      ] else if (isModerate) ...[
                        const Icon(Icons.warning, color: AppColors.alertYellow, size: 12),
                        const SizedBox(width: 4),
                      ] else ...[
                        const Icon(Icons.check_circle, color: AppColors.success, size: 12),
                        const SizedBox(width: 4),
                      ],
                      Text(level, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: levelColor)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Recent Alerts Panel ─────────────────────────────────────────

class _RecentAlertsPanel extends StatelessWidget {
  final List<District> districts;
  final bool isMobile;
  const _RecentAlertsPanel({required this.districts, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    // Generate alerts from highest risk districts
    final sorted = [...districts]..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    final alerts = sorted.take(3).map((d) {
      String message;
      if (d.riskLevel == 'red') {
        message = 'High risk of post-harvest loss due to high humidity and rainfall.';
      } else if (d.riskLevel == 'yellow') {
        message = 'Moderate risk conditions expected in the next 48 hours.';
      } else {
        message = 'Healthy crop conditions with safe harvesting weather.';
      }
      return (district: d, message: message, hoursAgo: [2, 4, 6][sorted.indexOf(d)]);
    }).toList();

    return HolographicCard(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: AppColors.alertRed, size: 20),
                const SizedBox(width: 8),
                const Text('Recent Alerts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),
            ...alerts.map((a) => _AlertCard(
              district: a.district,
              message: a.message,
              hoursAgo: a.hoursAgo,
              isMobile: isMobile,
            )),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final District district;
  final String message;
  final int hoursAgo;
  final bool isMobile;
  const _AlertCard({required this.district, required this.message, required this.hoursAgo, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final isRed = district.riskLevel == 'red';
    final isYellow = district.riskLevel == 'yellow';
    final borderColor = isRed ? AppColors.alertRed : (isYellow ? AppColors.alertYellow : AppColors.success);
    final icon = isRed ? Icons.warning_amber : (isYellow ? Icons.warning : Icons.check_circle);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored left border
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(color: borderColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(2))),
          ),
          const SizedBox(width: 12),
          // Icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: borderColor.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: borderColor, size: 18),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(district.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ),
                    Text('$hoursAgo hours ago', style: const TextStyle(fontSize: 10, color: AppColors.textDim)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isMobile) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('View Details', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Post-Harvest Alert Banner (Mobile) ──────────────────────────

class _PostHarvestAlertBanner extends StatelessWidget {
  final List<District> districts;
  const _PostHarvestAlertBanner({required this.districts});

  @override
  Widget build(BuildContext context) {
    final highRisk = districts.where((d) => d.riskLevel == 'red').firstOrNull;
    if (highRisk == null) return const SizedBox.shrink();

    return HolographicAlertCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.alertRed.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.warning_amber, color: AppColors.alertRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Post-Harvest Alert', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const Text('Maize in Nyabihu District is at risk of quality loss due to high humidity.', maxLines: 2, style: TextStyle(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text('2 hours ago', style: const TextStyle(fontSize: 11, color: AppColors.textDim)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: AppColors.textOnPrimary, size: 16),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
