import 'package:flutter/material.dart';
import '../utils/colors.dart';

enum NavItem { dashboard, map, alerts, profile }

class ResponsiveScaffold extends StatelessWidget {
  final NavItem currentNav;
  final Widget child;
  final VoidCallback? onMenuToggle;

  const ResponsiveScaffold({
    super.key,
    required this.currentNav,
    required this.child,
    this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return _DesktopLayout(currentNav: currentNav, child: child);
    } else {
      return _MobileLayout(currentNav: currentNav, child: child);
    }
  }
}

class _DesktopLayout extends StatefulWidget {
  final NavItem currentNav;
  final Widget child;
  final VoidCallback? onMenuToggle;

  const _DesktopLayout({required this.currentNav, required this.child, this.onMenuToggle});

  @override
  State<_DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<_DesktopLayout> {
  bool _sidebarExpanded = true;

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
                ],
              ),
            ),
          ),

          // Holographic background glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0x1500E676),
                    const Color(0x0000E676),
                  ],
                ),
              ),
            ),
          ),

          // Main content area
          Row(
            children: [
              // Sidebar
              _buildSidebar(context),

              // Main content
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final listWidth = _sidebarExpanded ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: listWidth,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 20 : 12,
            ),
            child: Row(
              children: [
                // Logo icon - two leaves
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppGradients.greenGlowGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [AppShadows.glowGreen],
                  ),
                  child: const Icon(
                    Icons.grass,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CropGuard AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _navItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  selectedIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isSelected: widget.currentNav == NavItem.dashboard,
                ),
                _navItem(
                  context,
                  icon: Icons.map_outlined,
                  selectedIcon: Icons.map,
                  label: 'Map & Analytics',
                  isSelected: widget.currentNav == NavItem.map,
                ),
                _navItem(
                  context,
                  icon: Icons.grass,
                  selectedIcon: Icons.grass,
                  label: 'Crop Monitoring',
                  isSelected: false,
                ),
                _navItem(
                  context,
                  icon: Icons.cloud_outlined,
                  selectedIcon: Icons.cloud,
                  label: 'Weather',
                  isSelected: false,
                ),
                _navItem(
                  context,
                  icon: Icons.notifications_outlined,
                  selectedIcon: Icons.notifications,
                  label: 'Alerts',
                  isSelected: widget.currentNav == NavItem.alerts,
                ),
                _navItem(
                  context,
                  icon: Icons.assessment_outlined,
                  selectedIcon: Icons.assessment,
                  label: 'Reports',
                  isSelected: false,
                ),
                _navItem(
                  context,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: false,
                ),
              ],
            ),
          ),

          // Profile area at bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppGradients.greenGlowGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textOnPrimary,
                    size: 18,
                  ),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rwanda Farmer',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Manager',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Collapse button
          if (_sidebarExpanded)
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: () => setState(() => _sidebarExpanded = false),
                icon: const Icon(Icons.keyboard_arrow_right, size: 20),
                label: const Text('Collapse'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: () => setState(() => _sidebarExpanded = true),
                icon: const Icon(Icons.keyboard_arrow_left, size: 20),
                label: const Text('Expand'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            // Navigation callback - implement in parent
          },
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: _sidebarExpanded ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryDark.withOpacity(0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                if (_sidebarExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu toggle
          IconButton(              onPressed: () => _sidebarExpanded = !_sidebarExpanded,
            icon: const Icon(
              Icons.menu,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),

          const Spacer(),

          // Title
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Rwanda Agricultural Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Real-time insights for healthier crops and higher yields',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Date/Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  DateTime.now().toString().substring(0, 10).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  DateTime.now().toString().substring(11, 16),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Notification bell
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Profile avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.greenGlowGradient,
              shape: BoxShape.circle,
              boxShadow: [AppShadows.glowGreen],
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.textOnPrimary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final NavItem currentNav;
  final Widget child;

  const _MobileLayout({required this.currentNav, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _MobileHeader(),

          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: child,
            ),
          ),

          // Bottom navigation
          _MobileBottomNav(currentNav: currentNav),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppGradients.cardGradient,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger menu
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.menu,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 8),

          // Logo + title
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppGradients.greenGlowGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.grass,
                  color: AppColors.textOnPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CropGuard AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  final NavItem currentNav;

  const _MobileBottomNav({required this.currentNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Home',
            isSelected: currentNav == NavItem.dashboard,
            onTap: () {},
          ),
          _bottomNavItem(
            icon: Icons.map_outlined,
            selectedIcon: Icons.map,
            label: 'Map',
            isSelected: currentNav == NavItem.map,
            onTap: () {},
          ),
          _bottomNavItem(
            icon: Icons.notifications_outlined,
            selectedIcon: Icons.notifications,
            label: 'Alerts',
            isSelected: currentNav == NavItem.alerts,
            onTap: () {},
          ),
          _bottomNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            isSelected: currentNav == NavItem.profile,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
