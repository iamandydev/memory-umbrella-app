import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Large toggle switch widget for device control
class DeviceToggleSwitch extends StatefulWidget {
  final bool isOn;
  final bool isLoading;
  final ValueChanged<bool>? onToggle;

  const DeviceToggleSwitch({
    super.key,
    required this.isOn,
    this.isLoading = false,
    this.onToggle,
  });

  @override
  State<DeviceToggleSwitch> createState() => _DeviceToggleSwitchState();
}

class _DeviceToggleSwitchState extends State<DeviceToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
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
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Text(
            'Device Control',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) {
              _animationController.reverse();
              if (!widget.isLoading && widget.onToggle != null) {
                widget.onToggle!(!widget.isOn);
              }
            },
            onTapCancel: () => _animationController.reverse(),
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: _buildToggleSwitch(theme),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            widget.isOn ? 'ON' : 'OFF',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: widget.isOn
                  ? AppTheme.successLight
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          if (widget.isLoading) ...[
            SizedBox(height: 1.h),
            Text(
              'Sending command...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleSwitch(ThemeData theme) {
    return Container(
      width: 35.w,
      height: 35.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.isOn
            ? AppTheme.primaryLight
            : theme.colorScheme.outline.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isLoading)
            SizedBox(
              width: 8.w,
              height: 8.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isOn ? Colors.white : AppTheme.primaryLight,
                ),
              ),
            )
          else
            CustomIconWidget(
              iconName: widget.isOn ? 'power_settings_new' : 'power_off',
              color: widget.isOn
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 12.w,
            ),
        ],
      ),
    );
  }
}
