import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying real-time connection metrics including signal strength graph
class ConnectionMetricsWidget extends StatefulWidget {
  final bool isConnected;
  final int signalStrength;
  final double stabilityPercentage;
  final Duration connectedTime;

  const ConnectionMetricsWidget({
    super.key,
    required this.isConnected,
    required this.signalStrength,
    required this.stabilityPercentage,
    required this.connectedTime,
  });

  @override
  State<ConnectionMetricsWidget> createState() =>
      _ConnectionMetricsWidgetState();
}

class _ConnectionMetricsWidgetState extends State<ConnectionMetricsWidget> {
  List<FlSpot> signalData = [];

  @override
  void initState() {
    super.initState();
    _generateSignalData();
  }

  void _generateSignalData() {
    signalData = List.generate(20, (index) {
      final baseStrength = widget.signalStrength.toDouble();
      final variation = (index % 3 - 1) * 5;
      return FlSpot(index.toDouble(), (baseStrength + variation).clamp(0, 100));
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

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
                iconName: 'signal_cellular_alt',
                color: widget.isConnected
                    ? AppTheme.successLight
                    : AppTheme.errorLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Connection Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: widget.isConnected
                      ? AppTheme.successLight.withValues(alpha: 0.1)
                      : AppTheme.errorLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.isConnected ? 'Connected' : 'Disconnected',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: widget.isConnected
                        ? AppTheme.successLight
                        : AppTheme.errorLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Signal Strength Graph
          Container(
            height: 20.h,
            child: Semantics(
              label:
                  "Signal Strength Graph showing connection quality over time",
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}s',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: 19,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: signalData,
                      isCurved: true,
                      color: widget.isConnected
                          ? AppTheme.primaryLight
                          : AppTheme.errorLight,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: widget.isConnected
                            ? AppTheme.primaryLight.withValues(alpha: 0.1)
                            : AppTheme.errorLight.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Signal Strength',
                  '${widget.signalStrength}%',
                  CustomIconWidget(
                    iconName: 'wifi',
                    color: _getSignalColor(widget.signalStrength),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Stability',
                  '${widget.stabilityPercentage.toStringAsFixed(1)}%',
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: _getStabilityColor(widget.stabilityPercentage),
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Connected Time',
                  _formatDuration(widget.connectedTime),
                  CustomIconWidget(
                    iconName: 'access_time',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String title, String value, Widget icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int strength) {
    if (strength >= 75) return AppTheme.successLight;
    if (strength >= 50) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  Color _getStabilityColor(double stability) {
    if (stability >= 90) return AppTheme.successLight;
    if (stability >= 70) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }
}
