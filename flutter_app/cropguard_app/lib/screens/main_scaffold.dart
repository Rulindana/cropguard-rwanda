import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/district_model.dart';
import '../models/facility_model.dart';
import '../services/firebase_service.dart';
import '../utils/colors.dart';
import '../utils/language_provider.dart';
import '../utils/theme_provider.dart';
import '../utils/translations.dart';
import '../utils/year_provider.dart';
import '../widgets/chatbot.dart';
import 'dashboard_screen.dart';
import 'district_detail_screen.dart';
import 'feedback_screen.dart';
import 'home_screen.dart';
import 'summary_screen.dart';
import 'facilities_list_screen.dart';

export '../utils/translations.dart';

enum NavItem { dashboard, map, alerts, summary, facilities, feedback }

// ── Top-level shell ───────────────────────────────────────────────────────────

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});
  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  NavItem _currentNav = NavItem.dashboard;
  bool _sidebarExpanded = true;
  List<District> _districts = [];
  List<Facility> _facilities = [];
  bool _dataLoaded = false;
  bool _isOffline = false;
  String? _dataChangeMessage;
  Timer? _notifTimer;
  late StreamSubscription<List<District>> _districtSub;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _subscribeToLiveUpdates();
  }

  Future<void> _loadInitialData() async {
    // ✅ Phase 1: Load local JSON immediately (< 100ms) so UI shows data at once
    try {
      final localDistricts = await DistrictService().getDistrictsLocal();
      final localFacilities = await FacilityService().getFacilitiesLocal();
      if (mounted && localDistricts.isNotEmpty) {
        setState(() {
          _districts = localDistricts;
          _facilities = localFacilities;
          _dataLoaded = true;
          _isOffline = true; // showing local data — offline mode
        });
      }
    } catch (_) {}

    // ✅ Phase 2: Update from Firestore in background (doesn't block UI)
    try {
      final liveDistricts = await DistrictService().getDistrictsOnce();
      final liveFacilities = await FacilityService().getFacilitiesOnce();
      if (mounted && liveDistricts.isNotEmpty) {
        setState(() {
          _districts = liveDistricts;
          _facilities = liveFacilities;
          _dataLoaded = true;
          _isOffline = false; // live Firestore data loaded
        });
      } else if (mounted) {
        setState(() { _dataLoaded = true; _isOffline = false; });
      }
    } catch (_) {
      if (mounted) setState(() { _dataLoaded = true; });
    }
  }

  void _subscribeToLiveUpdates() {
    _districtSub = DistrictService().getDistrictsStream().listen((districts) {
      if (!mounted || districts.isEmpty) return;
      bool changed = false;
      if (_districts.isNotEmpty) {
        for (final u in districts) {
          final old = _districts.where((d) => d.id == u.id).firstOrNull;
          if (old != null && (old.riskScore - u.riskScore).abs() > 0.5) { changed = true; break; }
        }
      }
      setState(() {
        _districts = districts;
        _dataLoaded = true;
        if (changed) {
          final lang = Provider.of<LanguageProvider>(context, listen: false).strings;
          _dataChangeMessage = _updateMsg(lang.languageCode);
          _notifTimer?.cancel();
          _notifTimer = Timer(const Duration(seconds: 6),
              () { if (mounted) setState(() => _dataChangeMessage = null); });
        }
      });
    });
  }

  String _updateMsg(String code) {
    switch (code) {
      case 'rw': return '🔄 NISR yashyize amakuru mashya — Amakuru yo kuri igihe yavuguruwe';
      case 'fr': return '🔄 NISR a mis à jour les données — Tableau de bord actualisé';
      default:   return '🔄 NISR data updated — Dashboard refreshed with latest figures';
    }
  }

  void _navigate(NavItem item) => setState(() => _currentNav = item);

  Widget _buildPage(AppStrings lang, bool isDark) {
    if (!_dataLoaded) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text(lang.languageCode == 'rw' ? 'Gutegereza amakuru...'
            : lang.languageCode == 'fr' ? 'Chargement...' : 'Loading district data…',
            style: TextStyle(color: isDark ? AppColors.textSecondary : const Color(0xFF37474F))),
      ]));
    }
    switch (_currentNav) {
      case NavItem.dashboard:
        return DashboardScreen(districts: _districts, facilities: _facilities, onNavigate: _navigate);
      case NavItem.map:
        return const HomeScreen();
      case NavItem.alerts:
        // ✅ Alerts shows high/moderate risk districts list — NOT national summary
        return _AlertsPage(districts: _districts, onNavigate: _navigate);
      case NavItem.summary:
        return const SummaryScreen();
      case NavItem.facilities:
        return _districts.isNotEmpty
            ? FacilitiesListScreen(district: _districts.first, facilities: _facilities)
            : const Center(child: Text('No data'));
      case NavItem.feedback:
        return const FeedbackScreen();
    }
  }

  @override
  void dispose() { _districtSub.cancel(); _notifTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().strings;
    final isDark = context.watch<ThemeProvider>().isDark;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final page = _buildPage(lang, isDark);

    return Stack(children: [
      isDesktop
          ? _DesktopShell(currentNav: _currentNav, sidebarExpanded: _sidebarExpanded,
              lang: lang, isDark: isDark, onNavigate: _navigate,
              onToggleSidebar: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
              child: page)
          : _MobileShell(currentNav: _currentNav, lang: lang, isDark: isDark,
              onNavigate: _navigate, child: page),

      // Data-change notification banner
      if (_dataChangeMessage != null)
        Positioned(top: 0, left: 0, right: 0,
            child: _DataBanner(message: _dataChangeMessage!,
                onDismiss: () => setState(() => _dataChangeMessage = null))),

      // ✅ Innovation 6: Offline mode indicator
      if (_isOffline && _dataLoaded)
        Positioned(
          top: isDesktop ? 64 : 56,
          left: 0, right: 0,
          child: const _OfflineBanner(),
        ),

      // Floating chatbot — on mobile sits above the bottom nav (80px), on desktop normal
      Positioned(
        bottom: isDesktop ? 24 : 88,
        right: 16,
        child: const CropGuardChatbot(),
      ),
    ]);
  }
}

