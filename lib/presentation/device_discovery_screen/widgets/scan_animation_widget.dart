import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Animated scanning indicator widget for Bluetooth device discovery
class ScanAnimationWidget extends StatefulWidget {
  final bool isScanning;
  final VoidCallback? onTap;

  const ScanAnimationWidget({
    super.key,
    required this.isScanning,
    this.onTap,
  });

  @override
  State<ScanAnimationWidget> createState() => _ScanAnimationWidgetState();
}

class _ScanAnimationWidgetState extends State<ScanAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    if (widget.isScanning) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(ScanAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      if (widget.isScanning) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rotationController.stop();
    _pulseController.reset();
    _rotationController.reset();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.1),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Inner rotating circle
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: widget.isScanning
                      ? _rotationAnimation.value * 2 * 3.14159
                      : 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: widget.isScanning
                            ? 'bluetooth_searching'
                            : 'bluetooth',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ),
                );
              },
            ),

            // Scanning waves
            if (widget.isScanning) ...[
              _buildScanWave(0.0, 0.8),
              _buildScanWave(0.3, 0.6),
              _buildScanWave(0.6, 0.4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScanWave(double delay, double opacity) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final animationValue = (_pulseController.value + delay) % 1.0;
        final scale = 1.0 + (animationValue * 1.5);
        final waveOpacity = opacity * (1.0 - animationValue);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: waveOpacity),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
