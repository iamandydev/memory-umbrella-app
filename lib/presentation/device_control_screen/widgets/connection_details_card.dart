import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Connection details card widget showing device information
class ConnectionDetailsCard extends StatelessWidget {
  final int signalStrength;
  final String lastCommand;
  final DateTime lastCommandTime;
  final Duration connectionDuration;

  const ConnectionDetailsCard({
    super.key,
    required this.signalStrength,
    required this.lastCommand,
    required this.lastCommandTime,
    required this.connectionDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connection Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildDetailRow(
            context,
            'Signal Strength',
            '$signalStrength%',
            CustomIconWidget(
              iconName: 'signal_cellular_alt',
              color: _getSignalColor(),
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Last Command',
            lastCommand == '1' ? 'Turn ON' : 'Turn OFF',
            CustomIconWidget(
              iconName: lastCommand == '1' ? 'toggle_on' : 'toggle_off',
              color: lastCommand == '1'
                  ? AppTheme.successLight
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Command Time',
            _formatTime(lastCommandTime),
            CustomIconWidget(
              iconName: 'access_time',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildDetailRow(
            context,
            'Connected For',
            _formatDuration(connectionDuration),
            CustomIconWidget(
              iconName: 'timer',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);

    return Row(
      children: [
        icon,
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSignalColor() {
    if (signalStrength >= 70) return AppTheme.successLight;
    if (signalStrength >= 40) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    }
  }
}
