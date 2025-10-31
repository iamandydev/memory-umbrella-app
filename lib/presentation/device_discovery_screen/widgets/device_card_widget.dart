import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Device card widget for displaying discovered Bluetooth devices
class DeviceCardWidget extends StatefulWidget {
  final Map<String, dynamic> device;
  final VoidCallback onConnect;
  final VoidCallback? onDeviceInfo;
  final VoidCallback? onForgetDevice;
  final bool isConnecting;

  const DeviceCardWidget({
    super.key,
    required this.device,
    required this.onConnect,
    this.onDeviceInfo,
    this.onForgetDevice,
    this.isConnecting = false,
  });

  @override
  State<DeviceCardWidget> createState() => _DeviceCardWidgetState();
}

class _DeviceCardWidgetState extends State<DeviceCardWidget>
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
      end: 0.98,
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
    final colorScheme = theme.colorScheme;

    final deviceName = (widget.device['name'] as String?) ?? 'Unknown Device';
    final deviceId = widget.device['id'] as String? ?? '';
    final signalStrength = widget.device['signalStrength'] as int? ?? -60;
    final isConnected = widget.device['isConnected'] as bool? ?? false;
    final isPaired = widget.device['isPaired'] as bool? ?? false;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onLongPress: isPaired ? _showContextMenu : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: isConnected
                    ? Border.all(
                        color: AppTheme.successLight,
                        width: 2,
                      )
                    : null,
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    // Device icon and signal strength
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'bluetooth',
                            color: colorScheme.primary,
                            size: 6.w,
                          ),
                          Positioned(
                            top: 1,
                            right: 1,
                            child: _buildSignalStrengthIcon(signalStrength),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),

                    // Device information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  deviceName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: deviceName == 'Unknown Device'
                                        ? colorScheme.onSurface
                                            .withValues(alpha: 0.6)
                                        : colorScheme.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildConnectionStatusBadge(
                                  isConnected, isPaired),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            deviceId.isNotEmpty ? deviceId : 'No ID available',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // Connect button
                    _buildConnectButton(isConnected),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignalStrengthIcon(int signalStrength) {
    IconData iconData;
    Color iconColor;

    if (signalStrength >= -50) {
      iconData = Icons.signal_wifi_4_bar;
      iconColor = AppTheme.successLight;
    } else if (signalStrength >= -70) {
      iconData = Icons.help_outline;
      iconColor = AppTheme.warningLight;
    } else if (signalStrength >= -80) {
      iconData = Icons.help_outline;
      iconColor = AppTheme.warningLight;
    } else {
      iconData = Icons.help_outline;
      iconColor = AppTheme.errorLight;
    }

    return Container(
      width: 3.w,
      height: 3.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: iconData.codePoint.toString(),
        color: iconColor,
        size: 2.w,
      ),
    );
  }

  Widget _buildConnectionStatusBadge(bool isConnected, bool isPaired) {
    if (isConnected) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: AppTheme.successLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successLight,
              size: 3.w,
            ),
            SizedBox(width: 1.w),
            Text(
              'Connected',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.successLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      );
    } else if (isPaired) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Paired',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildConnectButton(bool isConnected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.isConnecting) {
      return Container(
        width: 20.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: SizedBox(
            width: 4.w,
            height: 4.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: 20.w,
      height: 5.h,
      child: ElevatedButton(
        onPressed: isConnected ? null : widget.onConnect,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isConnected ? AppTheme.successLight : colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        child: isConnected
            ? CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 4.w,
              )
            : Text(
                'Connect',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                margin: EdgeInsets.only(top: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'info_outline',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                title: Text(
                  'Device Info',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDeviceInfo?.call();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete_outline',
                  color: AppTheme.errorLight,
                  size: 6.w,
                ),
                title: Text(
                  'Forget Device',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.errorLight,
                      ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onForgetDevice?.call();
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
