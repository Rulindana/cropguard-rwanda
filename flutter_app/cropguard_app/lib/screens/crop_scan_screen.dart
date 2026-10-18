import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show instantiateImageCodec;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/disease_model.dart';
import '../services/ai_service.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/theme_provider.dart';
import 'disease_result_screen.dart';

/// CropGuard AI — Crop Disease Scan Screen
/// Lets farmers take or upload a photo of a plant leaf and get
/// instant AI-powered disease detection and treatment advice.
class CropScanScreen extends StatefulWidget {
  const CropScanScreen({super.key});

  @override
  State<CropScanScreen> createState() => _CropScanScreenState();
}

class _CropScanScreenState extends State<CropScanScreen>
    with TickerProviderStateMixin {
  final _picker = ImagePicker();

  // UI state
  String? _selectedImagePath;
  XFile? _selectedFile;
  Uint8List? _previewBytes;
  bool _isAnalyzing = false;
  String _analyzeStatus = '';

  // Animations
  late AnimationController _pulseCtrl;
  late AnimationController _scanLineCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _scanLineAnim;
  late Animation<double> _fadeAnim;

  // Scanning status messages — populated from translations in build()
  List<String> _analysisSteps = [];
  int _stepIndex = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _scanLineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineCtrl, curve: Curves.linear),
    );

    _fadeAnim =
        CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _scanLineCtrl.dispose();
    _fadeCtrl.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  // ── Permission dialog ─────────────────────────────────────────────────────

  /// Shows a friendly permission explanation dialog before opening camera/gallery.
  /// Returns true if user pressed Allow, false if they pressed Skip/Cancel.
  Future<bool> _showPermissionDialog({required bool isCamera}) async {
    final lang = context.read<LanguageProvider>().strings;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
        final textColor = isDark ? Colors.white : const Color(0xFF0B2010);
        final subColor = isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCamera ? Icons.camera_alt : Icons.photo_library,
                    color: AppColors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  isCamera ? lang.scanAllowCamera : lang.scanAllowGallery,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  isCamera ? lang.scanCameraDesc : lang.scanGalleryDesc,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 13,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Privacy note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline,
                          color: AppColors.primary, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lang.scanPrivacyNote,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(ctx).pop(true);
                    },
                    icon: Icon(isCamera ? Icons.camera_alt : Icons.photo_library,
                        size: 18),
                    label: Text(
                      isCamera ? lang.scanAllowCameraBtn : lang.scanAllowGalleryBtn,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: const Color(0xFF0B1617),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(ctx).pop(false);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: subColor,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(lang.scanSkip,
                        style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }

  // ── Image picking ─────────────────────────────────────────────────────────

  /// Returns true if the user has previously granted the permission (stored in prefs).
  Future<bool> _isPermissionGranted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  /// Remembers that the user granted the permission so we never ask again.
  Future<void> _savePermissionGranted(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  /// Copies the picked photo into our OWN app-documents folder so the file
  /// survives after image_picker's temp cache is cleaned. Without this the
  /// preview/result screens render a stale path = dark/black box.
  Future<void> _keepPickedPhoto(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final ext = p.extension(file.path).isNotEmpty
          ? p.extension(file.path)
          : '.jpg';
      final stablePath =
          p.join(dir.path, 'scan_${DateTime.now().millisecondsSinceEpoch}$ext');
      await File(stablePath).writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      setState(() {
        _selectedFile = file;
        _selectedImagePath = stablePath;
        _previewBytes = bytes;
      });
    } catch (_) {
      // Fall back to the raw picker path if the copy fails.
      if (!mounted) return;
      setState(() {
        _selectedFile = file;
        _selectedImagePath = file.path;
        _previewBytes = null;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    HapticFeedback.mediumImpact();
    if (!kIsWeb) {
      // Only show custom dialog the first time; after that proceed directly
      final alreadyGranted = await _isPermissionGranted('camera_perm_granted');
      if (!alreadyGranted) {
        final allowed = await _showPermissionDialog(isCamera: true);
        if (!allowed) return;
        await _savePermissionGranted('camera_perm_granted');
      }
    }
    try {
      final XFile? file =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (file != null) {
        await _keepPickedPhoto(file);
      }
    } catch (e) {
      _showError(context.read<LanguageProvider>().strings.scanCameraError);
    }
  }

  Future<void> _pickFromGallery() async {
    HapticFeedback.lightImpact();
    if (!kIsWeb) {
      // Only show custom dialog the first time; after that proceed directly
      final alreadyGranted = await _isPermissionGranted('gallery_perm_granted');
      if (!alreadyGranted) {
        final allowed = await _showPermissionDialog(isCamera: false);
        if (!allowed) return;
        await _savePermissionGranted('gallery_perm_granted');
      }
    }
    try {
      final XFile? file = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 85);
      if (file != null) {
        await _keepPickedPhoto(file);
      }
    } catch (e) {
      _showError(context.read<LanguageProvider>().strings.scanGalleryError);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Analysis ──────────────────────────────────────────────────────────────

  /// Validates that the image contains plant-like content by analyzing
  /// green color ratios in the image bytes. Returns true if it looks like a plant.
  Future<bool> _isPlantImage(String imagePath) async {
    try {
      Uint8List bytes;
      if (kIsWeb) {
        // On web we can't read file bytes easily — assume valid
        return true;
      }
      bytes = await File(imagePath).readAsBytes();

      // Decode image to get pixel data using Flutter's image decoder
      final codec = await instantiateImageCodec(bytes, targetWidth: 80, targetHeight: 80);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final byteData = await image.toByteData();
      image.dispose();

      if (byteData == null) return true; // Can't validate → allow

      int greenDominantPixels = 0;
      int totalPixels = 0;
      final pixelBytes = byteData.buffer.asUint8List();

      // Sample every 4th pixel (RGBA format)
      for (int i = 0; i < pixelBytes.length; i += 16) {
        final r = pixelBytes[i];
        final g = pixelBytes[i + 1];
        final b = pixelBytes[i + 2];
        // A pixel is "plant-like" if:
        // - green is the dominant channel
        // - OR it has significant brown/yellow-green (earth, dried leaves)
        final isGreenDominant = g > r && g > b && g > 60;
        final isBrownYellow = r > 80 && g > 60 && b < 80 && r > b;
        if (isGreenDominant || isBrownYellow) greenDominantPixels++;
        totalPixels++;
      }

      if (totalPixels == 0) return true;
      final greenRatio = greenDominantPixels / totalPixels;
      // Plant images typically have >18% green/brown-plant pixels
      return greenRatio >= 0.18;
    } catch (e) {
      // If validation fails for any reason, allow the scan
      return true;
    }
  }

  /// Shows an honest dialog when the model saw a real plant whose crop is
  /// NOT in our disease database (e.g. avocado seedling) — never a disease.
  Future<void> _showNotCoveredDialog({
    required String cropSeen,
    required String notes,
  }) async {
    final lang = context.read<LanguageProvider>().strings;
    final isDark = context.read<ThemeProvider>().isDark;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF00C853).withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C853).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('🌳', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(height: 16),
              Text(
                lang.scanNotCoveredTitle,
                style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                lang.scanNotCoveredDesc(cropSeen, notes),
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF7B9EA0)
                      : const Color(0xFF546E7A),
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _clearImage();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B1617),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    lang.scanErrorTryAgain,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a dialog telling the user the image is not a plant.
  Future<void> _showNotPlantDialog() async {
    final lang = context.read<LanguageProvider>().strings;
    final isDark = context.read<ThemeProvider>().isDark;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_rounded, color: Color(0xFFDC2626), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                lang.languageCode == 'rw'
                    ? 'Ifoto Ntabwo Ari Ikimera'
                    : lang.languageCode == 'fr'
                        ? 'Image Non Végétale Détectée'
                        : 'Not a Plant Image',
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                lang.languageCode == 'rw'
                    ? 'AI yabonetse ko ifoto wafashe atari ikimera cyangwa ikibabi. Nyamuneka fata ifoto nziza y\'ikibabi kirwaye cyangwa ishyamba ry\'imyaka.'
                    : lang.languageCode == 'fr'
                        ? 'L\'IA a détecté que cette image ne semble pas être une plante ou une feuille. Veuillez prendre une photo claire d\'une feuille malade ou d\'une culture.'
                        : 'The AI detected that this image does not appear to be a plant or leaf. Please take a clear photo of a diseased leaf or crop.',
                style: TextStyle(
                  color: isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A),
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  lang.languageCode == 'rw'
                      ? '✅ Ingero: ibigori, ibishyimbo, ibirayi, ingano, ikawa, ikimera cyangwa ikibabi'
                      : lang.languageCode == 'fr'
                          ? '✅ Exemples: maïs, haricots, pommes de terre, blé, café, ou toute feuille/plante'
                          : '✅ Examples: maize, beans, potato, wheat, coffee, or any leaf/plant',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.of(ctx).pop();
                    _clearImage();
                  },
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: Text(
                    lang.languageCode == 'rw'
                        ? 'Fata Ifoto Nshya'
                        : lang.languageCode == 'fr'
                            ? 'Reprendre une Photo'
                            : 'Take a New Photo',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B1617),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _analyzeImage() async {
    if (_selectedImagePath == null) return;
    HapticFeedback.mediumImpact();
    final lang = context.read<LanguageProvider>().strings;
    final ai = AIService();

    if (!ai.isConfigured) {
      await _showScanErrorDialog(
        title: lang.scanErrorNotConfiguredTitle,
        message: lang.scanErrorNotConfiguredDesc,
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _stepIndex = 0;
      _analyzeStatus = _analysisSteps[0];
    });

    // Progress steps advance while the real model call runs
    _stepTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _stepIndex =
            (_stepIndex + 1).clamp(0, _analysisSteps.length - 1);
        _analyzeStatus = _analysisSteps[_stepIndex];
      });
      if (_stepIndex >= _analysisSteps.length - 1) timer.cancel();
    });

    // Read the real image bytes (XFile works on mobile AND web).
    // The progress timer keeps running until the model call finishes.
    late final Uint8List bytes;
    try {
      if (_selectedFile != null) {
        bytes = await _selectedFile!.readAsBytes();
      } else if (!kIsWeb) {
        bytes = await File(_selectedImagePath!).readAsBytes();
      } else {
        throw Exception('Image source unavailable');
      }
    } catch (e) {
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      await _showScanErrorDialog(
        title: lang.scanErrorServiceTitle,
        message: lang.scanErrorServiceDesc,
      );
      return;
    }

    // ── Plant validation ────────────────────────────────────────
    // Free on-device pixel pre-filter: reject obvious non-plant photos
    // before spending an API call. The model validates again in depth.
    final looksLikePlant = await _isPlantImage(_selectedImagePath!);
    if (!looksLikePlant) {
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      await _showNotPlantDialog();
      return;
    }

    // Real AI diagnosis — the photo is sent to the vision model
    try {
      final diagnosis = await ai.diagnose(
        imageBytes: bytes,
        mimeType: _mimeTypeFor(_selectedImagePath!),
        languageCode: lang.languageCode,
      );

      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      if (!mounted) return;

      if (!diagnosis.isPlant) {
        await _showNotPlantDialog();
        return;
      }

      if (!diagnosis.cropCovered) {
        await _showNotCoveredDialog(
          cropSeen: diagnosis.cropSeen,
          notes: diagnosis.notes,
        );
        return;
      }

      final disease = diagnosis.disease;
      if (disease == null) {
        await _showScanErrorDialog(
          title: lang.scanErrorServiceTitle,
          message: lang.scanErrorNoMatchDesc,
        );
        return;
      }

      // Navigate to result screen with the REAL diagnosis
      final result = ScanResult(
        disease: disease,
        confidence: diagnosis.confidence,
        imagePath: _selectedImagePath!,
        imageBytes: bytes,
        scannedAt: DateTime.now(),
        alternatives: diagnosis.alternatives,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiseaseResultScreen(result: result),
        ),
      );
    } on AIServiceException catch (e) {
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      final (title, message) = switch (e.kind) {
        AIServiceErrorKind.notConfigured =>
          (lang.scanErrorNotConfiguredTitle, lang.scanErrorNotConfiguredDesc),
        AIServiceErrorKind.network =>
          (lang.scanErrorNetworkTitle, lang.scanErrorNetworkDesc),
        _ => (lang.scanErrorServiceTitle, lang.scanErrorServiceDesc),
      };
      if (!mounted) return;
      await _showScanErrorDialog(title: title, message: message);
    } catch (e) {
      _stepTimer?.cancel();
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      if (!mounted) return;
      await _showScanErrorDialog(
        title: lang.scanErrorServiceTitle,
        message: lang.scanErrorServiceDesc,
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedFile = null;
      _selectedImagePath = null;
      _isAnalyzing = false;
    });
  }

  /// Guesses the MIME type of the picked image for the vision API.
  String _mimeTypeFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'image/heic';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  /// Honest error dialog for real AI-service failures (no fake fallbacks).
  Future<void> _showScanErrorDialog({
    required String title,
    required String message,
  }) async {
    final lang = context.read<LanguageProvider>().strings;
    final isDark = context.read<ThemeProvider>().isDark;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);

    await showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: Color(0xFFF59E0B),
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  color:
                      isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A),
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: const Color(0xFF0B1617),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    lang.scanErrorTryAgain,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang = context.watch<LanguageProvider>().strings;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Populate analysis steps from translations every build so language changes apply
    _analysisSteps = [
      lang.scanStep1, lang.scanStep2, lang.scanStep3, lang.scanStep4,
      lang.scanStep5, lang.scanStep6, lang.scanStep7,
    ];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : double.infinity),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────────
                  _HeaderSection(isDark: isDark),
                  const SizedBox(height: 20),

                  // ── Scan area ────────────────────────────────────────────
                  _selectedImagePath == null
                      ? _EmptyState(
                          isDark: isDark,
                          pulseAnim: _pulseAnim,
                          onCamera: _pickFromCamera,
                          onGallery: _pickFromGallery,
                        )
                      : _ImagePreview(
                          imagePath: _selectedImagePath!,
                          imageBytes: _previewBytes,
                          isDark: isDark,
                          isAnalyzing: _isAnalyzing,
                          analyzeStatus: _analyzeStatus,
                          stepIndex: _stepIndex,
                          totalSteps: _analysisSteps.length,
                          scanLineAnim: _scanLineAnim,
                          onClear: _clearImage,
                          onAnalyze: _analyzeImage,
                        ),

                  const SizedBox(height: 20),

                  // ── Tips ─────────────────────────────────────────────────
                  _TipsSection(isDark: isDark),
                  const SizedBox(height: 20),

                  // ── Supported diseases ───────────────────────────────────
                  _SupportedDiseasesSection(isDark: isDark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final bool isDark;
  const _HeaderSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
      final lang = context.watch<LanguageProvider>().strings;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);
    final subColor =
        isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(Icons.biotech,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.scanTitle,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    lang.scanSubtitle,
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.2), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang.scanInfo,
                  style: TextStyle(
                    color: subColor,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Empty state (no image selected) ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Animation<double> pulseAnim;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _EmptyState({
    required this.isDark,
    required this.pulseAnim,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
      final lang = context.watch<LanguageProvider>().strings;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final subColor =
        isDark ? const Color(0xFF7B9EA0) : const Color(0xFF78909C);

    return Column(
      children: [
        // Drop zone
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
              // ignore: deprecated_member_use
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing camera icon
              ScaleTransition(
                scale: pulseAnim,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.12),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: AppColors.primary, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.scanNoImage,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0B2010),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lang.scanNoImageSub,
                style: TextStyle(color: subColor, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Buttons row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt,
                label: lang.scanTakePhoto,
                subtitle: lang.scanUseCamera,
                onTap: onCamera,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library_outlined,
                label: lang.scanUploadPhoto,
                subtitle: lang.scanFromGallery,
                onTap: onGallery,
                isPrimary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppColors.primary
              : (isDark ? const Color(0xFF1A3035) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppColors.primary.withOpacity(0.4), width: 1.5),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isPrimary
                  ? const Color(0xFF0B1617)
                  : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isPrimary
                    ? const Color(0xFF0B1617)
                    : (isDark ? Colors.white : const Color(0xFF0B2010)),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: isPrimary
                    ? const Color(0xFF0B1617).withOpacity(0.7)
                    : (isDark
                        ? const Color(0xFF7B9EA0)
                        : const Color(0xFF78909C)),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Image preview (image selected) ───────────────────────────────────────────

class _ImagePreview extends StatelessWidget {
  final String imagePath;
  final Uint8List? imageBytes;
  final bool isDark;
  final bool isAnalyzing;
  final String analyzeStatus;
  final int stepIndex;
  final int totalSteps;
  final Animation<double> scanLineAnim;
  final VoidCallback onClear;
  final VoidCallback onAnalyze;

  const _ImagePreview({
    required this.imagePath,
    this.imageBytes,
    required this.isDark,
    required this.isAnalyzing,
    required this.analyzeStatus,
    required this.stepIndex,
    required this.totalSteps,
    required this.scanLineAnim,
    required this.onClear,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    return Column(
      children: [
        // Image container with scan overlay
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 280,
                width: double.infinity,
                child: _buildImage(),
              ),
            ),

            // Dark overlay during analysis
            if (isAnalyzing)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),

            // Scanning line animation
            if (isAnalyzing)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedBuilder(
                    animation: scanLineAnim,
                    builder: (_, __) => Stack(
                      children: [
                        // Scan line
                        Positioned(
                          top: scanLineAnim.value * 280 - 2,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppColors.primary.withOpacity(0.8),
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Corner markers
                        ..._buildCornerMarkers(),
                      ],
                    ),
                  ),
                ),
              ),

            // Analysis status overlay
            if (isAnalyzing)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.85),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                analyzeStatus,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (stepIndex + 1) / totalSteps,
                            minHeight: 4,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Remove image button (only when not analyzing)
            if (!isAnalyzing)
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),

            // Ready to scan badge
            if (!isAnalyzing)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Color(0xFF0B1617), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        lang.scanReadyToScan,
                        style: TextStyle(
                          color: Color(0xFF0B1617),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Analyze button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isAnalyzing ? null : onAnalyze,
            icon: isAnalyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0B1617),
                    ),
                  )
                : const Icon(Icons.biotech, size: 22),
            label: Text(
              isAnalyzing ? lang.scanAnalyzing : lang.scanAnalyze,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF0B1617),
              disabledBackgroundColor:
                  AppColors.primary.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: isAnalyzing ? 0 : 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    // In-memory bytes always win: they render even if the temp file was
    // cleaned or the path is stale — this was the black-preview bug.
    if (imageBytes != null && imageBytes!.isNotEmpty) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _fallbackWidget(),
      );
    }
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    // On web, image_picker returns a blob URL — use Image.network
    // On mobile (Android/iOS), it returns a file path — use Image.file
    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackWidget(),
      );
    }
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackWidget(),
    );
  }

  Widget _fallbackWidget() => const ColoredBox(
        color: Color(0xFF1A3035),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: AppColors.primary, size: 60),
              SizedBox(height: 8),
              Text('Plant Image',
                  style: TextStyle(color: AppColors.primary)),
            ],
          ),
        ),
      );

  List<Widget> _buildCornerMarkers() {
    const size = 20.0;
    const thick = 3.0;
    const color = AppColors.primary;
    return [
      // Top-left
      Positioned(
        top: 12,
        left: 12,
        child: _Corner(size: size, thick: thick, color: color,
            top: true, left: true),
      ),
      // Top-right
      Positioned(
        top: 12,
        right: 12,
        child: _Corner(size: size, thick: thick, color: color,
            top: true, left: false),
      ),
      // Bottom-left
      Positioned(
        bottom: 12,
        left: 12,
        child: _Corner(size: size, thick: thick, color: color,
            top: false, left: true),
      ),
      // Bottom-right
      Positioned(
        bottom: 12,
        right: 12,
        child: _Corner(size: size, thick: thick, color: color,
            top: false, left: false),
      ),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double thick;
  final Color color;
  final bool top;
  final bool left;
  const _Corner(
      {required this.size,
      required this.thick,
      required this.color,
      required this.top,
      required this.left});

  @override
  Widget build(BuildContext context) {
      final lang = context.watch<LanguageProvider>().strings;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
            color: color, thick: thick, top: top, left: left),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thick;
  final bool top;
  final bool left;
  const _CornerPainter(
      {required this.color,
      required this.thick,
      required this.top,
      required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final x = left ? 0.0 : size.width;
    final y = top ? 0.0 : size.height;
    final dx = left ? size.width : -size.width;
    final dy = top ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}

// ── Tips section ──────────────────────────────────────────────────────────────

class _TipsSection extends StatelessWidget {
  final bool isDark;
  const _TipsSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
      final lang = context.watch<LanguageProvider>().strings;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);
    final subColor =
        isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF263338) : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.scanTipsTitle,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            (lang.scanTip1Title, lang.scanTip1Desc),
            (lang.scanTip2Title, lang.scanTip2Desc),
            (lang.scanTip3Title, lang.scanTip3Desc),
            (lang.scanTip4Title, lang.scanTip4Desc),
            (lang.scanTip5Title, lang.scanTip5Desc),
          ].map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${tip.$1}: ',
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        TextSpan(
                          text: tip.$2,
                          style:
                              TextStyle(color: subColor, fontSize: 13),
                        ),
                      ],
                    ),
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

