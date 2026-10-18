import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/theme_provider.dart';
import '../utils/translations.dart';
import 'admin/admin_login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollProgress = 0.0;
  double _plantGrowth = 0.0;

  late AnimationController _introCtrl;
  late Animation<double> _introAnim;
  late AnimationController _particleCtrl;

  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());
  final List<bool> _sectionVisible = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _introAnim = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack);
    _introCtrl.forward();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final cur = _scrollCtrl.offset;
    setState(() {
      _scrollProgress = (cur / max).clamp(0.0, 1.0);
      _plantGrowth = (cur / (max * 0.6)).clamp(0.0, 1.0);
    });
    for (int i = 0; i < _sectionKeys.length; i++) {
      if (_sectionVisible[i]) continue;
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final pos = box.localToGlobal(Offset.zero);
      if (pos.dy < MediaQuery.of(context).size.height * 0.85) {
        setState(() => _sectionVisible[i] = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _introCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang = context.watch<LanguageProvider>().strings;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _ThemeToggleFab(isDark: isDark),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ParticlePainter(progress: _particleCtrl.value, isDark: isDark),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: _scrollCtrl,
            child: Column(
              children: [
                // ── HERO ──────────────────────────────────────────────────
                _HeroSection(introAnim: _introAnim,
                    scrollOffset: _scrollCtrl.hasClients ? _scrollCtrl.offset : 0.0,
                    isDark: isDark, lang: lang),

                // ── STORIES + STICKY PLANT ────────────────────────────────
                if (isDesktop)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Column(children: [
                            _AnimatedStorySection(
                              key: _sectionKeys[1],
                              number: '01', title: lang.step1,
                              subtitle: 'Understanding District Baselines',
                              body: lang.step1Desc,
                              icon: Icons.upload_file,
                              imagePath: 'assets/icon/hero_plant.jpg',
                              imageOnRight: false, visible: _sectionVisible[1],
                              isDark: isDark, accentColor: const Color(0xFF00E676),
                            ),
                            _AnimatedStorySection(
                              key: _sectionKeys[2],
                              number: '02', title: lang.step2,
                              subtitle: 'Weather & Risk Forecasting',
                              body: lang.step2Desc,
                              icon: Icons.psychology,
                              imagePath: 'assets/icon/hero_farmer.jpg',
                              imageOnRight: true, visible: _sectionVisible[2],
                              isDark: isDark, accentColor: const Color(0xFF00B0FF),
                            ),
                          ]),
                        ),
                        SizedBox(
                          width: 300,
                          child: _StickyPlantPanel(
                              growthProgress: _plantGrowth, isDark: isDark, lang: lang),
                        ),
                      ],
                    ),
                  )
                else
                  Column(children: [
                    _PlantGrowthSection(
                        key: _sectionKeys[0], growthProgress: _plantGrowth,
                        visible: _sectionVisible[0], isDark: isDark, lang: lang),
                    _AnimatedStorySection(
                      key: _sectionKeys[1], number: '01', title: lang.step1,
                      subtitle: 'District Baselines', body: lang.step1Desc,
                      icon: Icons.upload_file, imagePath: 'assets/icon/hero_plant.jpg',
                      imageOnRight: false, visible: _sectionVisible[1],
                      isDark: isDark, accentColor: const Color(0xFF00E676),
                    ),
                    _AnimatedStorySection(
                      key: _sectionKeys[2], number: '02', title: lang.step2,
                      subtitle: 'Risk Forecasting', body: lang.step2Desc,
                      icon: Icons.psychology, imagePath: 'assets/icon/hero_farmer.jpg',
                      imageOnRight: true, visible: _sectionVisible[2],
                      isDark: isDark, accentColor: const Color(0xFF00B0FF),
                    ),
                  ]),

                // ── IMPACT ────────────────────────────────────────────────
                _ImpactSection(key: _sectionKeys[3],
                    visible: _sectionVisible[3], isDark: isDark, lang: lang),

                // ── ADMIN ACCESS — web only, hidden on APK ────────────────
                if (kIsWeb)
                  _AdminAccessSection(isDark: isDark, lang: lang),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────
class _ThemeToggleFab extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleFab({required this.isDark});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); context.read<ThemeProvider>().toggleTheme(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52, height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF263338) : const Color(0xFFE0F2E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Stack(children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left: isDark ? 2 : 24, top: 2,
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 13, color: const Color(0xFF0B1617)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Particle background ───────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _ParticlePainter({required this.progress, required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = (baseY - progress * size.height * 0.3 + size.height) % size.height;
      final opacity = (0.3 + 0.4 * math.sin(progress * math.pi * 2 + i.toDouble())).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = AppColors.primary.withOpacity(opacity * (isDark ? 0.4 : 0.15))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 1.5 + rng.nextDouble() * 2.5, paint);
    }
  }
  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

// ── Hero section ──────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final Animation<double> introAnim;
  final double scrollOffset;
  final bool isDark;
  final AppStrings lang;
  const _HeroSection({required this.introAnim, required this.scrollOffset,
      required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return SizedBox(
      height: h * 0.88, width: double.infinity,
      child: Stack(fit: StackFit.expand, children: [
        Positioned(top: -scrollOffset * 0.35, left: 0, right: 0, bottom: 0,
          child: Image.asset('assets/icon/hero_farmer.jpg',
              fit: BoxFit.cover, alignment: Alignment.topCenter)),
        Container(decoration: BoxDecoration(gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.55), Colors.black.withOpacity(0.25),
                   Colors.black.withOpacity(0.75)], stops: const [0.0, 0.4, 1.0]))),
        AnimatedBuilder(
          animation: introAnim,
          builder: (_, __) => Opacity(
            opacity: introAnim.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - introAnim.value)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 110, height: 110,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.6), blurRadius: 40, spreadRadius: 8)],
                    border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2.5)),
                  child: ClipOval(child: Image.asset('assets/icon/logo.png', fit: BoxFit.cover))),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (b) => const LinearGradient(
                    colors: [Color(0xFF00E676), Colors.white, Color(0xFF00E676)]).createShader(b),
                  child: const Text('CropGuard AI',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 1.5))),
                const SizedBox(height: 8),
                Text(lang.appTagline, style: TextStyle(
                    fontSize: 15, color: Colors.white.withOpacity(0.82), letterSpacing: 2)),
                const SizedBox(height: 24),
                const _LiveRiskCounter(),
                const SizedBox(height: 24),
                _GlowButton(label: lang.openDashboard,
                    onTap: () => Navigator.pushNamed(context, '/dashboard')),
                const SizedBox(height: 30),
                _BouncingScrollHint(label: lang.scrollToExplore),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Glow button ───────────────────────────────────────────────────────────────
