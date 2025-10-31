import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Splash screen for the Umbrella App providing branded launch experience
/// while initializing Bluetooth services and determining navigation path
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _loadingAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing Bluetooth services...';
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo fade and scale animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));

    // Loading indicator animation
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _logoAnimationController.forward();
    _loadingAnimationController.repeat();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization steps with realistic timing
      await _checkBluetoothPermissions();
      await _initializeBluetoothServices();
      await _loadAudioAssets();
      await _prepareDeviceCache();

      // Navigate to device discovery after successful initialization
      if (mounted && !_hasError) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacementNamed(context, '/device-discovery-screen');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _checkBluetoothPermissions() async {
    setState(() {
      _initializationStatus = 'Checking Bluetooth permissions...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulate permission check - in real implementation, use permission_handler
    // This would check for BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION permissions
  }

  Future<void> _initializeBluetoothServices() async {
    setState(() {
      _initializationStatus = 'Initializing Bluetooth adapter...';
    });
    await Future.delayed(const Duration(milliseconds: 1000));

    // Simulate Bluetooth adapter initialization
    // In real implementation, this would initialize flutter_blue_plus
    // and check if Bluetooth is enabled
  }

  Future<void> _loadAudioAssets() async {
    setState(() {
      _initializationStatus = 'Loading audio assets...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Simulate audio asset loading for disconnect alerts
    // In real implementation, this would preload audio files using audioplayers
  }

  Future<void> _prepareDeviceCache() async {
    setState(() {
      _initializationStatus = 'Preparing device cache...';
    });
    await Future.delayed(const Duration(milliseconds: 400));

    // Simulate device cache preparation
    // In real implementation, this would initialize local storage for device data
  }

  String _getErrorMessage(dynamic error) {
    // Return user-friendly error messages based on error type
    if (error.toString().contains('bluetooth')) {
      return 'Bluetooth is not available on this device';
    } else if (error.toString().contains('permission')) {
      return 'Bluetooth permissions are required';
    } else {
      return 'Failed to initialize app services';
    }
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _isInitializing = true;
      _initializationStatus = 'Retrying initialization...';
    });
    _initializeApp();
  }

  void _openSettings() {
    // In real implementation, this would open device Bluetooth settings
    // using url_launcher or similar package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Please enable Bluetooth in device settings',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style to match brand color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.lightTheme.colorScheme.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.primary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildLogo(),
              SizedBox(height: 8.h),
              _buildAppName(),
              const Spacer(flex: 1),
              _buildInitializationContent(),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'umbrella',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppName() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _logoFadeAnimation.value,
          child: Text(
            'Umbrella App',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitializationContent() {
    if (_hasError) {
      return _buildErrorContent();
    } else {
      return _buildLoadingContent();
    }
  }

  Widget _buildLoadingContent() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _loadingAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 6.w,
              height: 6.w,
              child: CircularProgressIndicator(
                value: null,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.8),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 3.h),
        Text(
          _initializationStatus,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3.w),
          ),
          child: CustomIconWidget(
            iconName: 'error_outline',
            color: Colors.white,
            size: 8.w,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Initialization Failed',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              label: 'Retry',
              onPressed: _retryInitialization,
              isPrimary: true,
            ),
            SizedBox(width: 4.w),
            _buildActionButton(
              label: 'Settings',
              onPressed: _openSettings,
              isPrimary: false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.white : Colors.transparent,
        foregroundColor:
            isPrimary ? AppTheme.lightTheme.colorScheme.primary : Colors.white,
        elevation: isPrimary ? 2 : 0,
        side: isPrimary
            ? null
            : BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
