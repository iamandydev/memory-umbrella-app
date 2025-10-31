import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying ESP32 device information and specifications
class DeviceInfoWidget extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;
  final bool isConnected;

  const DeviceInfoWidget({
    super.key,
    required this.deviceInfo,
    required this.isConnected,
  });

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
                iconName: 'memory',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Device Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isConnected ? AppTheme.successLight : AppTheme.errorLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Device Name and ID
          _buildInfoRow(
            context,
            'Device Name',
            deviceInfo['name'] as String? ?? 'Unknown Device',
            CustomIconWidget(
              iconName: 'bluetooth',
              color: colorScheme.primary,
              size: 20,
            ),
          ),

          _buildInfoRow(
            context,
            'Device ID',
            deviceInfo['id'] as String? ?? 'N/A',
            CustomIconWidget(
              iconName: 'fingerprint',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
          ),

          _buildInfoRow(
            context,
            'Device Type',
            deviceInfo['type'] as String? ?? 'ESP32',
            CustomIconWidget(
              iconName: 'developer_board',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
          ),

          _buildInfoRow(
            context,
            'Firmware Version',
            deviceInfo['firmware'] as String? ?? 'v1.2.3',
            CustomIconWidget(
              iconName: 'system_update',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 20,
            ),
          ),

          SizedBox(height: 2.h),

          // Services Section
          Text(
            'Supported Services',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          ..._buildServicesList(context),

          SizedBox(height: 2.h),

          // Characteristics Section
          Text(
            'Device Characteristics',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.h),

          ..._buildCharacteristicsList(context),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, Widget icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          icon,
          SizedBox(width: 3.w),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServicesList(BuildContext context) {
    final services = deviceInfo['services'] as List<String>? ??
        [
          'Generic Access',
          'Generic Attribute',
          'Device Information',
          'Custom Umbrella Service'
        ];

    return services
        .map((service) => _buildServiceItem(context, service))
        .toList();
  }

  Widget _buildServiceItem(BuildContext context, String service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'settings_bluetooth',
            color: colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              service,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.successLight,
            size: 16,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCharacteristicsList(BuildContext context) {
    final characteristics =
        deviceInfo['characteristics'] as List<Map<String, dynamic>>? ??
            [
              {
                'name': 'Control Command',
                'uuid': '12345678-1234-1234-1234-123456789abc',
                'properties': ['Write']
              },
              {
                'name': 'Status Notification',
                'uuid': '87654321-4321-4321-4321-cba987654321',
                'properties': ['Read', 'Notify']
              },
              {
                'name': 'Battery Level',
                'uuid': '00002a19-0000-1000-8000-00805f9b34fb',
                'properties': ['Read']
              },
            ];

    return characteristics
        .map((characteristic) =>
            _buildCharacteristicItem(context, characteristic))
        .toList();
  }

  Widget _buildCharacteristicItem(
      BuildContext context, Map<String, dynamic> characteristic) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final properties =
        (characteristic['properties'] as List<dynamic>? ?? []).cast<String>();

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'code',
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                size: 16,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  characteristic['name'] as String? ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'UUID: ${characteristic['uuid'] as String? ?? 'N/A'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontFamily: 'monospace',
            ),
          ),
          SizedBox(height: 0.5.h),
          Wrap(
            spacing: 1.w,
            children: properties
                .map((property) => Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