class _GlowButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _GlowButton({required this.label, required this.onTap});
  @override
  State<_GlowButton> createState() => _GlowButtonState();
}
class _GlowButtonState extends State<_GlowButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _glow = Tween(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _glow, builder: (_, __) => GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4 * _glow.value), blurRadius: 24)]),
        child: Text(widget.label, style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0B1617)))),
    ));
  }
}

// ── Android APK one-tap download (web only) ───────────────────────────────
// Opens the /apk landing page, which auto-starts the APK download for
// Android visitors. Uses url_launcher so it works in every browser.
class _DownloadAppButton extends StatelessWidget {
  final AppStrings lang;
  const _DownloadAppButton({required this.lang});

  static const _apkPageUrl = 'https://nisr-b06b6.web.app/apk';

  Future<void> _openApkPage(BuildContext context) async {
    final uri = Uri.parse(_apkPageUrl);
    if (!await launchUrl(uri, webOnlyWindowName: '_self')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_apkPageUrl)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openApkPage(context),
      icon: const Icon(Icons.android, size: 20, color: Color(0xFF00E676)),
      label: Text(lang.downloadApp,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00E676))),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}


// ── Scroll hint ───────────────────────────────────────────────────────────────
class _BouncingScrollHint extends StatefulWidget {
  final String label;
  const _BouncingScrollHint({required this.label});
  @override
  State<_BouncingScrollHint> createState() => _BouncingScrollHintState();
}
class _BouncingScrollHintState extends State<_BouncingScrollHint> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _bounce = Tween(begin: 0.0, end: 8.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _bounce, builder: (_, __) => Transform.translate(
      offset: Offset(0, _bounce.value),
      child: Column(children: [
        Text(widget.label, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12, letterSpacing: 2)),
        const SizedBox(height: 4),
        const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00E676), size: 22),
      ]),
    ));
  }
}

