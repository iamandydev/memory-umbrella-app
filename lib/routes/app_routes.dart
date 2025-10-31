import 'package:flutter/material.dart';
import '../presentation/device_discovery_screen/device_discovery_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/device_control_screen/device_control_screen.dart';
import '../presentation/connection_status_screen/connection_status_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String deviceDiscovery = '/device-discovery-screen';
  static const String splash = '/splash-screen';
  static const String deviceControl = '/device-control-screen';
  static const String connectionStatus = '/connection-status-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const DeviceDiscoveryScreen(),
    deviceDiscovery: (context) => const DeviceDiscoveryScreen(),
    splash: (context) => const SplashScreen(),
    deviceControl: (context) => const DeviceControlScreen(),
    connectionStatus: (context) => const ConnectionStatusScreen(),
    // TODO: Add your other routes here
  };
}
