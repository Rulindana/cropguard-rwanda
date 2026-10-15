import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';
import '../../services/admin_auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@cropguard.ai');
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final svc = AdminAuthService();
      final user = await svc.signIn(_emailCtrl.text.trim(), _passCtrl.text.trim());
      if (!mounted) return;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      } else {
        setState(() { _error = 'Invalid credentials'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter your email above first, then tap Forgot Password.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _error = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Password reset email sent to $email — check your inbox.'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not send reset email: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1617),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  ClipOval(child: Image.asset('assets/icon/logo.png', width: 80, height: 80, fit: BoxFit.cover)),
                  const SizedBox(height: 16),
                  const Text('CropGuard Admin',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  const Text('Manage the system securely',
                      style: TextStyle(fontSize: 13, color: Color(0xFFB0BEC5))),
                  const SizedBox(height: 32),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec('Email', Icons.email_outlined),
                    validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDec('Password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.primary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.alertRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: const TextStyle(color: AppColors.alertRed, fontSize: 13)),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: const Color(0xFF0B1617),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B1617)))
                          : const Text('Login to Admin Panel',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),

                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('← Back to App',
                        style: TextStyle(color: AppColors.primary)),
                  ),
                  // Forgot password
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetPassword,
                    child: const Text(
                      'Forgot password? Send reset email',
                      style: TextStyle(
                        color: Color(0xFF78909C),
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF78909C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFFB0BEC5)),
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true,
    fillColor: const Color(0xFF152629),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF263338))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF263338))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary)),
  );
}

// ── Simple admin dashboard ────────────────────────────────────────────────────

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112225),
        title: const Text('Admin Panel', style: TextStyle(color: AppColors.primary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await AdminAuthService().signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(20),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _AdminCard(icon: Icons.bar_chart, title: 'Risk Data', subtitle: 'Edit district risk scores',
              color: const Color(0xFF00E676),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _DistrictRiskEditor()))),
          _AdminCard(icon: Icons.warehouse, title: 'Facilities', subtitle: 'Add/edit storage sites',
              color: const Color(0xFF00B0FF),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _FacilitiesEditor()))),
          _AdminCard(icon: Icons.people, title: 'Subscribers', subtitle: 'SMS alert users',
              color: const Color(0xFFAB47BC),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _SubscribersScreen()))),
          _AdminCard(icon: Icons.notifications_active, title: 'Send Alert', subtitle: 'Broadcast to farmers',
              color: const Color(0xFFFFA726),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _SendAlertScreen()))),
          _AdminCard(icon: Icons.settings, title: 'App Settings', subtitle: 'Thresholds & config',
              color: const Color(0xFFEF5350),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _AppSettingsScreen()))),
          _AdminCard(icon: Icons.android, title: 'APK Release', subtitle: 'Upload & manage APK',
              color: const Color(0xFF66BB6A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ApkManagementScreen()))),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({required this.icon, required this.title,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF112225),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 52, height: 52,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 26)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFFB0BEC5)),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── APK Management Screen ─────────────────────────────────────────────────────

class _ApkManagementScreen extends StatefulWidget {
  _ApkManagementScreen();
  @override
  State<_ApkManagementScreen> createState() => _ApkManagementScreenState();
}