// ── Sticky plant panel (desktop) ──────────────────────────────────────────────
class _StickyPlantPanel extends StatelessWidget {
  final double growthProgress;
  final bool isDark;
  final AppStrings lang;
  const _StickyPlantPanel({required this.growthProgress, required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0D1F22) : const Color(0xFFE8F5E9);
    final stage = growthProgress < 0.2 ? ('🌱', 'Germination')
        : growthProgress < 0.4 ? ('🌿', 'Seedling')
        : growthProgress < 0.6 ? ('🪴', 'Growing')
        : growthProgress < 0.8 ? ('🌾', 'Maturing')
        : ('🌳', 'Harvest Ready');
    return Container(color: bg, padding: const EdgeInsets.all(20),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(lang.cropGrowthCycle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0B2010)), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(lang.scrollToGrow, style: TextStyle(fontSize: 11,
            color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F))),
        const SizedBox(height: 20),
        Expanded(child: CustomPaint(painter: _PlantPainter(progress: growthProgress, isDark: isDark),
            size: const Size(double.infinity, double.infinity))),
        const SizedBox(height: 16),
        AnimatedSwitcher(duration: const Duration(milliseconds: 400),
          child: Container(key: ValueKey(stage.$2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.4))),
            child: Text('${stage.$1}  ${stage.$2}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF00E676))))),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: growthProgress, minHeight: 8,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00E676)))),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _StageDot(label: '🌱', active: growthProgress >= 0.0),
          _StageDot(label: '🌿', active: growthProgress >= 0.2),
          _StageDot(label: '🪴', active: growthProgress >= 0.4),
          _StageDot(label: '🌾', active: growthProgress >= 0.6),
          _StageDot(label: '🌳', active: growthProgress >= 0.8),
        ]),
      ]),
    );
  }
}

// ── Plant growth section (mobile) ─────────────────────────────────────────────
class _PlantGrowthSection extends StatelessWidget {
  final double growthProgress;
  final bool visible, isDark;
  final AppStrings lang;
  const _PlantGrowthSection({super.key, required this.growthProgress,
      required this.visible, required this.isDark, required this.lang});
  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0D1F22) : const Color(0xFFE8F5E9);
    final stage = growthProgress < 0.2 ? ('🌱', 'Germination')
        : growthProgress < 0.4 ? ('🌿', 'Seedling')
        : growthProgress < 0.6 ? ('🪴', 'Growing')
        : growthProgress < 0.8 ? ('🌾', 'Maturing')
        : ('🌳', 'Harvest Ready');
    return AnimatedOpacity(duration: const Duration(milliseconds: 600), opacity: visible ? 1.0 : 0.0,
      child: Container(color: bg, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(children: [
          Text(lang.cropGrowthCycle, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0B2010))),
          const SizedBox(height: 6),
          Text(lang.scrollToGrow, style: TextStyle(fontSize: 13,
              color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F))),
          const SizedBox(height: 36),
          SizedBox(height: 220, child: CustomPaint(
              painter: _PlantPainter(progress: growthProgress, isDark: isDark),
              size: const Size(200, 220))),
          const SizedBox(height: 20),
          AnimatedSwitcher(duration: const Duration(milliseconds: 400),
            child: Container(key: ValueKey(stage.$2),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4))),
              child: Text('${stage.$1}  ${stage.$2}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF00E676))))),
          const SizedBox(height: 20),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: growthProgress, minHeight: 8,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF00E676)))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _StageDot(label: '🌱', active: growthProgress >= 0.0),
            _StageDot(label: '🌿', active: growthProgress >= 0.2),
            _StageDot(label: '🪴', active: growthProgress >= 0.4),
            _StageDot(label: '🌾', active: growthProgress >= 0.6),
            _StageDot(label: '🌳', active: growthProgress >= 0.8),
          ]),
        ]),
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  final String label;
  final bool active;
  const _StageDot({required this.label, required this.active});
  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: active ? 1.3 : 0.8, duration: const Duration(milliseconds: 300),
    child: Text(label, style: TextStyle(fontSize: active ? 22 : 16)));
}

