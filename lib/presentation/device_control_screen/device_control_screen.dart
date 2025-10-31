import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/connection_details_card.dart';
import './widgets/connection_status_header.dart';
import './widgets/device_toggle_switch.dart';
import './widgets/disconnect_button.dart';

/// Device Control Screen for managing connected ESP32 umbrella device
class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen>
    with TickerProviderStateMixin {
  // Mock device data
  final Map<String, dynamic> _deviceData = {
    "deviceName": "Smart Umbrella Pro",
    "bluetoothId": "ESP32-UM-A1B2C3",
    "isConnected": true,
    "signalStrength": 85,
    "deviceState": true,
    "lastCommand": "1",
    "lastCommandTime": DateTime.now().subtract(const Duration(minutes: 5)),
    "connectionStartTime":
        DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
  };

  bool _isCommandLoading = false;
  bool _isDisconnectLoading = false;
  late AnimationController _connectionAnimationController;
  late Animation<Color?> _connectionColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startConnectionMonitoring();
  }

  void _initializeAnimations() {
    _connectionAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _connectionColorAnimation = ColorTween(
      begin: AppTheme.successLight,
      end: AppTheme.successLight.withValues(alpha: 0.3),
    ).animate(CurvedAnimation(
      parent: _connectionAnimationController,
      curve: Curves.easeInOut,
    ));

    if (_deviceData["isConnected"] as bool) {
      _connectionAnimationController.repeat(reverse: true);
    }
  }

  void _startConnectionMonitoring() {
    // Simulate continuous background monitoring
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        // Simulate random disconnection for demo
        if (DateTime.now().millisecond % 3 == 0) {
          _handleDeviceDisconnection();
        } else {
          _startConnectionMonitoring();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectionAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: theme.colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pushReplacementNamed(
              context, '/device-discovery-screen'),
        ),
        title: Text(
          'Device Control',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/connection-status-screen'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Connection Status Header
              ConnectionStatusHeader(
                deviceName: _deviceData["deviceName"] as String,
                bluetoothId: _deviceData["bluetoothId"] as String,
                isConnected: _deviceData["isConnected"] as bool,
                signalStrength: _deviceData["signalStrength"] as int,
              ),

              SizedBox(height: 4.h),

              // Device Toggle Switch
              DeviceToggleSwitch(
                isOn: _deviceData["deviceState"] as bool,
                isLoading: _isCommandLoading,
                onToggle: _handleDeviceToggle,
              ),

              SizedBox(height: 4.h),

              // Connection Details Card
              ConnectionDetailsCard(
                signalStrength: _deviceData["signalStrength"] as int,
                lastCommand: _deviceData["lastCommand"] as String,
                lastCommandTime: _deviceData["lastCommandTime"] as DateTime,
                connectionDuration: DateTime.now()
                    .difference(_deviceData["connectionStartTime"] as DateTime),
              ),

              SizedBox(height: 4.h),

              // Disconnect Button
              DisconnectButton(
                isLoading: _isDisconnectLoading,
                onDisconnect: _handleManualDisconnect,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDeviceToggle(bool newState) async {
    if (!(_deviceData["isConnected"] as bool)) {
      _showConnectionLostDialog();
      return;
    }

    setState(() {
      _isCommandLoading = true;
    });

    // Simulate command transmission
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      // Simulate command success/failure
      final success = DateTime.now().millisecond % 4 != 0; // 75% success rate

      if (success) {
        setState(() {
          _deviceData["deviceState"] = newState;
          _deviceData["lastCommand"] = newState ? "1" : "0";
          _deviceData["lastCommandTime"] = DateTime.now();
          _isCommandLoading = false;
        });

        _showSuccessSnackbar(
            newState ? 'Device turned ON' : 'Device turned OFF');
        _triggerHapticFeedback();
      } else {
        setState(() {
          _isCommandLoading = false;
        });
        _showErrorSnackbar('Command failed. Please try again.');
      }
    }
  }

  void _handleManualDisconnect() async {
    setState(() {
      _isDisconnectLoading = true;
    });

    // Simulate disconnection process
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _deviceData["isConnected"] = false;
        _isDisconnectLoading = false;
      });

      _connectionAnimationController.stop();
      _showSuccessSnackbar('Device disconnected successfully');

      // Navigate back to discovery screen after disconnect
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/device-discovery-screen');
        }
      });
    }
  }

  void _handleDeviceDisconnection() {
    if (!mounted || !(_deviceData["isConnected"] as bool)) return;

    setState(() {
      _deviceData["isConnected"] = false;
    });

    _connectionAnimationController.stop();
    _triggerDisconnectionAlert();
    _showConnectionLostDialog();
  }

  void _triggerDisconnectionAlert() {
    // Trigger device vibration
    HapticFeedback.heavyImpact();

    // Show audio notification (simulated)
    _showErrorSnackbar('⚠️ Device disconnected! Audio alert triggered.');
  }

  void _showConnectionLostDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'bluetooth_disabled',
                color: AppTheme.errorLight,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Connection Lost',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'The device connection has been lost. Would you like to attempt reconnection or return to device discovery?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(
                    context, '/device-discovery-screen');
              },
              child: Text(
                'Discovery',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _attemptReconnection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reconnect',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _attemptReconnection() async {
    _showInfoSnackbar('Attempting to reconnect...');

    // Simulate reconnection attempt
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // Simulate reconnection success/failure
      final success = DateTime.now().millisecond % 2 == 0; // 50% success rate

      if (success) {
        setState(() {
          _deviceData["isConnected"] = true;
          _deviceData["connectionStartTime"] = DateTime.now();
        });
        _connectionAnimationController.repeat(reverse: true);
        _showSuccessSnackbar('Reconnection successful!');
        _startConnectionMonitoring();
      } else {
        _showErrorSnackbar(
            'Reconnection failed. Please try manual connection.');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/device-discovery-screen');
          }
        });
      }
    }
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'info',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