class _ApkManagementScreenState extends State<_ApkManagementScreen> {
  final _urlCtrl = TextEditingController();
  final _versionCtrl = TextEditingController(text: '1.0');
  final _notesCtrl = TextEditingController();
  bool _saving = false;
  String? _currentUrl;
  String? _currentVersion;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('apk_release')
          .get();
      if (doc.exists) {
        setState(() {
          _currentUrl = doc.data()?['download_url'] ?? '';
          _currentVersion = doc.data()?['version'] ?? '';
          _urlCtrl.text = _currentUrl ?? '';
          _versionCtrl.text = _currentVersion ?? '1.0';
          _notesCtrl.text = doc.data()?['release_notes'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    if (_urlCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection('app_config')
          .doc('apk_release')
          .set({
        'download_url': _urlCtrl.text.trim(),
        'version': _versionCtrl.text.trim(),
        'release_notes': _notesCtrl.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ APK URL saved! Users will see the new download link.'),
          backgroundColor: AppColors.primary,
        ));
        setState(() { _currentUrl = _urlCtrl.text.trim(); _currentVersion = _versionCtrl.text.trim(); });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.alertRed));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112225),
        title: const Text('APK Release Management', style: TextStyle(color: AppColors.primary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Current status
          if (_currentUrl != null && _currentUrl!.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('✅ Current Release', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Version: $_currentVersion', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(_currentUrl!, style: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(_currentUrl!);
                    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: const Text('Test download link →',
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3035),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📋 How to upload APK:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              SizedBox(height: 8),
              Text('1. Upload your APK to Google Drive, Dropbox, or GitHub Releases',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
              Text('2. Get the direct download link',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
              Text('3. Paste the link below and click Save',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
              Text('4. The floating button on the website will immediately use the new link',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 12)),
            ]),
          ),

          // Form
          const Text('APK Download URL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _urlCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('https://drive.google.com/... or github.com/.../releases/...', Icons.link),
          ),
          const SizedBox(height: 16),
          const Text('Version', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _versionCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _dec('e.g. 1.1', Icons.new_releases),
          ),
          const SizedBox(height: 16),
          const Text('Release Notes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextField(
            controller: _notesCtrl,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: _dec('What\'s new in this version...', Icons.notes),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B1617)))
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save & Publish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0B1617),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  InputDecoration _dec(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF78909C)),
    prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
    filled: true,
    fillColor: const Color(0xFF152629),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF263338))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF263338))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary)),
  );
}

// ── Admin sub-screens (stubs — expandable) ────────────────────────────────────

class _DistrictRiskEditor extends StatelessWidget {
  const _DistrictRiskEditor();
  @override
  Widget build(BuildContext context) => _AdminSubScreen(
    title: 'Risk Data Editor',
    icon: Icons.bar_chart,
    color: const Color(0xFF00E676),
    body: 'Edit district risk scores, rainfall indices and advisory messages stored in Firestore.',
  );
}

class _FacilitiesEditor extends StatelessWidget {
  const _FacilitiesEditor();
  @override
  Widget build(BuildContext context) => _AdminSubScreen(
    title: 'Facilities Manager',
    icon: Icons.warehouse,
    color: const Color(0xFF00B0FF),
    body: 'Add, edit or remove storage facilities across Rwanda\'s 30 districts.',
  );
}

class _SubscribersScreen extends StatelessWidget {
  const _SubscribersScreen();
  @override
  Widget build(BuildContext context) => _AdminSubScreen(
    title: 'SMS Subscribers',
    icon: Icons.people,
    color: const Color(0xFFAB47BC),
    body: 'View and manage farmers subscribed to SMS/USSD risk alerts.',
  );
}

class _SendAlertScreen extends StatelessWidget {
  const _SendAlertScreen();
  @override
  Widget build(BuildContext context) => _AdminSubScreen(
    title: 'Send Alert',
    icon: Icons.notifications_active,
    color: const Color(0xFFFFA726),
    body: 'Broadcast an emergency alert to all subscribers in a district or nationwide.',
  );
}

class _AppSettingsScreen extends StatelessWidget {
  const _AppSettingsScreen();
  @override
  Widget build(BuildContext context) => _AdminSubScreen(
    title: 'App Settings',
    icon: Icons.settings,
    color: const Color(0xFFEF5350),
    body: 'Configure risk thresholds, alert frequency, and system parameters.',
  );
}

class _AdminSubScreen extends StatelessWidget {
  final String title, body;
  final IconData icon;
  final Color color;
  const _AdminSubScreen({required this.title, required this.body,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1617),
      appBar: AppBar(
        backgroundColor: const Color(0xFF112225),
        title: Text(title, style: const TextStyle(color: AppColors.primary)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 72, height: 72,
              decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 36)),
            const SizedBox(height: 20),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 12),
            Text(body, style: const TextStyle(fontSize: 14, color: Color(0xFFB0BEC5), height: 1.6),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF112225), borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3))),
              child: const Text('🚧  Full editor coming soon.\nData is managed via Firebase Console for now.',
                  style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13), textAlign: TextAlign.center)),
          ]),
        ),
      ),
    );
  }
}
