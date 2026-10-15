import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/theme_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Credits Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreditsScreen extends StatefulWidget {
  const CreditsScreen({super.key});
  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _titleCtrl;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleFade = CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutBack));
    _titleCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final bg = isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4);
    final txtPri = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtSub = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);
    final cardBg = isDark ? const Color(0xFF112225) : Colors.white;
    final cardBorder =
        isDark ? const Color(0xFF263338) : const Color(0xFFCCE8D8);

    return Container(
      color: bg,
      child: Stack(
        children: [
          // Animated background orbs
          AnimatedBuilder(
            animation: _bgCtrl,
            builder:
                (_, __) => CustomPaint(
                  painter: _OrbPainter(t: _bgCtrl.value, isDark: isDark),
                  size: Size.infinite,
                ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Title ────────────────────────────────────────────
                FadeTransition(
                  opacity: _titleFade,
                  child: SlideTransition(
                    position: _titleSlide,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (b) => const LinearGradient(
                                colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                              ).createShader(b),
                          child: const Text(
                            '🏆 Credits',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The team behind CropGuard AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: txtSub,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── NISR Hackathon badge ──────────────────────────
                _HackathonBadge(isDark: isDark),

                const SizedBox(height: 32),

                // ── Team members ──────────────────────────────────
                _TeamMemberCard(
                  name: 'RULINDANA SIMBI\nHonoré Tesny',
                  role: 'Lead Developer & System Architect',
                  imagePath: 'assets/icon/team_rulindana.jpg',
                  hasPhoto: true,
                  accentColor: const Color(0xFF00E676),
                  delay: 0,
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  txtPri: txtPri,
                  txtSub: txtSub,
                  skills: ['Flutter', 'Firebase', 'Python', 'AI/ML'],
                ),

                const SizedBox(height: 20),

                _TeamMemberCard(
                  name: 'IRAKIZA Moïse',
                  role: 'UI/UX Designer & Frontend Engineer',
                  imagePath: 'assets/icon/team_moise.png',
                  hasPhoto: true,
                  accentColor: const Color(0xFF00B0FF),
                  delay: 150,
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  txtPri: txtPri,
                  txtSub: txtSub,
                  skills: ['UI Design', 'User Research', 'Prototyping'],
                ),

                const SizedBox(height: 20),

                _TeamMemberCard(
                  name: 'ISHIMWERYAYO\nJean Damour',
                  role: 'Data Analyst & Agricultural Specialist',
                  imagePath: 'assets/icon/team_jean_damour.png',
                  hasPhoto: true,
                  accentColor: const Color(0xFFAB47BC),
                  delay: 300,
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  txtPri: txtPri,
                  txtSub: txtSub,
                  skills: ['NISR SAS Data', 'Risk Modeling', 'Analytics'],
                ),

                const SizedBox(height: 36),

                // ── Tech stack ────────────────────────────────────
                _TechStackSection(
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  txtPri: txtPri,
                  txtSub: txtSub,
                ),

                const SizedBox(height: 32),

                // ── Data sources ──────────────────────────────────
                _DataSourcesSection(
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  txtPri: txtPri,
                  txtSub: txtSub,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated background orbs
// ─────────────────────────────────────────────────────────────────────────────

class _OrbPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _OrbPainter({required this.t, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      (0.2, 0.15, 180.0, const Color(0xFF00E676)),
      (0.8, 0.4, 220.0, const Color(0xFF00B0FF)),
      (0.5, 0.75, 160.0, const Color(0xFFAB47BC)),
    ];
    for (final orb in orbs) {
      final x =
          orb.$1 * size.width + math.sin(t * math.pi * 2 + orb.$1 * 3) * 30;
      final y =
          orb.$2 * size.height + math.cos(t * math.pi * 2 + orb.$2 * 2) * 20;
      final paint =
          Paint()
            ..color = (orb.$4 as Color).withOpacity(isDark ? 0.07 : 0.04)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset(x, y), orb.$3, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Hackathon badge
// ─────────────────────────────────────────────────────────────────────────────

class _HackathonBadge extends StatefulWidget {
  final bool isDark;
  const _HackathonBadge({required this.isDark});
  @override
  State<_HackathonBadge> createState() => _HackathonBadgeState();
}

class _HackathonBadgeState extends State<_HackathonBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder:
          (_, __) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00E676).withOpacity(0.15),
                  const Color(0xFF00B0FF).withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00E676).withOpacity(0.5 * _glow.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF00E676,
                  ).withOpacity(0.15 * _glow.value),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏅', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NISR Hackathon 2026',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF00E676),
                      ),
                    ),
                    Text(
                      'National Institute of Statistics of Rwanda',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Team member card with circular photo + animated ring
// ─────────────────────────────────────────────────────────────────────────────

class _TeamMemberCard extends StatefulWidget {
  final String name;
  final String role;
  final String imagePath;
  final bool hasPhoto;
  final Color accentColor;
  final int delay;
  final bool isDark;
  final Color cardBg, cardBorder, txtPri, txtSub;
  final List<String> skills;

  const _TeamMemberCard({
    required this.name,
    required this.role,
    required this.imagePath,
    required this.hasPhoto,
    required this.accentColor,
    required this.delay,
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.txtPri,
    required this.txtSub,
    required this.skills,
  });

  @override
  State<_TeamMemberCard> createState() => _TeamMemberCardState();
}

class _TeamMemberCardState extends State<_TeamMemberCard>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _entryCtrl;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _entryCtrl.forward();
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular photo with animated rotating ring
              AnimatedBuilder(
                animation: _ringCtrl,
                builder:
                    (_, __) => CustomPaint(
                      painter: _RingPainter(
                        t: _ringCtrl.value,
                        color: widget.accentColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: ClipOval(
                          child:
                              widget.hasPhoto
                                  ? Image.asset(
                                    widget.imagePath,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    width: 80,
                                    height: 80,
                                    color: widget.accentColor.withOpacity(0.15),
                                    child: Center(
                                      child: Text(
                                        widget.name
                                            .split('\n')
                                            .first
                                            .split(' ')
                                            .map(
                                              (w) => w.isNotEmpty ? w[0] : '',
                                            )
                                            .take(2)
                                            .join(),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                          color: widget.accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                    ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: widget.txtPri,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.role,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          widget.skills.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.accentColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: widget.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Rotating dashed ring painter around photo
class _RingPainter extends CustomPainter {
  final double t;
  final Color color;
  _RingPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final paint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;

    // Draw 8 dashes rotating
    for (int i = 0; i < 8; i++) {
      final angle = t * math.pi * 2 + i * math.pi / 4;
      final start = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle + 0.25),
        center.dy + radius * math.sin(angle + 0.25),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Tech stack section
// ─────────────────────────────────────────────────────────────────────────────

class _TechStackSection extends StatelessWidget {
  final bool isDark;
  final Color cardBg, cardBorder, txtPri, txtSub;

  const _TechStackSection({
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.txtPri,
    required this.txtSub,
  });

  @override
  Widget build(BuildContext context) {
    final techs = [
      ('⚡', 'Flutter', 'Cross-platform UI', const Color(0xFF00B0FF)),
      ('🔥', 'Firebase', 'Real-time DB & Hosting', const Color(0xFFFFA726)),
      ('🐍', 'Python', 'Data Pipeline & AI', const Color(0xFF66BB6A)),
      ('🌍', 'Open-Meteo', 'Weather Forecasts', const Color(0xFF26C6DA)),
      ('📊', 'NISR SAS', 'Agricultural Baselines', const Color(0xFFAB47BC)),
      ('🛰️', 'Satellite', 'Soil Moisture Data', const Color(0xFFEF5350)),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🛠 Tech Stack',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: txtPri,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                techs.map((t) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: t.$4.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.$4.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(t.$1, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.$2,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: t.$4,
                              ),
                            ),
                            Text(
                              t.$3,
                              style: TextStyle(fontSize: 10, color: txtSub),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data sources section
// ─────────────────────────────────────────────────────────────────────────────

class _DataSourcesSection extends StatelessWidget {
  final bool isDark;
  final Color cardBg, cardBorder, txtPri, txtSub;

  const _DataSourcesSection({
    required this.isDark,
    required this.cardBg,
    required this.cardBorder,
    required this.txtPri,
    required this.txtSub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📂 Data Sources',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: txtPri,
            ),
          ),
          const SizedBox(height: 14),
          _DataRow(
            icon: '📊',
            title: 'NISR Seasonal Agricultural Survey (SAS)',
            url: 'statistics.gov.rw',
            color: const Color(0xFF00E676),
            txtSub: txtSub,
          ),
          _DataRow(
            icon: '🌤️',
            title: 'Open-Meteo Weather API',
            url: 'open-meteo.com',
            color: const Color(0xFF00B0FF),
            txtSub: txtSub,
          ),
          _DataRow(
            icon: '🛰️',
            title: 'NASA SMAP Satellite Soil Moisture',
            url: 'nasa.gov',
            color: const Color(0xFFFFA726),
            txtSub: txtSub,
          ),
          _DataRow(
            icon: '📱',
            title: "Africa's Talking SMS Gateway",
            url: 'africastalking.com',
            color: const Color(0xFFAB47BC),
            txtSub: txtSub,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '© 2026 CropGuard AI — NISR Hackathon',
              style: TextStyle(
                fontSize: 12,
                color: txtSub,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String icon, title, url;
  final Color color;
  final Color txtSub;

  const _DataRow({
    required this.icon,
    required this.title,
    required this.url,
    required this.color,
    required this.txtSub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(url, style: TextStyle(fontSize: 10, color: txtSub)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