// ── Plant painter ─────────────────────────────────────────────────────────────
class _PlantPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  _PlantPainter({required this.progress, required this.isDark});
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final ground = size.height * 0.92;
    final groundPaint = Paint()..color = AppColors.primary.withOpacity(0.3)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 60, ground), Offset(cx + 60, ground), groundPaint);
    if (progress <= 0) return;
    final stemPaint = Paint()..color = const Color(0xFF2E7D32)..strokeWidth = 5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final leafPaint = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    final stemH = (size.height * 0.72) * progress;
    final stemTop = ground - stemH;
    final path = Path();
    path.moveTo(cx, ground);
    path.cubicTo(cx + 8 * math.sin(progress * math.pi), ground - stemH * 0.3,
        cx - 8 * math.sin(progress * math.pi), ground - stemH * 0.7, cx, stemTop);
    canvas.drawPath(path, stemPaint);
    void drawLeaf(double x, double y, double size, double angle) {
      final lp = Path();
      lp.moveTo(x, y);
      final dx = math.cos(angle) * size;
      final dy = math.sin(angle) * size * 0.5;
      lp.cubicTo(x + dx * 0.3, y - dy * 1.5, x + dx * 0.7, y - dy * 1.2, x + dx, y);
      lp.cubicTo(x + dx * 0.7, y + dy * 0.8, x + dx * 0.3, y + dy * 0.5, x, y);
      canvas.drawPath(lp, leafPaint);
    }
    if (progress > 0.15) { final t = ((progress - 0.15) / 0.15).clamp(0.0, 1.0); drawLeaf(cx, ground - stemH * 0.25, 28 * t, -math.pi * 0.3); }
    if (progress > 0.3)  { final t = ((progress - 0.3) / 0.2).clamp(0.0, 1.0);  drawLeaf(cx, ground - stemH * 0.45, 32 * t, math.pi + math.pi * 0.3); }
    if (progress > 0.5)  { final t = ((progress - 0.5) / 0.2).clamp(0.0, 1.0);  drawLeaf(cx, ground - stemH * 0.65, 28 * t, -math.pi * 0.25); }
    if (progress > 0.7)  { final t = ((progress - 0.7) / 0.2).clamp(0.0, 1.0);  drawLeaf(cx, ground - stemH * 0.78, 24 * t, math.pi + math.pi * 0.25); }
    if (progress > 0.85) {
      final t = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
      canvas.drawCircle(Offset(cx, stemTop), 10 * t, Paint()..color = AppColors.primary.withOpacity(t)..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(cx, stemTop), 18 * t, Paint()..color = AppColors.primary.withOpacity(0.3 * t)..style = PaintingStyle.fill);
    }
  }
  @override
  bool shouldRepaint(_PlantPainter old) => old.progress != progress;
}

