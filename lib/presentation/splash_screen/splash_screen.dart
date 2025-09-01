import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _tireRotationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;

  double _progressValue = 0.0;
  String _loadingMessage = 'Iniciando aplicación...';
  bool _hasError = false;
  String? _errorMessage;
  bool _isOffline = false;

  final List<String> _loadingStages = [
    'Iniciando aplicación...',
    'Verificando autenticación...',
    'Sincronizando datos...',
    'Cargando recursos...',
    'Finalizando...'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  void _setupAnimations() {
    // Logo scale and fade animation
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Tire rotation animation
    _tireRotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _logoAnimationController.forward();
    _tireRotationController.repeat();
  }

  Future<void> _startInitialization() async {
    await _checkConnectivity();

    if (!_hasError) {
      await _performLoadingStages();
    }

    if (mounted && !_hasError) {
      _navigateToNextScreen();
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      if (connectivityResults.contains(ConnectivityResult.none)) {
        setState(() {
          _isOffline = true;
          _loadingMessage = 'Sin conexión - Modo offline';
        });
      }
    } catch (e) {
      // Continue with initialization even if connectivity check fails
      debugPrint('Connectivity check failed: $e');
    }
  }

  Future<void> _performLoadingStages() async {
    try {
      for (int i = 0; i < _loadingStages.length; i++) {
        if (!mounted) return;

        setState(() {
          _loadingMessage = _loadingStages[i];
          _progressValue = (i + 1) / _loadingStages.length;
        });

        // Simulate different loading times for each stage
        int delay = i == 1 ? 1000 : 600; // Authentication check takes longer
        await Future.delayed(Duration(milliseconds: delay));

        // Simulate potential authentication error (rarely)
        if (i == 1 && DateTime.now().millisecond % 100 == 0) {
          throw Exception('Error de autenticación');
        }
      }

      // Ensure minimum display time
      if (_progressValue >= 1.0) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _loadingMessage = 'Error durante la inicialización';
      });
    }
  }

  void _navigateToNextScreen() {
    // TODO: Check authentication status here
    // For now, always navigate to login screen
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _progressValue = 0.0;
      _loadingMessage = 'Reintentando...';
    });
    _startInitialization();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _tireRotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withValues(alpha: 0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Column(
                              children: [
                                // Workshop Logo
                                Container(
                                  width: 35.w,
                                  height: 35.w,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.shadow,
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: CustomImageWidget(
                                      imageUrl:
                                          'assets/images/img_app_logo.svg',
                                      width: 20.w,
                                      height: 20.w,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 3.h),

                                // App Name
                                Text(
                                  'SangarReservs',
                                  style: GoogleFonts.inter(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                SizedBox(height: 1.h),

                                // Tagline
                                Text(
                                  'Gestión Profesional de Neumáticos',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 8.h),

                    // Loading Animation Section
                    if (!_hasError) ...[
                      // Tire Rotation Animation
                      AnimatedBuilder(
                        animation: _tireRotationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _tireRotationController.value * 2 * 3.14159,
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.outline,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.tire_repair_rounded,
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 4.h),

                      // Progress Bar
                      Container(
                        width: 60.w,
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progressValue,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Loading Message
                      Text(
                        _loadingMessage,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Offline Indicator
                      if (_isOffline) ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                color: colorScheme.onErrorContainer,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Sin conexión a internet',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Error State
                    if (_hasError) ...[
                      Container(
                        padding: EdgeInsets.all(4.w),
                        margin: EdgeInsets.symmetric(horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              color: colorScheme.error,
                              size: 8.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Error de Inicialización',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'No se pudo inicializar la aplicación correctamente.',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: colorScheme.onErrorContainer,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 3.h),
                            ElevatedButton(
                              onPressed: _retryInitialization,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.5.h,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 18),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Reintentar',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 3.h,
                ),
                child: Column(
                  children: [
                    Text(
                      'Versión 1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '© 2025 SangarReservs - Taller Profesional',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color:
                            colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
