import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying connection history timeline with events
class ConnectionTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> timelineEvents;
  final VoidCallback? onClearHistory;

  const ConnectionTimelineWidget({
    super.key,
    required this.timelineEvents,
    this.onClearHistory,
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
                iconName: 'timeline',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Connection History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onClearHistory != null)
                TextButton(
                  onPressed: onClearHistory,
                  child: Text(
                    'Clear',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          if (timelineEvents.isEmpty)
            _buildEmptyState(context)
          else
            ..._buildTimelineItems(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'history_toggle_off',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No connection history available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Connection events will appear here once you start using the device',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineItems(BuildContext context) {
    return timelineEvents.asMap().entries.map((entry) {
      final index = entry.key;
      final event = entry.value;
      final isLast = index == timelineEvents.length - 1;

      return _buildTimelineItem(context, event, isLast);
    }).toList();
  }

  Widget _buildTimelineItem(
      BuildContext context, Map<String, dynamic> event, bool isLast) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final eventType = event['type'] as String? ?? 'unknown';
    final timestamp = event['timestamp'] as DateTime? ?? DateTime.now();
    final message = event['message'] as String? ?? 'Unknown event';
    final details = event['details'] as String?;

    return GestureDetector(
      onLongPress: () => _showEventDetails(context, event),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getEventColor(eventType),
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 6.h,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                  ),
              ],
            ),

            SizedBox(width: 3.w),

            // Event content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _getEventIcon(eventType),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _formatTimestamp(timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (details != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      details,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEventIcon(String eventType) {
    final color = _getEventColor(eventType);

    switch (eventType) {
      case 'connected':
        return CustomIconWidget(iconName: 'link', color: color, size: 16);
      case 'disconnected':
        return CustomIconWidget(iconName: 'link_off', color: color, size: 16);
      case 'command_sent':
        return CustomIconWidget(iconName: 'send', color: color, size: 16);
      case 'command_failed':
        return CustomIconWidget(iconName: 'error', color: color, size: 16);
      case 'reconnected':
        return CustomIconWidget(iconName: 'refresh', color: color, size: 16);
      default:
        return CustomIconWidget(iconName: 'info', color: color, size: 16);
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'connected':
      case 'reconnected':
        return AppTheme.successLight;
      case 'disconnected':
      case 'command_failed':
        return AppTheme.errorLight;
      case 'command_sent':
        return AppTheme.primaryLight;
      default:
        return AppTheme.secondaryLight;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _showEventDetails(BuildContext context, Map<String, dynamic> event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getEventIcon(event['type'] as String? ?? 'unknown'),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Event Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildDetailRow(
                context, 'Event Type', event['type'] as String? ?? 'Unknown'),
            _buildDetailRow(context, 'Message',
                event['message'] as String? ?? 'No message'),
            _buildDetailRow(
                context,
                'Timestamp',
                _formatFullTimestamp(
                    event['timestamp'] as DateTime? ?? DateTime.now())),
            if (event['details'] != null)
              _buildDetailRow(context, 'Details', event['details'] as String),
            if (event['duration'] != null)
              _buildDetailRow(context, 'Duration', '${event['duration']}ms'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
