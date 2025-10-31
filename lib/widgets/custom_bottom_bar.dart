import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom bottom navigation bar variants for IoT device management
enum CustomBottomBarVariant {
  /// Standard bottom navigation with icons and labels
  standard,

  /// Floating action bar with primary action
  floating,

  /// Tab bar style for switching between views
  tabs,
}

/// Navigation item data structure for bottom bar
class BottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final bool isActive;

  const BottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    this.isActive = false,
  });
}

/// Production-ready custom bottom navigation bar implementing Contemporary Functional Minimalism
/// Optimized for IoT device management with clear navigation hierarchy
class CustomBottomBar extends StatefulWidget {
  /// The variant of the bottom bar to display
  final CustomBottomBarVariant variant;

  /// Current active route (required for highlighting active item)
  final String currentRoute;

  /// Callback when navigation item is tapped (optional)
  final ValueChanged<String>? onItemTapped;

  /// Background color override (optional)
  final Color? backgroundColor;

  /// Elevation override (optional, defaults to 8.0)
  final double? elevation;

  /// Whether to show labels (optional, defaults to true)
  final bool showLabels;

  /// Primary action for floating variant (optional)
  final VoidCallback? onPrimaryAction;

  /// Primary action icon for floating variant (optional)
  final IconData? primaryActionIcon;

  const CustomBottomBar({
    super.key,
    required this.variant,
    required this.currentRoute,
    this.onItemTapped,
    this.backgroundColor,
    this.elevation,
    this.showLabels = true,
    this.onPrimaryAction,
    this.primaryActionIcon,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Hardcoded navigation items for IoT device management
  static const List<BottomBarItem> _navigationItems = [
    BottomBarItem(
      icon: Icons.bluetooth_searching,
      activeIcon: Icons.bluetooth_connected,
      label: 'Discovery',
      route: '/device-discovery-screen',
    ),
    BottomBarItem(
      icon: Icons.devices_outlined,
      activeIcon: Icons.devices,
      label: 'Control',
      route: '/device-control-screen',
    ),
    BottomBarItem(
      icon: Icons.signal_wifi_statusbar_null_outlined,
      activeIcon: Icons.signal_wifi_4_bar,
      label: 'Status',
      route: '/connection-status-screen',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case CustomBottomBarVariant.tabs:
        return _buildTabBottomBar(context);
      default:
        return _buildStandardBottomBar(context);
    }
  }

  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: widget.elevation ?? 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navigationItems.map((item) {
              final isActive = widget.currentRoute == item.route;
              return _buildNavigationItem(context, item, isActive);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: widget.elevation ?? 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Navigation items
              ..._navigationItems.map((item) {
                final isActive = widget.currentRoute == item.route;
                return Expanded(
                  child: _buildCompactNavigationItem(context, item, isActive),
                );
              }),
              // Primary action button
              const SizedBox(width: 16),
              _buildPrimaryActionButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: _navigationItems.map((item) {
              final isActive = widget.currentRoute == item.route;
              return Expanded(
                child: _buildTabItem(context, item, isActive),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
      BuildContext context, BottomBarItem item, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () => _handleItemTap(item.route),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isActive ? 1.0 : _scaleAnimation.value,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Icon(
                      isActive ? (item.activeIcon ?? item.icon) : item.icon,
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                  if (widget.showLabels) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.w400,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactNavigationItem(
      BuildContext context, BottomBarItem item, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _handleItemTap(item.route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          isActive ? (item.activeIcon ?? item.icon) : item.icon,
          color: isActive
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTabItem(
      BuildContext context, BottomBarItem item, bool isActive) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _handleItemTap(item.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? colorScheme.primary : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? (item.activeIcon ?? item.icon) : item.icon,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onPrimaryAction ??
          () => _handleItemTap('/device-discovery-screen'),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Icon(
          widget.primaryActionIcon ?? Icons.add,
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  void _handleItemTap(String route) {
    if (widget.onItemTapped != null) {
      widget.onItemTapped!(route);
    } else {
      Navigator.pushNamed(context, route);
    }
  }
}