// ── Data change banner ────────────────────────────────────────────────────────

class _DataBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _DataBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: AppColors.primary,
        child: Row(children: [
          const Icon(Icons.sync, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
          IconButton(onPressed: onDismiss,
              icon: const Icon(Icons.close, color: Colors.white, size: 18),
              padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
      ),
    );
  }
}

// ── Desktop shell ─────────────────────────────────────────────────────────────

class _DesktopShell extends StatelessWidget {
  final NavItem currentNav;
  final bool sidebarExpanded;
  final AppStrings lang;
  final bool isDark;
  final ValueChanged<NavItem> onNavigate;
  final VoidCallback onToggleSidebar;
  final Widget child;

  const _DesktopShell({required this.currentNav, required this.sidebarExpanded,
      required this.lang, required this.isDark, required this.onNavigate,
      required this.onToggleSidebar, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4),
      body: Row(children: [
        _Sidebar(currentNav: currentNav, expanded: sidebarExpanded, lang: lang,
            isDark: isDark, onNavigate: onNavigate, onToggle: onToggleSidebar),
        Expanded(child: Column(children: [
          _DesktopHeader(lang: lang, isDark: isDark,
              onMenuToggle: onToggleSidebar, onNavigate: onNavigate),
          Expanded(child: Container(margin: const EdgeInsets.all(24), child: child)),
        ])),
      ]),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final NavItem currentNav;
  final bool expanded;
  final AppStrings lang;
  final bool isDark;
  final ValueChanged<NavItem> onNavigate;
  final VoidCallback onToggle;

  const _Sidebar({required this.currentNav, required this.expanded,
      required this.lang, required this.isDark, required this.onNavigate,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF152629) : Colors.white;
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFE0E0E0);
    final txtPri = isDark ? Colors.white           : const Color(0xFF0B2010);
    final txtSub = isDark ? const Color(0xFFB0BEC5): const Color(0xFF37474F);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: expanded ? 240.0 : 72.0,
      decoration: BoxDecoration(color: bg,
          border: Border(right: BorderSide(color: border, width: 1))),
      child: Column(children: [
        // Logo
        Container(height: 80,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 12),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
              child: ClipRRect(borderRadius: BorderRadius.circular(18),
                  child: Image.asset('assets/icon/logo.png', fit: BoxFit.cover))),
            if (expanded) ...[
              const SizedBox(width: 12),
              Expanded(child: Text('CropGuard AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: txtPri),
                  overflow: TextOverflow.ellipsis)),
            ],
          ]),
        ),

        const SizedBox(height: 8),

        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 8), children: [
          _NavTile(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard,
              label: lang.navDashboard, item: NavItem.dashboard, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.dashboard)),
          _NavTile(icon: Icons.map_outlined, selectedIcon: Icons.map,
              label: lang.navMap, item: NavItem.map, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.map)),
          _NavTile(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications,
              label: lang.navAlerts, item: NavItem.alerts, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.alerts)),
          _NavTile(icon: Icons.assessment_outlined, selectedIcon: Icons.assessment,
              label: lang.navSummary, item: NavItem.summary, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.summary)),
          _NavTile(icon: Icons.storage_outlined, selectedIcon: Icons.storage,
              label: lang.navFacilities, item: NavItem.facilities, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.facilities)),
          _NavTile(icon: Icons.feedback_outlined, selectedIcon: Icons.feedback,
              label: lang.navFeedback, item: NavItem.feedback, currentNav: currentNav,
              expanded: expanded, isDark: isDark, onTap: () => onNavigate(NavItem.feedback)),
        ])),

        // Profile
        Container(padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: border, width: 1))),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppGradients.greenGlowGradient, shape: BoxShape.circle),
              child: const Icon(Icons.person, color: Color(0xFF0B1617), size: 18)),
            if (expanded) ...[
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lang.profileName, style: TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w700, color: txtPri), overflow: TextOverflow.ellipsis),
                Text(lang.profileRole, style: TextStyle(fontSize: 11, color: txtSub)),
              ])),
            ],
          ]),
        ),

        // Collapse
        Padding(padding: const EdgeInsets.all(8),
          child: TextButton.icon(onPressed: onToggle,
            icon: Icon(expanded ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right, size: 20),
            label: expanded ? Text(lang.collapse) : const SizedBox.shrink(),
            style: TextButton.styleFrom(foregroundColor: txtSub,
                padding: EdgeInsets.zero, minimumSize: Size.zero))),
      ]),
    );
  }
}

