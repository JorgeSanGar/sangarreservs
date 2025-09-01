import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final String bookingStatus;
  final String userRole;
  final VoidCallback? onStartService;
  final VoidCallback? onCompleteService;
  final VoidCallback? onPauseService;
  final VoidCallback? onResumeService;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final VoidCallback? onDuplicate;
  final bool isServicePaused;

  const ActionButtonsWidget({
    super.key,
    required this.bookingStatus,
    required this.userRole,
    this.onStartService,
    this.onCompleteService,
    this.onPauseService,
    this.onResumeService,
    this.onReschedule,
    this.onCancel,
    this.onDuplicate,
    this.isServicePaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPrimaryActions(context),
            if (userRole == 'manager') ...[
              SizedBox(height: 2.h),
              _buildSecondaryActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (bookingStatus.toLowerCase()) {
      case 'programado':
      case 'scheduled':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              onStartService?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'play_arrow',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Iniciar Servicio',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );

      case 'en_progreso':
      case 'in_progress':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (isServicePaused) {
                        onResumeService?.call();
                      } else {
                        onPauseService?.call();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isServicePaused
                          ? AppTheme.successLight
                          : AppTheme.warningLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: isServicePaused ? 'play_arrow' : 'pause',
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          isServicePaused ? 'Reanudar' : 'Pausar',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onCompleteService?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Marcar Completado',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case 'completado':
      case 'completed':
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.successLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.successLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Servicio Completado',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successLight,
                ),
              ),
            ],
          ),
        );

      case 'cancelado':
      case 'cancelled':
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: AppTheme.errorLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.errorLight.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'cancel',
                color: AppTheme.errorLight,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Cita Cancelada',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.errorLight,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSecondaryActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onDuplicate?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'copy',
                  color: colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Duplicar',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: OutlinedButton(
            onPressed: bookingStatus.toLowerCase() == 'completado' ||
                    bookingStatus.toLowerCase() == 'cancelado'
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onReschedule?.call();
                  },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: bookingStatus.toLowerCase() == 'completado' ||
                          bookingStatus.toLowerCase() == 'cancelado'
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Reprogramar',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: OutlinedButton(
            onPressed: bookingStatus.toLowerCase() == 'completado' ||
                    bookingStatus.toLowerCase() == 'cancelado'
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    _showCancelDialog(context);
                  },
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: bookingStatus.toLowerCase() == 'completado' ||
                        bookingStatus.toLowerCase() == 'cancelado'
                    ? colorScheme.outline
                    : AppTheme.errorLight,
              ),
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'cancel',
                  color: bookingStatus.toLowerCase() == 'completado' ||
                          bookingStatus.toLowerCase() == 'cancelado'
                      ? colorScheme.onSurfaceVariant
                      : AppTheme.errorLight,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: bookingStatus.toLowerCase() == 'completado' ||
                            bookingStatus.toLowerCase() == 'cancelado'
                        ? colorScheme.onSurfaceVariant
                        : AppTheme.errorLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar Cita',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Está seguro de que desea cancelar esta cita? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Mantener Cita',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              HapticFeedback.heavyImpact();
              onCancel?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Cancelar Cita',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}