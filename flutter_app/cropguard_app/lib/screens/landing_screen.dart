import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<double> _growthAnimation;
  int _currentSection = 0;

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
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B1617),
                  Color(0xFF112225),
                  Color(0xFF0A1518),
                ],
              ),
            ),
          ),

          // Animated background glow
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
                      Colors.green.withOpacity(0.08 + _growthAnimation.value * 0.05),
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
                ),

                // Scroll indicator
                const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scroll to explore',
                        style: TextStyle(
                          color: AppColors.textDim,
                          fontSize: 13,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
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
                  body: '''
Every crop begins with reliable data. We ingest official NISR Seasonal Agricultural Survey (SAS) microdata to track yield forecasts across all 30 districts of Rwanda.

Our system processes baseline harvest volumes for maize, beans, Irish potatoes, and cassava — giving planners a clear picture of what each region expects to produce this season.
''',
                  icon: Icons.upload_file,
                  isEven: false,
                ),

                // Predictive Analytics Section
                _StorySection(
                  number: '02',
                  title: 'Predictive AI',
                  subtitle: 'Weather & Risk Forecasting',
                  body: '''
By merging real-time Open-Meteo weather forecasts with historical loss patterns, our algorithm flags high-risk post-harvest zones before rainfall strikes.

The risk formula calculates: (Rainfall × 0.40) + (Humidity × 0.30) + (Loss Rate × 0.30) — giving every district a live risk score updated every 6 hours.
''',
                  icon: Icons.psychology,
                  isEven: true,
                ),

                // Storage Routing Section
                _StorySection(
                  number: '03',
                  title: 'Smart Storage',
                  subtitle: 'Connecting Farmers to Facilities',
                  body: '''
When a district crosses into high-risk territory, the system automatically identifies the nearest available drying grounds, silos, and cold storage units.

Cooperative managers receive contact details and capacity metrics — enabling rapid coordination before crops are lost to rot or aflatoxin contamination.
''',
                  icon: Icons.storage,
                  isEven: false,
                ),

                // Impact Section
                _ImpactSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final Animation<double> animation;

  const _HeroSection({required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background glow
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
                    Colors.green.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Logo
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + animation.value * 0.2,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF00E676),
                        Color(0xFF00C853),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.grass,
                      color: Color(0xFF0B1617),
                      size: 56,
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
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
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

class _StorySection extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final bool isEven;

  const _StorySection({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(100, 60, 100, 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number badge
          Container(
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
          ),
          const SizedBox(width: 30),

          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: isEven
                    ? const Color(0xFF112225).withOpacity(0.8)
                    : const Color(0xFF0B1617).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF263338).withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00000030),
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
                        child: Icon(
                          icon,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        body,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                          height: 1.8,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      width: double.infinity,
      padding: const EdgeInsets.all(100),
      child: Column(
        children: [
          const Text(
            'Protecting Every Harvest',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'From NISR data to field action — CropGuard AI helps Rwanda\'s farmers save their harvest from post-harvest losses.',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                value: '30',
                label: 'Districts Covered',
              ),
              const SizedBox(width: 60),
              _StatItem(
                value: '21',
                label: 'Storage Facilities',
              ),
              const SizedBox(width: 60),
              _StatItem(
                value: '24/7',
                label: 'Live Monitoring',
              ),
            ],
          ),
          const SizedBox(height: 80),
          SizedBox(
            width: 280,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: const Color(0xFF0B1617),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Explore Live Dashboard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Built for NISR 2026 Big Data Hackathon — Track 1: Agricultural Productivity',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textDim,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
