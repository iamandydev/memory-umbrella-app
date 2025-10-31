import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for IoT device management application
enum CustomAppBarVariant {
  /// Standard app bar with back button and title
  standard,

  /// App bar with search functionality for device discovery
  search,

  /// App bar with connection status indicator
  connectionStatus,

  /// App bar with device count and refresh action
  deviceList,
}

/// Production-ready custom app bar widget implementing Contemporary Functional Minimalism
/// Optimized for IoT device management with clear connection state communication
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The variant of the app bar to display
  final CustomAppBarVariant variant;

  /// The title text to display (required)
  final String title;

  /// Optional subtitle for additional context
  final String? subtitle;

  /// Whether to show the back button (optional, defaults to auto-detect)
  final bool? showBackButton;

  /// Custom leading widget (optional)
  final Widget? leading;

  /// List of action widgets (optional)
  final List<Widget>? actions;

  /// Connection status for connectionStatus variant (optional)
  final bool? isConnected;

  /// Device count for deviceList variant (optional)
  final int? deviceCount;

  /// Search callback for search variant (optional)
  final ValueChanged<String>? onSearchChanged;

  /// Refresh callback for deviceList variant (optional)
  final VoidCallback? onRefresh;

  /// Background color override (optional)
  final Color? backgroundColor;

  /// Elevation override (optional, defaults to 2.0)
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.variant,
    required this.title,
    this.subtitle,
    this.showBackButton,
    this.leading,
    this.actions,
    this.isConnected,
    this.deviceCount,
    this.onSearchChanged,
    this.onRefresh,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with TickerProviderStateMixin {
  late AnimationController _connectionAnimationController;
  late Animation<double> _connectionAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _connectionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _connectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _connectionAnimationController,
      curve: Curves.easeInOut,
    ));

    if (widget.variant == CustomAppBarVariant.connectionStatus &&
        widget.isConnected == true) {
      _connectionAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.variant == CustomAppBarVariant.connectionStatus) {
      if (widget.isConnected == true && oldWidget.isConnected != true) {
        _connectionAnimationController.repeat(reverse: true);
      } else if (widget.isConnected != true) {
        _connectionAnimationController.stop();
        _connectionAnimationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _connectionAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor:
          widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: widget.elevation ?? theme.appBarTheme.elevation,
      centerTitle: false,
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: _buildActions(context),
      bottom: widget.subtitle != null ? _buildSubtitleBottom(context) : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;

    final shouldShowBack =
        widget.showBackButton ?? Navigator.of(context).canPop();
    if (!shouldShowBack) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
      onPressed: () => Navigator.of(context).pop(),
      tooltip: 'Back',
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.variant) {
      case CustomAppBarVariant.search:
        return _isSearchActive
            ? _buildSearchField(context)
            : _buildStandardTitle(context);

      case CustomAppBarVariant.connectionStatus:
        return Row(
          children: [
            Expanded(child: _buildStandardTitle(context)),
            const SizedBox(width: 8),
            _buildConnectionIndicator(context),
          ],
        );

      case CustomAppBarVariant.deviceList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: theme.appBarTheme.titleTextStyle,
            ),
            if (widget.deviceCount != null)
              Text(
                '${widget.deviceCount} ${widget.deviceCount == 1 ? 'device' : 'devices'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        );

      default:
        return _buildStandardTitle(context);
    }
  }

  Widget _buildStandardTitle(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      widget.title,
      style: theme.appBarTheme.titleTextStyle,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search devices...',
        border: InputBorder.none,
        hintStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: theme.colorScheme.onSurface,
      ),
      onChanged: widget.onSearchChanged,
    );
  }

  Widget _buildConnectionIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final isConnected = widget.isConnected ?? false;

    return AnimatedBuilder(
      animation: _connectionAnimation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected
                ? Color.lerp(
                      const Color(0xFF059669), // Success green
                      const Color(0xFF059669).withValues(alpha: 0.3),
                      _connectionAnimation.value,
                    ) ??
                    const Color(0xFF059669)
                : const Color(0xFFDC2626), // Error red
          ),
        );
      },
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final actions = <Widget>[];

    switch (widget.variant) {
      case CustomAppBarVariant.search:
        actions.add(
          IconButton(
            icon: Icon(_isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchActive = !_isSearchActive;
                if (!_isSearchActive) {
                  _searchController.clear();
                  widget.onSearchChanged?.call('');
                }
              });
            },
            tooltip: _isSearchActive ? 'Close search' : 'Search devices',
          ),
        );
        break;

      case CustomAppBarVariant.deviceList:
        if (widget.onRefresh != null) {
          actions.add(
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: widget.onRefresh,
              tooltip: 'Refresh devices',
            ),
          );
        }
        break;

      case CustomAppBarVariant.connectionStatus:
        actions.add(
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                Navigator.pushNamed(context, '/connection-status-screen'),
            tooltip: 'Connection settings',
          ),
        );
        break;

      default:
        break;
    }

    // Add custom actions if provided
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions.isNotEmpty ? actions : null;
  }

  PreferredSizeWidget? _buildSubtitleBottom(BuildContext context) {
    if (widget.subtitle == null) return null;

    return PreferredSize(
      preferredSize: const Size.fromHeight(24),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        child: Text(
          widget.subtitle!,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