// ── Nav tile ──────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final NavItem item, currentNav;
  final bool expanded, isDark;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.selectedIcon,
      required this.label, required this.item, required this.currentNav,
      required this.expanded, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = item == currentNav;
    final txtColor = isSelected ? AppColors.primary
        : (isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F));

    return Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(8),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5) : null,
            ),
            child: Row(children: [
              Container(width: 32, height: 32,
                decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6)),
                child: Icon(isSelected ? selectedIcon : icon, color: txtColor, size: 20)),
              if (expanded) ...[
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: TextStyle(fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: txtColor), overflow: TextOverflow.ellipsis)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Desktop header ────────────────────────────────────────────────────────────

class _DesktopHeader extends StatelessWidget {
  final AppStrings lang;
  final bool isDark;
  final VoidCallback onMenuToggle;
  final ValueChanged<NavItem> onNavigate;

  const _DesktopHeader({required this.lang, required this.isDark,
      required this.onMenuToggle, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF112225) : Colors.white;
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFE0E0E0);
    final txtPri = isDark ? Colors.white            : const Color(0xFF0B2010);
    final txtSub = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: bg,
          border: Border(bottom: BorderSide(color: border, width: 1))),
      child: Row(children: [
        IconButton(onPressed: onMenuToggle,
            icon: Icon(Icons.menu, color: txtSub, size: 24)),
        const SizedBox(width: 8),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(lang.dashboardTitle, style: TextStyle(fontSize: 16,
              fontWeight: FontWeight.w800, color: txtPri)),
          Text(lang.dashboardSubtitle, style: TextStyle(fontSize: 11, color: txtSub)),
        ])),
        const SizedBox(width: 16),
        // ✅ Year selector
        _YearSelector(isDark: isDark),
        const SizedBox(width: 8),
        _LanguageSwitcher(isDark: isDark),
        const SizedBox(width: 8),
        _ThemeToggle(),
        const SizedBox(width: 12),
        IconButton(onPressed: () => onNavigate(NavItem.alerts),
          icon: Stack(children: [
            Icon(Icons.notifications_outlined, color: txtSub, size: 24),
            Positioned(right: 4, top: 4,
              child: Container(width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.alertRed, shape: BoxShape.circle))),
          ])),
        const SizedBox(width: 8),
        Container(width: 36, height: 36,
          decoration: BoxDecoration(gradient: AppGradients.greenGlowGradient, shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Color(0xFF0B1617), size: 18)),
      ]),
    );
  }
}

