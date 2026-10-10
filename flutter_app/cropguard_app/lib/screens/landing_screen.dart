import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/theme_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<double> _growthAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _growthAnimation = CurvedAnimation(
      parent: _scrollController,
      curve: Curves.easeInOut,
    );
    _scrollController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bgTop    = isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4);
    final bgMid    = isDark ? const Color(0xFF112225) : const Color(0xFFFFFFFF);
    final bgBot    = isDark ? const Color(0xFF0A1518) : const Color(0xFFEBF5F0);

    return Scaffold(
      // ── Top-right theme toggle ──────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _ThemeToggleFab(isDark: isDark),
      ),
      body: Stack(
        children: [
          // Background gradient — responds to theme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgMid, bgBot],
              ),
            ),
          ),

          // Animated green glow (subtle in light mode)
          AnimatedBuilder(
            animation: _growthAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      0.5 - (_growthAnimation.value * 0.3),
                      0.3 - (_growthAnimation.value * 0.2),
                    ),
                    colors: [
                      Colors.green.withOpacity(
                          isDark
                              ? 0.08 + _growthAnimation.value * 0.05
                              : 0.04 + _growthAnimation.value * 0.02),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Main content
          SingleChildScrollView(
            child: Column(
              children: [
                // Hero section
                _HeroSection(
                  animation: _growthAnimation,
                  isDark: isDark,
                ),

                // Scroll indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scroll to explore',
                        style: TextStyle(
                          color: AppColors.textFaded(context),
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                // Data Ingestion Section
                _StorySection(
                  number: '01',
                  title: 'Data Ingestion',
                  subtitle: 'Understanding District Baselines',
                  body:
                      'Every crop begins with reliable data. We ingest official NISR Seasonal Agricultural Survey (SAS) microdata to track yield forecasts across all 30 districts of Rwanda.\n\n'
                      'Our system processes baseline harvest volumes for maize, beans, Irish potatoes, and cassava — giving planners a clear picture of what each region expects to produce this season.',
                  icon: Icons.upload_file,
                  isEven: false,
                  isDark: isDark,
                ),

                // Predictive Analytics Section
                _StorySection(
                  number: '02',
                  title: 'Predictive AI',
                  subtitle: 'Weather & Risk Forecasting',
                  body:
                      'By merging real-time Open-Meteo weather forecasts with historical loss patterns, our algorithm flags high-risk post-harvest zones before rainfall strikes.\n\n'
                      'The risk formula: (Rainfall × 0.35) + (Humidity × 0.25) + (Loss Rate × 0.25) + (Soil Moisture × 0.15) — fusing satellite-derived soil-moisture data, updated every 6 hours.',
                  icon: Icons.psychology,
                  isEven: true,
                  isDark: isDark,
                ),

                // Storage Routing Section
                _StorySection(
                  number: '03',
                  title: 'Smart Storage',
                  subtitle: 'Connecting Farmers to Facilities',
                  body:
                      'When a district crosses into high-risk territory, the system automatically identifies the nearest available drying grounds, silos, and cold storage units.\n\n'
                      'Cooperative managers receive contact details and capacity metrics — enabling rapid coordination before crops are lost to rot or aflatoxin contamination.',
                  icon: Icons.storage,
                  isEven: false,
                  isDark: isDark,
                ),

                // Impact Section
                _ImpactSection(isDark: isDark),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme toggle FAB ──────────────────────────────────────────────────────────

class _ThemeToggleFab extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleFab({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF263338) : const Color(0xFFE0F2E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: isDark ? 2 : 24, top: 2,
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                size: 13,
                color: const Color(0xFF0B1617),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Animation<double> animation;
  final bool isDark;

  const _HeroSection({required this.animation, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final txtPrimary = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtSub     = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);
    final logoBg     = isDark ? const Color(0xFF0B1617) : Colors.white;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow circle
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.green.withOpacity(isDark ? 0.15 : 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Logo with pulse animation
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + animation.value * 0.2,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: logoBg,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(isDark ? 0.4 : 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/icon/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),

          // Text below logo
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            child: Column(
              children: [
                const Text(
                  'CropGuard AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Better Insights. Higher Yields.',
                  style: TextStyle(
                    fontSize: 16,
                    color: txtSub,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),
                // ✅ Innovation 4: Live risk counter
                const _LiveRiskCounter(),
                const SizedBox(height: 16),
                // CTA button
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/dashboard'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Open Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B1617),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Story section ─────────────────────────────────────────────────────────────

class _StorySection extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final bool isEven;
  final bool isDark;

  const _StorySection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.isEven,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark
        ? (isEven
            ? const Color(0xFF112225).withOpacity(0.8)
            : const Color(0xFF0B1617).withOpacity(0.6))
        : (isEven
            ? const Color(0xFFEBF5F0)
            : Colors.white);
    final cardBorder = isDark
        ? const Color(0xFF263338).withOpacity(0.5)
        : const Color(0xFFCCE8D8).withOpacity(0.8);
    final txtPrimary = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtBody    = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);

    final isNarrow = MediaQuery.of(context).size.width < 700;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isNarrow ? 20 : 80,
        isNarrow ? 32 : 60,
        isNarrow ? 20 : 80,
        isNarrow ? 32 : 60,
      ),
      child: isNarrow
          ? _buildColumn(cardBg, cardBorder, txtPrimary, txtBody)
          : _buildRow(cardBg, cardBorder, txtPrimary, txtBody),
    );
  }

  Widget _buildRow(Color cardBg, Color cardBorder, Color txtPrimary, Color txtBody) {
    final badge = _buildBadge();
    final card  = _buildCard(cardBg, cardBorder, txtPrimary, txtBody);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isEven
          ? [Expanded(child: card), const SizedBox(width: 30), badge]
          : [badge, const SizedBox(width: 30), Expanded(child: card)],
    );
  }

  Widget _buildColumn(Color cardBg, Color cardBorder, Color txtPrimary, Color txtBody) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(),
        const SizedBox(height: 16),
        _buildCard(cardBg, cardBorder, txtPrimary, txtBody),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B1617),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Color cardBg, Color cardBorder, Color txtPrimary, Color txtBody) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00000020),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: txtPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: TextStyle(
              fontSize: 15,
              color: txtBody,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact section ────────────────────────────────────────────────────────────

class _ImpactSection extends StatelessWidget {
  final bool isDark;
  const _ImpactSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final txtPrimary = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtSub     = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);
    final cardBg     = isDark ? const Color(0xFF112225) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF263338) : const Color(0xFFCCE8D8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Text(
            'Impact at Scale',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: txtPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Real numbers. Real impact.',
            style: TextStyle(fontSize: 16, color: txtSub),
          ),
          const SizedBox(height: 40),

          // Stats grid — wraps on mobile
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _StatCard(value: '30', label: 'Districts\nMonitored',
                  icon: Icons.location_on, cardBg: cardBg, cardBorder: cardBorder,
                  txtPrimary: txtPrimary, txtSub: txtSub),
              _StatCard(value: '21', label: 'Storage\nFacilities',
                  icon: Icons.warehouse, cardBg: cardBg, cardBorder: cardBorder,
                  txtPrimary: txtPrimary, txtSub: txtSub),
              _StatCard(value: '4', label: 'Crop\nTypes',
                  icon: Icons.grass, cardBg: cardBg, cardBorder: cardBorder,
                  txtPrimary: txtPrimary, txtSub: txtSub),
              _StatCard(value: '6h', label: 'Update\nFrequency',
                  icon: Icons.refresh, cardBg: cardBg, cardBorder: cardBorder,
                  txtPrimary: txtPrimary, txtSub: txtSub),
            ],
          ),

          const SizedBox(height: 48),

          // Launch button
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/dashboard'),
            icon: const Icon(Icons.map, size: 20),
            label: const Text('Open Risk Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0B1617),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color cardBg;
  final Color cardBorder;
  final Color txtPrimary;
  final Color txtSub;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.cardBg,
    required this.cardBorder,
    required this.txtPrimary,
    required this.txtSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              )),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: txtSub, height: 1.4)),
        ],
      ),
    );
  }
}