// ── Supported diseases preview ────────────────────────────────────────────────

class _SupportedDiseasesSection extends StatelessWidget {
  final bool isDark;
  const _SupportedDiseasesSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
      final lang = context.watch<LanguageProvider>().strings;
    final cardBg = isDark ? const Color(0xFF1A3035) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0B2010);
    final subColor =
        isDark ? const Color(0xFF7B9EA0) : const Color(0xFF546E7A);

    final crops = [
      ('🌽', 'Maize', '3 diseases'),
      ('🫘', 'Beans', '3 diseases'),
      ('🌿', 'Cassava', '2 diseases'),
      ('🥔', 'Potato', '2 diseases'),
      ('🍌', 'Banana', '1 disease'),
      ('🍅', 'Tomato', '2 diseases'),
      ('🌾', 'Wheat', '1 disease'),
      ('☕', 'Coffee', '1 disease'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF263338) : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                lang.scanSupportedTitle,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${DiseaseDatabase.all.length - 1} ${lang.scanDiseases}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            lang.scanDatabaseDesc,
            style: TextStyle(color: subColor, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: crops
                .map((c) => _CropChip(
                      emoji: c.$1,
                      crop: c.$2,
                      count: c.$3,
                      isDark: isDark,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CropChip extends StatelessWidget {
  final String emoji;
  final String crop;
  final String count;
  final bool isDark;

  const _CropChip({
    required this.emoji,
    required this.crop,
    required this.count,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF112225)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? const Color(0xFF263338)
              : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text(
            crop,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0B2010),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: TextStyle(
              color: isDark
                  ? const Color(0xFF7B9EA0)
                  : const Color(0xFF90A4AE),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