// ── Animated story section ────────────────────────────────────────────────────
class _AnimatedStorySection extends StatelessWidget {
  final String number, title, subtitle, body, imagePath;
  final IconData icon;
  final bool imageOnRight, visible, isDark;
  final Color accentColor;
  const _AnimatedStorySection({super.key, required this.number, required this.title,
      required this.subtitle, required this.body, required this.icon,
      required this.imagePath, required this.imageOnRight, required this.visible,
      required this.isDark, required this.accentColor});
  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 700;
    final cardBg = isDark ? const Color(0xFF112225) : Colors.white;
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFCCE8D8);
    final txtPri = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtBody = isDark ? const Color(0xFFDEE5E7) : const Color(0xFF1A2E20);
    final content = AnimatedOpacity(duration: const Duration(milliseconds: 700), opacity: visible ? 1.0 : 0.0,
      child: AnimatedSlide(duration: const Duration(milliseconds: 700),
        offset: visible ? Offset.zero : Offset(imageOnRight ? -0.15 : 0.15, 0),
        child: Container(padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
            boxShadow: [BoxShadow(color: accentColor.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(number, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: accentColor))),
              const SizedBox(width: 10),
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(subtitle, style: TextStyle(fontSize: 12, color: accentColor,
                  fontWeight: FontWeight.w600, letterSpacing: 0.8), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 14),
            Text(title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: txtPri, height: 1.2)),
            const SizedBox(height: 12),
            Text(body, style: TextStyle(fontSize: 14, color: txtBody, height: 1.65)),
          ]),
        ),
      ),
    );
    final image = AnimatedOpacity(duration: const Duration(milliseconds: 700), opacity: visible ? 1.0 : 0.0,
      child: AnimatedSlide(duration: const Duration(milliseconds: 700),
        offset: visible ? Offset.zero : Offset(imageOnRight ? 0.15 : -0.15, 0),
        child: ClipRRect(borderRadius: BorderRadius.circular(20),
          child: Image.asset(imagePath, fit: BoxFit.cover, height: isNarrow ? 200 : 280))));
    final padding = EdgeInsets.symmetric(horizontal: isNarrow ? 16 : 60, vertical: 40);
    if (isNarrow) return Padding(padding: padding, child: Column(children: imageOnRight
        ? [content, const SizedBox(height: 20), image]
        : [image, const SizedBox(height: 20), content]));
    return Padding(padding: padding, child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: imageOnRight
        ? [Expanded(child: content), const SizedBox(width: 24), Expanded(child: image)]
        : [Expanded(child: image), const SizedBox(width: 24), Expanded(child: content)]));
  }
}

