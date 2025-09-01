import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/booking_confirmation_step.dart';
import './widgets/schedule_selection_step.dart';
import './widgets/service_selection_step.dart';
import './widgets/vehicle_configuration_step.dart';
import './widgets/wizard_progress_indicator.dart';

class BookingCreationWizard extends StatefulWidget {
  const BookingCreationWizard({super.key});

  @override
  State<BookingCreationWizard> createState() => _BookingCreationWizardState();
}

class _BookingCreationWizardState extends State<BookingCreationWizard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int currentStep = 0;
  Map<String, dynamic>? selectedService;
  Map<String, dynamic>? vehicleConfig;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  Map<String, dynamic>? selectedSlot;

  final List<String> stepTitles = [
    'Servicio',
    'Configuración',
    'Horario',
    'Confirmación',
  ];

  bool get canProceedToNext {
    switch (currentStep) {
      case 0:
        return selectedService != null;
      case 1:
        return vehicleConfig != null;
      case 2:
        return selectedDate != null && selectedTime != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Reserva'),
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          WizardProgressIndicator(
            currentStep: currentStep,
            totalSteps: stepTitles.length,
            stepTitles: stepTitles,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                ServiceSelectionStep(
                  selectedService: selectedService,
                  onServiceSelected: (service) {
                    setState(() {
                      selectedService = service;
                    });
                  },
                ),
                VehicleConfigurationStep(
                  vehicleConfig: vehicleConfig,
                  selectedService: selectedService,
                  onConfigChanged: (config) {
                    setState(() {
                      vehicleConfig = config;
                    });
                  },
                ),
                ScheduleSelectionStep(
                  selectedSlot: selectedSlot,
                  onSlotSelected: _onSlotSelected,
                  estimatedDuration: _calculateEstimatedDuration(),
                ),
                BookingConfirmationStep(
                  selectedService: selectedService,
                  vehicleConfig: vehicleConfig,
                  selectedSlot: selectedSlot,
                  onBookingConfirmed: _handleBookingConfirmation,
                ),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Atrás',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
            ],
            Expanded(
              flex: currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: canProceedToNext ? _goToNextStep : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: canProceedToNext
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentStep == stepTitles.length - 1
                          ? 'Finalizar'
                          : 'Siguiente',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: canProceedToNext
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (currentStep < stepTitles.length - 1) ...[
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: canProceedToNext
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onServiceSelected(Map<String, dynamic> service) {
    setState(() {
      selectedService = service;
    });
    HapticFeedback.lightImpact();
  }

  void _onVehicleConfigChanged(Map<String, dynamic> config) {
    setState(() {
      vehicleConfig = config;
    });
  }

  void _onSlotSelected(Map<String, dynamic> slot) {
    setState(() {
      selectedSlot = slot;
    });
    HapticFeedback.lightImpact();
  }

  void _onBookingConfirmed(Map<String, dynamic> bookingData) {
    HapticFeedback.mediumImpact();
    _showSuccessDialog(bookingData);
  }

  void _goToNextStep() {
    if (currentStep < stepTitles.length - 1 && canProceedToNext) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  void _goToPreviousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    }
  }

  int _calculateEstimatedDuration() {
    if (selectedService == null || vehicleConfig == null) return 30;

    int baseDuration = (selectedService!["baseDuration"] as int);
    final vehicleType = vehicleConfig!["vehicleType"] as String;
    final wheelCount = vehicleConfig!["wheelCount"] as int;

    // Vehicle type multiplier
    switch (vehicleType) {
      case "4x4":
        baseDuration = (baseDuration * 1.3).round();
        break;
      case "SUV":
        baseDuration = (baseDuration * 1.5).round();
        break;
    }

    // Wheel count multiplier
    baseDuration = (baseDuration * wheelCount / 4).round();

    // Additional services
    if (vehicleConfig!["punctureRepair"] as bool) baseDuration += 15;
    if (vehicleConfig!["balancing"] as bool) baseDuration += 20;
    if (vehicleConfig!["alignment"] as bool) baseDuration += 30;

    return baseDuration;
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Reserva',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres cancelar? Se perderán todos los datos introducidos.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continuar',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: Text(
              'Cancelar',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> bookingData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 12.w,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              '¡Reserva Confirmada!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Tu cita ha sido programada exitosamente.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'ID de Reserva',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '#${bookingData["bookingId"]}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/today-s-agenda');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Ver Agenda',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBookingConfirmation(Map<String, dynamic> bookingData) {
    HapticFeedback.mediumImpact();
    _showSuccessDialog(bookingData);
  }
}