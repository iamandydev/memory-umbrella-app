import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/advanced_options_widget.dart';
import './widgets/alert_preferences_widget.dart';
import './widgets/connection_metrics_widget.dart';
import './widgets/connection_timeline_widget.dart';
import './widgets/device_info_widget.dart';

/// Connection Status Screen for detailed Bluetooth connection monitoring and management
class ConnectionStatusScreen extends StatefulWidget {
  const ConnectionStatusScreen({super.key});

  @override
  State<ConnectionStatusScreen> createState() => _ConnectionStatusScreenState();
}

class _ConnectionStatusScreenState extends State<ConnectionStatusScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isConnected = true;
  int _signalStrength = 85;
  double _stabilityPercentage = 92.5;
  Duration _connectedTime = const Duration(hours: 2, minutes: 34, seconds: 12);
  DateTime _lastUpdated = DateTime.now();

  // Mock device information
  final Map<String, dynamic> _deviceInfo = {
    'name': 'Smart Umbrella ESP32',
    'id': 'AA:BB:CC:DD:EE:FF',
    'type': 'ESP32-WROOM-32',
    'firmware': 'v2.1.4',
    'services': [
      'Generic Access',
      'Generic Attribute',
      'Device Information',
      'Smart Umbrella Control Service',
      'Battery Service'
    ],
    'characteristics': [
      {
        'name': 'Umbrella Control Command',
        'uuid': '12345678-1234-1234-1234-123456789abc',
        'properties': ['Write', 'WriteWithoutResponse']
      },
      {
        'name': 'Connection Status Notification',
        'uuid': '87654321-4321-4321-4321-cba987654321',
        'properties': ['Read', 'Notify', 'Indicate']
      },
      {
        'name': 'Battery Level Indicator',
        'uuid': '00002a19-0000-1000-8000-00805f9b34fb',
        'properties': ['Read', 'Notify']
      },
      {
        'name': 'Device Information String',
        'uuid': '00002a29-0000-1000-8000-00805f9b34fb',
        'properties': ['Read']
      }
    ]
  };

  // Mock timeline events
  List<Map<String, dynamic>> _timelineEvents = [];

  // Alert preferences
  Map<String, bool> _alertPreferences = {
    'audio_notifications': true,
    'vibration_alerts': true,
    'connection_notifications': true,
    'command_feedback': false,
    'low_signal_warnings': true,
    'auto_reconnect_notifications': true,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _generateMockTimelineEvents();
    _startConnectionMonitoring();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateMockTimelineEvents() {
    final now = DateTime.now();
    _timelineEvents = [
      {
        'type': 'connected',
        'message': 'Successfully connected to Smart Umbrella ESP32',
        'timestamp': now.subtract(const Duration(hours: 2, minutes: 34)),
        'details': 'Connection established via Bluetooth Low Energy',
        'duration': 1250,
      },
      {
        'type': 'command_sent',
        'message': 'Umbrella control command sent',
        'timestamp': now.subtract(const Duration(hours: 1, minutes: 45)),
        'details': 'Command: "1" (Open umbrella)',
        'duration': 89,
      },
      {
        'type': 'command_sent',
        'message': 'Umbrella control command sent',
        'timestamp': now.subtract(const Duration(hours: 1, minutes: 12)),
        'details': 'Command: "0" (Close umbrella)',
        'duration': 76,
      },
      {
        'type': 'reconnected',
        'message': 'Device reconnected automatically',
        'timestamp': now.subtract(const Duration(minutes: 23)),
        'details': 'Brief disconnection detected, auto-reconnect successful',
        'duration': 2340,
      },
      {
        'type': 'command_sent',
        'message': 'Status check command sent',
        'timestamp': now.subtract(const Duration(minutes: 8)),
        'details': 'Battery level request completed',
        'duration': 45,
      },
    ];
  }

  void _startConnectionMonitoring() {
    // Simulate real-time connection monitoring
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _signalStrength =
              (_signalStrength + (DateTime.now().millisecond % 10 - 5))
                  .clamp(70, 95);
          _stabilityPercentage = (_stabilityPercentage +
                  (DateTime.now().millisecond % 6 - 3) * 0.1)
              .clamp(85.0, 98.0);
          _connectedTime = _connectedTime + const Duration(seconds: 5);
          _lastUpdated = DateTime.now();
        });
        _startConnectionMonitoring();
      }
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _lastUpdated = DateTime.now();
      _signalStrength = 85 + (DateTime.now().millisecond % 15);
      _stabilityPercentage = 90.0 + (DateTime.now().millisecond % 8);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection data refreshed'),
        backgroundColor: AppTheme.successLight,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onPreferenceChanged(String key, bool value) {
    setState(() {
      _alertPreferences[key] = value;
    });
  }

  void _clearConnectionHistory() {
    setState(() {
      _timelineEvents.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection history cleared'),
        backgroundColor: AppTheme.warningLight,
      ),
    );
  }

  void _resetDeviceCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device cache reset successfully'),
        backgroundColor: AppTheme.errorLight,
      ),
    );
  }

  void _exportConnectionLog() {
    // Simulate log export
    final logContent = _generateLogContent();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Connection log exported (${logContent.length} characters)'),
        backgroundColor: AppTheme.primaryLight,
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _showLogPreview(logContent);
          },
        ),
      ),
    );
  }

  String _generateLogContent() {
    final buffer = StringBuffer();
    buffer.writeln('Connection Log Export - ${DateTime.now()}');
    buffer.writeln('Device: ${_deviceInfo['name']}');
    buffer.writeln('Device ID: ${_deviceInfo['id']}');
    buffer.writeln(
        'Current Status: ${_isConnected ? 'Connected' : 'Disconnected'}');
    buffer.writeln('Signal Strength: $_signalStrength%');
    buffer.writeln('Stability: ${_stabilityPercentage.toStringAsFixed(1)}%');
    buffer.writeln('Connected Time: $_connectedTime');
    buffer.writeln('\nConnection Events:');

    for (final event in _timelineEvents) {
      buffer.writeln(
          '${event['timestamp']}: ${event['type']} - ${event['message']}');
      if (event['details'] != null) {
        buffer.writeln('  Details: ${event['details']}');
      }
    }

    return buffer.toString();
  }

  void _showLogPreview(String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connection Log Preview'),
        content: Container(
          width: double.maxFinite,
          height: 50.h,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 10.sp,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios_new',
            color: colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection Status',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Last updated: ${_formatLastUpdated()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refreshData,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Refresh data',
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, '/device-control-screen'),
            icon: CustomIconWidget(
              iconName: 'settings_remote',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Device control',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Metrics'),
            Tab(text: 'Device'),
            Tab(text: 'History'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Metrics Tab
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  ConnectionMetricsWidget(
                    isConnected: _isConnected,
                    signalStrength: _signalStrength,
                    stabilityPercentage: _stabilityPercentage,
                    connectedTime: _connectedTime,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),

            // Device Tab
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  DeviceInfoWidget(
                    deviceInfo: _deviceInfo,
                    isConnected: _isConnected,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),

            // History Tab
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  ConnectionTimelineWidget(
                    timelineEvents: _timelineEvents,
                    onClearHistory: _clearConnectionHistory,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),

            // Settings Tab
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  AlertPreferencesWidget(
                    preferences: _alertPreferences,
                    onPreferenceChanged: _onPreferenceChanged,
                  ),
                  AdvancedOptionsWidget(
                    historyCount: _timelineEvents.length,
                    cacheSize: 2.4,
                    onClearHistory: _clearConnectionHistory,
                    onResetCache: _resetDeviceCache,
                    onExportLog: _exportConnectionLog,
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isConnected
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/device-control-screen'),
              child: CustomIconWidget(
                iconName: 'settings_remote',
                color: Colors.white,
                size: 24,
              ),
              tooltip: 'Device Control',
            )
          : null,
    );
  }

  String _formatLastUpdated() {
    final now = DateTime.now();
    final difference = now.difference(_lastUpdated);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
