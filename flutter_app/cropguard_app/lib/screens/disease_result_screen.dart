import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/disease_model.dart';
import '../utils/colors.dart';
import '../utils/theme_provider.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';
import '../utils/translations.dart';

/// Shows the AI scan result: disease name, confidence, symptoms, treatment steps
class DiseaseResultScreen extends StatefulWidget {
  final ScanResult result;

  const DiseaseResultScreen({super.key, required this.result});

  @override
  State<DiseaseResultScreen> createState() => _DiseaseResultScreenState();
}

class _DiseaseResultScreenState extends State<DiseaseResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFDC2626);
      case 'high':
        return const Color(0xFFEA580C);
      case 'moderate':
        return const Color(0xFFCA8A04);
      default:
        return const Color(0xFF16A34A);
    }
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical':
        return '🔴 CRITICAL';
      case 'high':
        return '🟠 HIGH';
      case 'moderate':
        return '🟡 MODERATE';
      default:
        return '🟢 HEALTHY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang = context.watch<LanguageProvider>().strings;
    final d = widget.result.disease;
    final pct = (widget.result.confidence * 100).toStringAsFixed(1);
    final isHealthy = d.id == 'healthy_plant';

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF152629) : Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          lang.scanResult,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0B2010),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: lang.scanShare,
            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(lang.scanShareSoon),
                    duration: const Duration(seconds: 2)),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Scanned image ──────────────────────────────────────────
                _ScannedImageCard(
                    imagePath: widget.result.imagePath,
                    imageBytes: widget.result.imageBytes,
                    isDark: isDark),
                const SizedBox(height: 16),

                // ── Disease name card ───────────────────────────────────────
                _DiseaseHeaderCard(
                  disease: d,
                  confidence: double.parse(pct),
                  severityColor: _severityColor(d.severity),
                  severityLabel: _severityLabel(d.severity),
                  isDark: isDark,
                  isHealthy: isHealthy,
                ),
                const SizedBox(height: 16),

                if (!isHealthy) ...[
                  // ── Symptoms — from AI vision analysis ───────────────────
                  _SectionCard(
                    title: lang.scanSymptoms,
                    isDark: isDark,
                    child: Column(
                      children: (widget.result.aiSymptoms.isNotEmpty
                              ? widget.result.aiSymptoms
                              : d.symptoms)
                          .map((s) => _BulletItem(text: s, isDark: isDark))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Causes ───────────────────────────────────────────────
                  _SectionCard(
                    title: lang.scanCauses,
                    isDark: isDark,
                    child: Column(
                      children: d.causes
                          .map((c) => _BulletItem(text: c, isDark: isDark))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Treatment steps — from AI vision analysis ────────────
                  _TreatmentCard(
                    steps: widget.result.aiTreatment.isNotEmpty
                        ? widget.result.aiTreatment
                        : d.treatmentSteps,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),

                  // ── Prevention — from AI vision analysis ─────────────────
                  _SectionCard(
                    title: lang.scanPrevention,
                    isDark: isDark,
                    child: Column(
                      children: (widget.result.aiPrevention.isNotEmpty
                              ? widget.result.aiPrevention
                              : d.preventionTips)
                          .map((p) => _BulletItem(text: p, isDark: isDark))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Alternative diagnoses ────────────────────────────────
                  _AlternativesCard(
                      alternatives: widget.result.alternatives,
                      isDark: isDark),
                  const SizedBox(height: 12),
                ] else ...[
                  _SectionCard(
                    title: lang.scanHealthyAdvice,
                    isDark: isDark,
                    child: Column(
                      children: d.treatmentSteps
                          .map((s) => _BulletItem(text: s, isDark: isDark))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Scan again button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.camera_alt, size: 20),
                    label: Text(lang.scanScanAgain),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF0B1617),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _ScannedImageCard extends StatelessWidget {
  final String imagePath;
  final Uint8List? imageBytes;
  final bool isDark;
  const _ScannedImageCard(
      {required this.imagePath, this.imageBytes, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        width: double.infinity,
        color: isDark ? const Color(0xFF1A3035) : const Color(0xFFE8F5E9),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    Widget fallback() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: AppColors.primary, size: 64),
              SizedBox(height: 8),
              Text('Plant Image',
                  style: TextStyle(color: AppColors.primary)),
            ],
          ),
        );

    // In-memory bytes always win: they render even if the temp file was
    // cleaned or gallery pickers return odd paths (the black-box bug).
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }
}

class _DiseaseHeaderCard extends StatelessWidget {
  final PlantDisease disease;
  final double confidence;
  final Color severityColor;
  final String severityLabel;
  final bool isDark;
  final bool isHealthy;

  const _DiseaseHeaderCard({
    required this.disease,
    required this.confidence,
    required this.severityColor,
    required this.severityLabel,
    required this.isDark,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);
    final subColor =
        isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
              color: severityColor.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: severityColor.withOpacity(0.4), width: 1),
            ),
            child: Text(
              severityLabel,
              style: TextStyle(
                color: severityColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Disease name + emoji
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(disease.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      disease.scientificName,
                      style: TextStyle(
                        color: subColor,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Crop affected
          Row(
            children: [
              const Icon(Icons.eco, color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                '${lang.scanCropLabel} ${disease.cropAffected}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Confidence bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.scanConfidence,
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                  Text(
                    '$confidence%',
                    style: TextStyle(
                      color: isHealthy ? AppColors.primary : severityColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: confidence / 100,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? const Color(0xFF263338)
                      : const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isHealthy ? AppColors.primary : severityColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            disease.description,
            style: TextStyle(
              color: subColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TreatmentCard extends StatefulWidget {
  final List<String> steps;
  final bool isDark;
  const _TreatmentCard({required this.steps, required this.isDark});

  @override
  State<_TreatmentCard> createState() => _TreatmentCardState();
}

class _TreatmentCardState extends State<_TreatmentCard> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final cardBg = widget.isDark ? const Color(0xFF1A3035) : Colors.white;
    final titleColor = widget.isDark ? Colors.white : const Color(0xFF0B2010);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                lang.scanTreatment,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${_completed.length}/${widget.steps.length}',
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lang.scanTreatmentTap,
            style: TextStyle(
              color: widget.isDark
                  ? const Color(0xFF7B9EA0)
                  : const Color(0xFF78909C),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.steps.asMap().entries.map((e) {
            final idx = e.key;
            final step = e.value;
            final done = _completed.contains(idx);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  if (done) {
                    _completed.remove(idx);
                  } else {
                    _completed.add(idx);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primary.withOpacity(0.12)
                      : (widget.isDark
                          ? const Color(0xFF112225)
                          : const Color(0xFFF5F5F5)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: done
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.primary
                            : (widget.isDark
                                ? const Color(0xFF263338)
                                : const Color(0xFFE0E0E0)),
                      ),
                      child: Icon(
                        done ? Icons.check : Icons.circle_outlined,
                        size: 14,
                        color: done
                            ? const Color(0xFF0B1617)
                            : (widget.isDark
                                ? const Color(0xFF7B9EA0)
                                : const Color(0xFF90A4AE)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          color: done
                              ? AppColors.primary
                              : (widget.isDark
                                  ? const Color(0xFFCFD8DC)
                                  : const Color(0xFF37474F)),
                          fontSize: 13,
                          height: 1.4,
                          decoration:
                              done ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const _SectionCard(
      {required this.title, required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0B2010);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF263338)
              : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  final bool isDark;
  const _BulletItem({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFFCFD8DC)
                    : const Color(0xFF37474F),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativesCard extends StatelessWidget {
  final List<PlantDisease> alternatives;
  final bool isDark;
  const _AlternativesCard(
      {required this.alternatives, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0B2010);
    final subColor =
        isDark ? const Color(0xFF7B9EA0) : const Color(0xFF78909C);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF263338)
              : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.scanAlternatives,
            style: TextStyle(
              color: titleColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            lang.scanAlternativesSub,
            style: TextStyle(color: subColor, fontSize: 11),
          ),
          const SizedBox(height: 12),
          ...alternatives.map((alt) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF112225)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(alt.emoji,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alt.name,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            alt.cropAffected,
                            style: TextStyle(
                                color: subColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B9EA0).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lang.scanAlt,
                        style: TextStyle(
                            color: subColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