// ── Impact section ────────────────────────────────────────────────────────────
class _ImpactSection extends StatelessWidget {
  final bool visible, isDark;
  final AppStrings lang;
  const _ImpactSection({super.key, required this.visible, required this.isDark, required this.lang});
  @override
  Widget build(BuildContext context) {
    final txtPri = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtSub = isDark ? const Color(0xFFDEE5E7) : const Color(0xFF1A2E20);
    final cardBg = isDark ? const Color(0xFF112225) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF263338) : const Color(0xFFCCE8D8);
    return AnimatedOpacity(duration: const Duration(milliseconds: 800), opacity: visible ? 1.0 : 0.0,
      child: AnimatedSlide(duration: const Duration(milliseconds: 800), offset: visible ? Offset.zero : const Offset(0, 0.1),
        child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
          child: Column(children: [
            ShaderMask(shaderCallback: (b) => const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00B0FF)]).createShader(b),
              child: Text('Impact at Scale', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))),
            const SizedBox(height: 8),
            Text('Real numbers. Real impact.', style: TextStyle(fontSize: 15, color: txtSub)),
            const SizedBox(height: 40),
            Wrap(spacing: 16, runSpacing: 16, alignment: WrapAlignment.center, children: [
              _StatCard(value: '30', label: 'Districts\nMonitored', icon: Icons.location_on, accent: const Color(0xFF00E676), cardBg: cardBg, cardBorder: cardBorder, txtPri: txtPri, txtSub: txtSub),
              _StatCard(value: '21', label: 'Storage\nFacilities', icon: Icons.warehouse, accent: const Color(0xFF00B0FF), cardBg: cardBg, cardBorder: cardBorder, txtPri: txtPri, txtSub: txtSub),
              _StatCard(value: '6h', label: 'Update\nCycle', icon: Icons.refresh, accent: const Color(0xFFFFA726), cardBg: cardBg, cardBorder: cardBorder, txtPri: txtPri, txtSub: txtSub),
              _StatCard(value: '3', label: 'Languages\nSupported', icon: Icons.translate, accent: const Color(0xFFAB47BC), cardBg: cardBg, cardBorder: cardBorder, txtPri: txtPri, txtSub: txtSub),
            ]),
            const SizedBox(height: 48),
            _GlowButton(label: lang.openDashboard,
                onTap: () => Navigator.pushNamed(context, '/dashboard')),
            // ── Android APK download ──────────────────────────────────
            // Web only: Android visitors tap once → /apk page auto-starts
            // the APK download. Hidden inside the installed APK itself.
            if (kIsWeb) ...[
              const SizedBox(height: 12),
              _DownloadAppButton(lang: lang),
            ],
          ]),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color accent, cardBg, cardBorder, txtPri, txtSub;
  const _StatCard({required this.value, required this.label, required this.icon,
      required this.accent, required this.cardBg, required this.cardBorder,
      required this.txtPri, required this.txtSub});
  @override
  Widget build(BuildContext context) {
    return Container(width: 140, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Column(children: [
        Icon(icon, color: accent, size: 28),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: accent)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: txtSub, height: 1.4)),
      ]));
  }
}

// ── Admin access section ──────────────────────────────────────────────────────
class _AdminAccessSection extends StatelessWidget {
  final bool isDark;
  final AppStrings lang;
  const _AdminAccessSection({required this.isDark, required this.lang});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminLoginScreen())),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primary.withOpacity(0.05),
          ),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.admin_panel_settings, color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admin Panel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
              Text(lang.languageCode == 'rw' ? 'Injira nk\'umunyamabanga' :
                   lang.languageCode == 'fr' ? 'Accès administrateur' :
                   'System management for authorized users',
                   style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F))),
            ])),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
          ]),
        ),
      ),
    );
  }
}

// ── Live risk counter ─────────────────────────────────────────────────────────
class _LiveRiskCounter extends StatefulWidget {
  const _LiveRiskCounter();
  @override
  State<_LiveRiskCounter> createState() => _LiveRiskCounterState();
}
class _LiveRiskCounterState extends State<_LiveRiskCounter> with SingleTickerProviderStateMixin {
  int _red = 0, _yellow = 0, _green = 0;
  bool _loaded = false;
  late AnimationController _anim;
  late Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
    _load();
  }
  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/data/risk_scores.json');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final districts = data['districts'] as List;
      int r = 0, y = 0, g = 0;
      for (final d in districts) {
        final level = (d['risk'] as Map?)?['level'] ?? 'green';
        if (level == 'red') r++; else if (level == 'yellow') y++; else g++;
      }
      if (mounted) { setState(() { _red=r; _yellow=y; _green=g; _loaded=true; }); _anim.forward(); }
    } catch (_) {}
  }
  @override
  void dispose() { _anim.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return FadeTransition(opacity: _fade,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.35))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Dot(color: const Color(0xFFDC2626), count: _red, label: 'High'),
          const SizedBox(width: 14),
          _Dot(color: const Color(0xFFF59E0B), count: _yellow, label: 'Moderate'),
          const SizedBox(width: 14),
          _Dot(color: const Color(0xFF00E676), count: _green, label: 'Safe'),
        ]),
      ),
    );
  }
}
class _Dot extends StatelessWidget {
  final Color color; final int count; final String label;
  const _Dot({required this.color, required this.count, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text('$count $label', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
  ]);
}