// ── Innovation 4: Live Risk Counter ──────────────────────────────────────────

class _LiveRiskCounter extends StatefulWidget {
  const _LiveRiskCounter();
  @override
  State<_LiveRiskCounter> createState() => _LiveRiskCounterState();
}

class _LiveRiskCounterState extends State<_LiveRiskCounter>
    with SingleTickerProviderStateMixin {
  int _red = 0, _yellow = 0, _green = 0;
  bool _loaded = false;
  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/risk_scores.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final districts = data['districts'] as List<dynamic>;
      int r = 0, y = 0, g = 0;
      for (final d in districts) {
        final level = (d['risk'] as Map<String, dynamic>?)?['level'] ?? 'green';
        if (level == 'red') r++;
        else if (level == 'yellow') y++;
        else g++;
      }
      if (mounted) {
        setState(() { _red = r; _yellow = y; _green = g; _loaded = true; });
        _anim.forward();
      }
    } catch (_) {}
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return FadeTransition(
      opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x220B1617),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(color: AppColors.alertRed, count: _red, label: 'High'),
            const SizedBox(width: 12),
            _Dot(color: AppColors.alertYellow, count: _yellow, label: 'Moderate'),
            const SizedBox(width: 12),
            _Dot(color: AppColors.primary, count: _green, label: 'Safe'),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final int count;
  final String label;
  const _Dot({required this.color, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text('$count $label',
          style: TextStyle(fontSize: 12, color: color,
              fontWeight: FontWeight.w700)),
    ]);
  }
}