// ── Language switcher ─────────────────────────────────────────────────────────

class _LanguageSwitcher extends StatelessWidget {
  final bool isDark;
  const _LanguageSwitcher({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();
    final current = provider.code;
    final bg = isDark ? const Color(0xFF152629) : const Color(0xFFF0F7F4);
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFE0E0E0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _LangBtn(code: 'en', label: 'EN', current: current, isDark: isDark,
            onTap: () => provider.setLanguage('en')),
        _LangBtn(code: 'rw', label: 'RW', current: current, isDark: isDark,
            onTap: () => provider.setLanguage('rw')),
        _LangBtn(code: 'fr', label: 'FR', current: current, isDark: isDark,
            onTap: () => provider.setLanguage('fr')),
      ]),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String code, label, current;
  final bool isDark;
  final VoidCallback onTap;
  const _LangBtn({required this.code, required this.label,
      required this.current, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = code == current;
    final inactiveColor = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);
    return GestureDetector(onTap: onTap,
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16)),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
            color: isActive ? const Color(0xFF0B1617) : inactiveColor))));
  }
}

// ── Theme toggle ──────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();
    return GestureDetector(
      onTap: () => provider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48, height: 26,
        decoration: BoxDecoration(
          color: provider.isDark ? const Color(0xFF263338) : const Color(0xFFE0F2E9),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
        ),
        child: Stack(children: [
          AnimatedPositioned(duration: const Duration(milliseconds: 200),
            left: provider.isDark ? 2 : 22, top: 2,
            child: Container(width: 20, height: 20,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 6)]),
              child: Icon(provider.isDark ? Icons.dark_mode : Icons.light_mode,
                  size: 12, color: const Color(0xFF0B1617)))),
        ]),
      ),
    );
  }
}

// ── Mobile shell ──────────────────────────────────────────────────────────────

class _MobileShell extends StatelessWidget {
  final NavItem currentNav;
  final AppStrings lang;
  final bool isDark;
  final ValueChanged<NavItem> onNavigate;
  final Widget child;

