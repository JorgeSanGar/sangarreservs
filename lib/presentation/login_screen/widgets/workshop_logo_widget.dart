import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WorkshopLogoWidget extends StatelessWidget {
  const WorkshopLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Container
        Container(
          width: 25.w,
          height: 25.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'build_circle',
              color: colorScheme.primary,
              size: 15.w,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // App Name
        Text(
  'Sangar',
  style: GoogleFonts.inter(
    color: colorScheme.onSurface,
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  ).copyWith(
    color: Color(0XFF1E293B),
    fontFamily: 'Inter_700',
    fontSize: 31,
    fontWeight: FontWeight.w700,
    height: 1.43,
    letterSpacing: -0.5,
    wordSpacing: 0,
  ),
),

        SizedBox(height: 1.h),

        // Tagline
        Text(
          'Gestión Inteligente de Talleres',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}