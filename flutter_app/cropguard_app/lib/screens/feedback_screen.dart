import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/theme_provider.dart';
import '../widgets/holographic_card.dart';

// ── Feedback Screen ───────────────────────────────────────────────────────────

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  String _feedbackType = 'suggestion';
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  static const _types = [
    ('suggestion', '💡', 'Suggestion'),
    ('bug',        '🐛', 'Bug Report'),
    ('support',    '🆘', 'Support Request'),
    ('compliment', '⭐', 'Compliment'),
    ('other',      '📝', 'Other'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _submitting = true; _error = null; });

    try {
      await FirebaseFirestore.instance.collection('feedback').add({
        'name':    _nameCtrl.text.trim(),
        'email':   _emailCtrl.text.trim(),
        'type':    _feedbackType,
        'message': _msgCtrl.text.trim(),
        // ISO timestamp — used by Firestore rate-limit rule
        'submitted_at': FieldValue.serverTimestamp(),
        // Basic fingerprint to detect spam (not PII — just helps moderation)
        'app_version': '1.0.0',
      });
      if (mounted) setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Could not submit. Please check your connection and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang   = context.watch<LanguageProvider>().strings;

    final bg      = isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4);
    final txtPri  = isDark ? Colors.white             : const Color(0xFF0B2010);
    final txtSub  = isDark ? const Color(0xFFB0BEC5)  : const Color(0xFF37474F);
    final cardBg  = isDark ? const Color(0xFF112225)  : Colors.white;
    final inputBg = isDark ? const Color(0xFF152629)  : const Color(0xFFF7FBF9);
    final border  = isDark ? const Color(0xFF263338)  : const Color(0xFFCCE8D8);

    return Container(
      color: bg,
      child: _submitted
          ? _SuccessBanner(isDark: isDark, txtPri: txtPri, txtSub: txtSub,
              onAnother: () => setState(() {
                _submitted = false;
                _nameCtrl.clear();
                _emailCtrl.clear();
                _msgCtrl.clear();
                _feedbackType = 'suggestion';
              }))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ────────────────────────────────────────────
                      Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: AppGradients.greenGlowGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.feedback_outlined,
                              color: Color(0xFF0B1617), size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Feedback & Support',
                                style: TextStyle(fontSize: 20,
                                    fontWeight: FontWeight.w800, color: txtPri)),
                            Text('Help us improve CropGuard AI',
                                style: TextStyle(fontSize: 13, color: txtSub)),
                          ],
                        )),
                      ]),

                      const SizedBox(height: 24),

                      // ── Feedback type chips ───────────────────────────────
                      HolographicCard(
                        accentColor: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('What is this about?',
                                  style: TextStyle(fontSize: 13,
                                      fontWeight: FontWeight.w700, color: txtPri)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8, runSpacing: 8,
                                children: _types.map((t) {
                                  final isActive = _feedbackType == t.$1;
                                  return GestureDetector(
                                    onTap: () => setState(() => _feedbackType = t.$1),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? AppColors.primary.withOpacity(0.15)
                                            : inputBg,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isActive
                                              ? AppColors.primary
                                              : border,
                                          width: isActive ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Text('${t.$2} ${t.$3}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isActive
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isActive
                                                ? AppColors.primary
                                                : txtSub,
                                          )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Form ─────────────────────────────────────────────
                      HolographicCard(
                        accentColor: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                _Label('Your Name', txtPri),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _nameCtrl,
                                  hint: 'e.g. Jean de Dieu Uwimana',
                                  inputBg: inputBg,
                                  border: border,
                                  txtPri: txtPri,
                                  txtSub: txtSub,
                                  validator: (v) => (v == null || v.trim().isEmpty)
                                      ? 'Name is required' : null,
                                ),

                                const SizedBox(height: 16),

                                // Email (optional)
                                _Label('Email (optional — for follow-up)', txtPri),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _emailCtrl,
                                  hint: 'your@email.com',
                                  inputBg: inputBg,
                                  border: border,
                                  txtPri: txtPri,
                                  txtSub: txtSub,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) return null;
                                    if (!v.contains('@') || !v.contains('.')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Message
                                _Label('Your Message', txtPri),
                                const SizedBox(height: 6),
                                _InputField(
                                  controller: _msgCtrl,
                                  hint: _placeholderFor(_feedbackType),
                                  inputBg: inputBg,
                                  border: border,
                                  txtPri: txtPri,
                                  txtSub: txtSub,
                                  maxLines: 5,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Message is required';
                                    }
                                    if (v.trim().length < 10) {
                                      return 'Please write at least 10 characters';
                                    }
                                    // Basic XSS / injection guard
                                    if (v.contains('<script') ||
                                        v.contains('javascript:')) {
                                      return 'Invalid content detected';
                                    }
                                    return null;
                                  },
                                ),

                                if (_error != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.alertRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.alertRed.withOpacity(0.4)),
                                    ),
                                    child: Row(children: [
                                      const Icon(Icons.error_outline,
                                          color: AppColors.alertRed, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_error!,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.alertRed))),
                                    ]),
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Submit button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _submitting ? null : _submit,
                                    icon: _submitting
                                        ? const SizedBox(
                                            width: 16, height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF0B1617)))
                                        : const Icon(Icons.send_rounded, size: 18),
                                    label: Text(_submitting
                                        ? 'Submitting...' : 'Send Feedback'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: const Color(0xFF0B1617),
                                      disabledBackgroundColor:
                                          AppColors.primary.withOpacity(0.5),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      textStyle: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Direct contact ────────────────────────────────────
                      HolographicCard(
                        accentColor: AppColors.primary,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(
                              'For urgent matters, contact the NISR data team directly at '
                              'statistics@nisr.gov.rw or visit statistics.gov.rw',
                              style: TextStyle(fontSize: 12, color: txtSub, height: 1.5),
                            )),
                          ]),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String _placeholderFor(String type) {
    switch (type) {
      case 'bug':
        return 'Describe what happened, what you expected, and steps to reproduce…';
      case 'support':
        return 'Describe what you need help with…';
      case 'compliment':
        return 'Tell us what you like about CropGuard AI…';
      case 'suggestion':
      default:
        return 'Describe your idea or suggestion for improving CropGuard AI…';
    }
  }
}

// ── Success banner ────────────────────────────────────────────────────────────

class _SuccessBanner extends StatelessWidget {
  final bool isDark;
  final Color txtPri, txtSub;
  final VoidCallback onAnother;

  const _SuccessBanner({
    required this.isDark,
    required this.txtPri,
    required this.txtSub,
    required this.onAnother,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: AppGradients.greenGlowGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 30, spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF0B1617), size: 40),
            ),
            const SizedBox(height: 24),
            Text('Thank you!',
                style: TextStyle(fontSize: 26,
                    fontWeight: FontWeight.w800, color: txtPri)),
            const SizedBox(height: 8),
            Text('Your feedback has been submitted successfully.\n'
                'The CropGuard AI team will review it shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: txtSub, height: 1.6)),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: onAnother,
              icon: const Icon(Icons.add_comment_outlined, size: 18),
              label: const Text('Send Another'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color inputBg, border, txtPri, txtSub;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.inputBg,
    required this.border,
    required this.txtPri,
    required this.txtSub,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, color: txtPri),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: txtSub.withOpacity(0.6)),
        filled: true,
        fillColor: inputBg,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.alertRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
              color: AppColors.alertRed, width: 1.5),
        ),
      ),
    );
  }
}