  const _MobileShell({required this.currentNav, required this.lang,
      required this.isDark, required this.onNavigate, required this.child});

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          _MobileHeader(lang: lang, isDark: isDark, onNavigate: onNavigate),
          Expanded(
            child: Container(
              // Smaller horizontal margin on mobile so content has room to breathe
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: child,
            ),
          ),
          _MobileBottomNav(currentNav: currentNav, lang: lang, isDark: isDark, onNavigate: onNavigate),
        ]),
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final AppStrings lang;
  final bool isDark;
  final ValueChanged<NavItem> onNavigate;
  const _MobileHeader({required this.lang, required this.isDark, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF152629) : Colors.white;
    final border = isDark ? const Color(0xFF263338)  : const Color(0xFFE0E0E0);
    final txtPri = isDark ? Colors.white             : const Color(0xFF0B2010);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: bg,
          border: Border(bottom: BorderSide(color: border, width: 1))),
      child: Row(children: [
        Container(width: 28, height: 28,
            child: ClipRRect(borderRadius: BorderRadius.circular(14),
                child: Image.asset('assets/icon/logo.png', fit: BoxFit.cover))),
        const SizedBox(width: 8),
        Expanded(
          child: Text('CropGuard AI', style: TextStyle(fontSize: 15,
              fontWeight: FontWeight.w800, color: txtPri),
              overflow: TextOverflow.ellipsis),
        ),
        _LanguageSwitcher(isDark: isDark),
        const SizedBox(width: 6),
        _ThemeToggle(),
      ]),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final NavItem currentNav;
  final AppStrings lang;
  final bool isDark;
  final ValueChanged<NavItem> onNavigate;

  const _MobileBottomNav({required this.currentNav, required this.lang,
      required this.isDark, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? const Color(0xFF152629) : Colors.white;
    final border = isDark ? const Color(0xFF263338)  : const Color(0xFFE0E0E0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: bg,
          border: Border(top: BorderSide(color: border, width: 1))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _BotNavItem(icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard,
            label: lang.navDashboard, item: NavItem.dashboard, currentNav: currentNav,
            isDark: isDark, onTap: () => onNavigate(NavItem.dashboard)),
        _BotNavItem(icon: Icons.map_outlined, selectedIcon: Icons.map,
            label: lang.navMap, item: NavItem.map, currentNav: currentNav,
            isDark: isDark, onTap: () => onNavigate(NavItem.map)),
        _BotNavItem(icon: Icons.notifications_outlined, selectedIcon: Icons.notifications,
            label: lang.navAlerts, item: NavItem.alerts, currentNav: currentNav,
            isDark: isDark, onTap: () => onNavigate(NavItem.alerts)),
        _BotNavItem(icon: Icons.storage_outlined, selectedIcon: Icons.storage,
            label: lang.navFacilities, item: NavItem.facilities, currentNav: currentNav,
            isDark: isDark, onTap: () => onNavigate(NavItem.facilities)),
        _BotNavItem(icon: Icons.feedback_outlined, selectedIcon: Icons.feedback,
            label: lang.navFeedback, item: NavItem.feedback, currentNav: currentNav,
            isDark: isDark, onTap: () => onNavigate(NavItem.feedback)),
      ]),
    );
  }
}

class _BotNavItem extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final NavItem item, currentNav;
  final bool isDark;
  final VoidCallback onTap;

  const _BotNavItem({required this.icon, required this.selectedIcon,
      required this.label, required this.item, required this.currentNav,
      required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = item == currentNav;
    final txtColor = isSelected ? AppColors.primary
        : (isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F));
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(isSelected ? selectedIcon : icon, color: txtColor, size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: txtColor)),
        ]),
      ),
    );
  }
}

// ── Offline Banner ────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        color: const Color(0xFFB45309),
        child: const Row(children: [
          Icon(Icons.wifi_off, color: Colors.white, size: 13),
          SizedBox(width: 8),
          Expanded(child: Text(
            'Showing local data — syncing with live server…',
            style: TextStyle(color: Colors.white, fontSize: 11,
                fontWeight: FontWeight.w600),
          )),
        ]),
      ),
    );
  }
}

// ── Year Selector ─────────────────────────────────────────────────────────────

