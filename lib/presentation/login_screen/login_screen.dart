import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/workshop_service.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/workshop_logo_widget.dart';

// Add this import block //
import './widgets/login_form_widget.dart' as LoginFormWidgets;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  LoginMode _currentMode = LoginMode.workerLogin;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    // Simulate biometric availability check
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isBiometricAvailable = true;
      });
    }
  }

  /// Handle worker/manager login
  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = await AuthService.instance.signInWithEmail(
        email: email,
        password: password,
      );

      if (userModel != null && mounted) {
        HapticFeedback.lightImpact();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bienvenido, ${userModel.fullName ?? userModel.email}!',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            duration: const Duration(seconds: 2),
          ),
        );

        // Route based on role
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (userModel.isManager) {
            // Manager has access to all screens including KPIs
            Navigator.pushReplacementNamed(context, '/kpi-dashboard');
          } else {
            // Worker has restricted access
            Navigator.pushReplacementNamed(context, '/today-s-agenda');
          }
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
            'Credenciales incorrectas. Verifique su email y contraseña.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle new workshop registration (creates manager role)
  Future<void> _handleWorkshopRegistration({
    required String workshopName,
    required String managerName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create workshop and manager account
      final userModel =
          await WorkshopService.instance.createWorkshopWithManager(
        workshopName: workshopName,
        managerName: managerName,
        managerEmail: email,
        managerPassword: password,
        phone: phone,
        address: address,
      );

      if (userModel != null && mounted) {
        HapticFeedback.lightImpact();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Taller registrado exitosamente! Bienvenido, ${userModel.fullName}',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate to manager dashboard
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/kpi-dashboard');
        }
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
            'Error al registrar el taller: ${error.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle magic link authentication
  Future<void> _handleMagicLink(String email) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.resetPassword(email: email);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Enlace de acceso enviado a $email. Revise su correo.',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage(
            'Error al enviar el enlace de acceso. Inténtelo de nuevo.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle biometric authentication
  Future<void> _handleBiometricLogin() async {
    try {
      HapticFeedback.lightImpact();

      // Check if there's a saved user session
      final currentUser = await AuthService.instance.getCurrentUserProfile();

      if (currentUser != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Autenticación biométrica exitosa',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );

        // Navigate based on role
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (currentUser.isManager) {
            Navigator.pushReplacementNamed(context, '/kpi-dashboard');
          } else {
            Navigator.pushReplacementNamed(context, '/today-s-agenda');
          }
        }
      } else {
        _showErrorMessage(
            'No hay sesión guardada. Use credenciales para iniciar sesión.');
      }
    } catch (error) {
      if (mounted) {
        _showErrorMessage('Error en la autenticación biométrica.');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _switchMode(LoginMode mode) {
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: 6.h),

                    // Workshop Logo
                    const WorkshopLogoWidget(),

                    SizedBox(height: 4.h),

                    // Mode Selector Tabs
                    _buildModeSelector(colorScheme),

                    SizedBox(height: 4.h),

                    // Dynamic Content based on selected mode
                    _buildModeContent(),

                    // Biometric Authentication (only for login modes)
                    if (_currentMode != LoginMode.newWorkshop)
                      BiometricPromptWidget(
                        onBiometricLogin: _handleBiometricLogin,
                        isAvailable: _isBiometricAvailable && !_isLoading,
                      ),

                    const Spacer(),

                    // Footer
                    _buildFooter(colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildModeTab(
            'Trabajador',
            LoginMode.workerLogin,
            Icons.person,
            colorScheme,
          ),
          _buildModeTab(
            'Registrar Taller',
            LoginMode.newWorkshop,
            Icons.add_business,
            colorScheme,
          ),
          _buildModeTab(
            'Gerente',
            LoginMode.managerLogin,
            Icons.admin_panel_settings,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(
      String title, LoginMode mode, IconData icon, ColorScheme colorScheme) {
    final isSelected = _currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => _switchMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_currentMode) {
      case LoginMode.workerLogin:
        return _buildWorkerLoginContent();
      case LoginMode.newWorkshop:
        return _buildNewWorkshopContent();
      case LoginMode.managerLogin:
        return _buildManagerLoginContent();
    }
  }

  Widget _buildWorkerLoginContent() {
    return Column(
      children: [
        // Header
        Text(
          'Acceso de Trabajador',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Accede con las credenciales proporcionadas por tu gerente',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),

        // Login Form
        LoginFormWidget(
          onLogin: _handleLogin,
          onMagicLink: _handleMagicLink,
          isLoading: _isLoading,
          mode: LoginFormWidgets.LoginMode.workerLogin,
        ),
      ],
    );
  }

  Widget _buildNewWorkshopContent() {
    return WorkshopRegistrationForm(
      onSubmit: _handleWorkshopRegistration,
      isLoading: _isLoading,
    );
  }

  Widget _buildManagerLoginContent() {
    return Column(
      children: [
        // Header
        Text(
          'Acceso de Gerente',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Accede a tu panel de administración con permisos completos',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),

        // Login Form
        LoginFormWidget(
          onLogin: _handleLogin,
          onMagicLink: _handleMagicLink,
          isLoading: _isLoading,
          mode: LoginFormWidgets.LoginMode.managerLogin,
        ),
      ],
    );
  }

  Widget _buildFooter(ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Column(
        children: [
          Text(
            'Versión 1.0.0',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '© 2025 SangarReservs',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

enum LoginMode {
  workerLogin,
  newWorkshop,
  managerLogin,
}

class WorkshopRegistrationForm extends StatefulWidget {
  final Function({
    required String workshopName,
    required String managerName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) onSubmit;
  final bool isLoading;

  const WorkshopRegistrationForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<WorkshopRegistrationForm> createState() =>
      _WorkshopRegistrationFormState();
}

class _WorkshopRegistrationFormState extends State<WorkshopRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _workshopNameController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _workshopNameController.dispose();
    _managerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header
        Text(
          'Registrar Nuevo Taller',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Crea tu taller y obtén acceso completo como gerente',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),

        // Registration Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              // Workshop Name
              TextFormField(
                controller: _workshopNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Taller',
                  hintText: 'Ej: Taller Los Pinos',
                  prefixIcon: Icon(Icons.business, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del taller es requerido';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Manager Name
              TextFormField(
                controller: _managerNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Gerente',
                  hintText: 'Tu nombre completo',
                  prefixIcon: Icon(Icons.person, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre del gerente es requerido';
                  }
                  if (value.trim().length < 2) {
                    return 'El nombre debe tener al menos 2 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  hintText: 'gerente@taller.com',
                  prefixIcon: Icon(Icons.email, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El correo electrónico es requerido';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icon(Icons.lock, color: colorScheme.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: colorScheme.primary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La contraseña es requerida';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  hintText: '+34 123 456 789',
                  prefixIcon: Icon(Icons.phone, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Address
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Dirección del Taller',
                  hintText: 'Calle, número, ciudad',
                  prefixIcon:
                      Icon(Icons.location_on, color: colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La dirección es requerida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 4.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: widget.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.onPrimary),
                          ),
                        )
                      : Text(
                          'Registrar Taller',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        workshopName: _workshopNameController.text.trim(),
        managerName: _managerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
    }
  }
}