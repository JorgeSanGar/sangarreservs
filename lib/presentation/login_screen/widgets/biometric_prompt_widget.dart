import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricPromptWidget extends StatelessWidget {
  final VoidCallback onBiometricLogin;
  final bool isAvailable;

  const BiometricPromptWidget({
    super.key,
    required this.onBiometricLogin,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!isAvailable) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: 4.h),

        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Acceso rápido',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric Button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onBiometricLogin();
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 16.w,
                height: 16.w,
                padding: EdgeInsets.all(4.w),
                child: CustomIconWidget(
                  iconName: 'fingerprint',
                  color: colorScheme.onPrimaryContainer,
                  size: 8.w,
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 2.h),

        Text(
          'Usar huella dactilar',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}