class _YearSelector extends StatelessWidget {
  final bool isDark;
  const _YearSelector({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final yearProvider = context.watch<YearProvider>();
    final bg = isDark ? const Color(0xFF152629) : const Color(0xFFF0F7F4);
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFCCE8D8);
    final txtColor = isDark ? Colors.white : const Color(0xFF0B2010);

    return PopupMenuButton<int>(
      tooltip: 'Select data year',
      offset: const Offset(0, 40),
      color: isDark ? const Color(0xFF152629) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border),
      ),
      onSelected: yearProvider.setYear,
      itemBuilder: (_) => YearProvider.availableYears.map((yr) {
        final isSelected = yr == yearProvider.selectedYear;
        return PopupMenuItem<int>(
          value: yr,
          child: Row(children: [
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 16)
            else
              const SizedBox(width: 16),
            const SizedBox(width: 8),
            Text(
              yr == YearProvider.maxYear ? '$yr (Live)' : '$yr',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : txtColor,
              ),
            ),
          ]),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: yearProvider.isHistorical
                ? AppColors.alertYellow.withOpacity(0.7)
                : border,
            width: yearProvider.isHistorical ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            yearProvider.isHistorical ? Icons.history : Icons.calendar_today,
            size: 14,
            color: yearProvider.isHistorical ? AppColors.alertYellow : AppColors.primary,
          ),
          const SizedBox(width: 5),
          Text(
            '${yearProvider.selectedYear}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: yearProvider.isHistorical ? AppColors.alertYellow : AppColors.primary,
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.arrow_drop_down,
              size: 16,
              color: yearProvider.isHistorical ? AppColors.alertYellow : AppColors.primary),
        ]),
      ),
    );
  }
}

// ── Alerts Page — shows high/moderate risk districts ──────────────────────────

class _AlertsPage extends StatelessWidget {
  final List<District> districts;
  final ValueChanged<NavItem> onNavigate;

  const _AlertsPage({required this.districts, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final lang = context.watch<LanguageProvider>().strings;
    final bg = isDark ? const Color(0xFF0B1617) : const Color(0xFFF0F7F4);
    final txtPri = isDark ? Colors.white : const Color(0xFF0B2010);
    final txtSub = isDark ? const Color(0xFFB0BEC5) : const Color(0xFF37474F);

    final highRisk = districts.where((d) => d.riskLevel == 'red').toList()
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    final modRisk = districts.where((d) => d.riskLevel == 'yellow').toList()
      ..sort((a, b) => b.riskScore.compareTo(a.riskScore));
    final allAlerts = [...highRisk, ...modRisk];

    return Container(
      color: bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.alertRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.notifications_active,
                    color: AppColors.alertRed, size: 22),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(lang.recentAlerts,
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w800, color: txtPri)),
                Text('${allAlerts.length} districts require attention',
                    style: TextStyle(fontSize: 12, color: txtSub)),
              ]),
            ]),

            const SizedBox(height: 20),

            if (allAlerts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 48),
                    const SizedBox(height: 16),
                    Text('All districts are safe',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w700, color: txtPri)),
                    Text('No active risk alerts at this time',
                        style: TextStyle(fontSize: 13, color: txtSub)),
                  ]),
                ),
              )
            else
              ...allAlerts.map((d) => _AlertCard(
                    district: d,
                    isDark: isDark,
                    txtPri: txtPri,
                    txtSub: txtSub,
                    onNavigate: onNavigate,
                  )),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final District district;
  final bool isDark;
  final Color txtPri, txtSub;
  final ValueChanged<NavItem> onNavigate;

  const _AlertCard({
    required this.district,
    required this.isDark,
    required this.txtPri,
    required this.txtSub,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = district.riskColor;
    final cardBg = isDark ? const Color(0xFF112225) : Colors.white;
    final border = isDark ? const Color(0xFF263338) : const Color(0xFFE0E0E0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: riskColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: riskColor.withOpacity(0.1),
            blurRadius: 8, offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        // Risk icon
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(district.riskIcon, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(district.name,
                style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w800, color: txtPri)),
            const SizedBox(height: 3),
            Text(district.province,
                style: TextStyle(fontSize: 11, color: txtSub)),
            const SizedBox(height: 6),
            Text(district.advisory,
                style: TextStyle(fontSize: 12, color: txtSub, height: 1.4),
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        )),
        const SizedBox(width: 12),
        // Risk score + action
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: riskColor.withOpacity(0.5)),
            ),
            child: Text(
              '${district.riskScore.toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w800, color: riskColor),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DistrictDetailScreen(district: district),
            )),
            child: Text('View →',
                style: TextStyle(fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
        ]),
      ]),
    );
  }
}
