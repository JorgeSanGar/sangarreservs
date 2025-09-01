import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class VisitModeIndicator extends StatelessWidget {
  final String visitMode;
  final String arrivalWindow;

  const VisitModeIndicator({
    super.key,
    required this.visitMode,
    required this.arrivalWindow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isWaitMode = visitMode.toLowerCase() == 'esperar' ||
        visitMode.toLowerCase() == 'wait';
    final modeColor = isWaitMode ? AppTheme.warningLight : colorScheme.primary;
    final modeIcon = isWaitMode ? 'hourglass_empty' : 'directions_car';
    final modeTitle =
        isWaitMode ? 'Modalidad: Esperar' : 'Modalidad: Dejar y Recoger';
    final modeDescription = isWaitMode
        ? 'El cliente esperará mientras se realiza el servicio'
        : 'El cliente dejará el vehículo y lo recogerá más tarde';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: modeIcon,
                    color: modeColor,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    modeTitle,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              modeDescription,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: modeColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: modeColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: modeColor,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Ventana de Llegada Recomendada',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: modeColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    arrivalWindow,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    isWaitMode
                        ? 'Llegue dentro de esta ventana para minimizar el tiempo de espera'
                        : 'Puede dejar su vehículo en cualquier momento dentro de esta ventana',
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}