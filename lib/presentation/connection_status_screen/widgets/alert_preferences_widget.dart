import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for managing alert preferences and notification settings
class AlertPreferencesWidget extends StatefulWidget {
  final Map<String, bool> preferences;
  final Function(String, bool) onPreferenceChanged;

  const AlertPreferencesWidget({
    super.key,
    required this.preferences,
    required this.onPreferenceChanged,
  });

  @override
  State<AlertPreferencesWidget> createState() => _AlertPreferencesWidgetState();
}

class _AlertPreferencesWidgetState extends State<AlertPreferencesWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'notifications',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Alert Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Audio Notifications
          _buildPreferenceItem(
            context,
            'Audio Notifications',
            'Play sound when device disconnects',
            'audio_notifications',
            CustomIconWidget(
              iconName: 'volume_up',
              color: colorScheme.primary,
              size: 20,
            ),
          ),

          // Vibration Alerts
          _buildPreferenceItem(
            context,
            'Vibration Alerts',
            'Vibrate phone on connection events',
            'vibration_alerts',
            CustomIconWidget(
              iconName: 'vibration',
              color: colorScheme.primary,
              size: 20,
            ),
          ),

          // Connection Status Notifications
          _buildPreferenceItem(
            context,
            'Connection Status',
            'Show notifications for connection changes',
            'connection_notifications',
            CustomIconWidget(
              iconName: 'notification_important',
              color: colorScheme.primary,
              size: 20,
            ),
          ),

          // Command Feedback
          _buildPreferenceItem(
            context,
            'Command Feedback',
            'Notify when commands are sent successfully',
            'command_feedback',
            CustomIconWidget(
              iconName: 'feedback',
              color: colorScheme.primary,
              size: 20,
            ),
          ),

          // Low Signal Warnings
          _buildPreferenceItem(
            context,
            'Low Signal Warnings',
            'Alert when signal strength is weak',
            'low_signal_warnings',
            CustomIconWidget(
              iconName: 'signal_wifi_bad',
              color: AppTheme.warningLight,
              size: 20,
            ),
          ),

          // Auto-Reconnect Notifications
          _buildPreferenceItem(
            context,
            'Auto-Reconnect Alerts',
            'Notify when device reconnects automatically',
            'auto_reconnect_notifications',
            CustomIconWidget(
              iconName: 'autorenew',
              color: AppTheme.successLight,
              size: 20,
            ),
          ),

          SizedBox(height: 2.h),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _enableAllPreferences(),
                  child: Text('Enable All'),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _disableAllPreferences(),
                  child: Text('Disable All'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    String title,
    String description,
    String key,
    Widget icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = widget.preferences[key] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isEnabled
            ? colorScheme.primaryContainer.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          icon,
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? colorScheme.primary : null,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              setState(() {
                widget.onPreferenceChanged(key, value);
              });
            },
          ),
        ],
      ),
    );
  }

  void _enableAllPreferences() {
    setState(() {
      final keys = [
        'audio_notifications',
        'vibration_alerts',
        'connection_notifications',
        'command_feedback',
        'low_signal_warnings',
        'auto_reconnect_notifications',
      ];

      for (final key in keys) {
        widget.onPreferenceChanged(key, true);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All alert preferences enabled'),
        backgroundColor: AppTheme.successLight,
      ),
    );
  }

  void _disableAllPreferences() {
    setState(() {
      final keys = [
        'audio_notifications',
        'vibration_alerts',
        'connection_notifications',
        'command_feedback',
        'low_signal_warnings',
        'auto_reconnect_notifications',
      ];

      for (final key in keys) {
        widget.onPreferenceChanged(key, false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All alert preferences disabled'),
        backgroundColor: AppTheme.secondaryLight,
      ),
    );
  }
}
