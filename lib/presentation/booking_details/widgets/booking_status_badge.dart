import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class BookingStatusBadge extends StatelessWidget {
  final String status;
  final bool isLarge;

  const BookingStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    String displayText;
    IconData iconData;

    switch (status.toLowerCase()) {
      case 'programado':
      case 'scheduled':
        backgroundColor = colorScheme.primary.withValues(alpha: 0.1);
        textColor = colorScheme.primary;
        displayText = 'Programado';
        iconData = Icons.schedule_rounded;
        break;
      case 'en_progreso':
      case 'in_progress':
        backgroundColor = AppTheme.warningLight.withValues(alpha: 0.1);
        textColor = AppTheme.warningLight;
        displayText = 'En Progreso';
        iconData = Icons.build_rounded;
        break;
      case 'completado':
      case 'completed':
        backgroundColor = AppTheme.successLight.withValues(alpha: 0.1);
        textColor = AppTheme.successLight;
        displayText = 'Completado';
        iconData = Icons.check_circle_rounded;
        break;
      case 'cancelado':
      case 'cancelled':
        backgroundColor = AppTheme.errorLight.withValues(alpha: 0.1);
        textColor = AppTheme.errorLight;
        displayText = 'Cancelado';
        iconData = Icons.cancel_rounded;
        break;
      default:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
        displayText = status;
        iconData = Icons.info_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 4.w : 3.w,
        vertical: isLarge ? 1.5.h : 1.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(isLarge ? 12 : 8),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getIconName(iconData),
            color: textColor,
            size: isLarge ? 18 : 16,
          ),
          SizedBox(width: 2.w),
          Text(
            displayText,
            style: GoogleFonts.inter(
              fontSize: isLarge ? 14.sp : 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getIconName(IconData iconData) {
    if (iconData == Icons.schedule_rounded) return 'schedule';
    if (iconData == Icons.build_rounded) return 'build';
    if (iconData == Icons.check_circle_rounded) return 'check_circle';
    if (iconData == Icons.cancel_rounded) return 'cancel';
    return 'info';
  }
}