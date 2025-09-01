import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WizardProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const WizardProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCompleted = stepNumber < currentStep;
              final isCurrent = stepNumber == currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStepIndicator(
                        stepNumber,
                        isCompleted,
                        isCurrent,
                      ),
                    ),
                    if (index < totalSteps - 1)
                      _buildConnector(isCompleted || isCurrent),
                  ],
                ),
              );
            }),
          ),

          SizedBox(height: 1.h),

          // Current step title
          Text(
            '${currentStep}/${totalSteps}: ${stepTitles[currentStep - 1]}',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, bool isCompleted, bool isCurrent) {
    Color backgroundColor;
    Color foregroundColor;
    Widget child;

    if (isCompleted) {
      backgroundColor = AppTheme.lightTheme.colorScheme.primary;
      foregroundColor = AppTheme.lightTheme.colorScheme.onPrimary;
      child = CustomIconWidget(
        iconName: 'check',
        color: foregroundColor,
        size: 4.w,
      );
    } else if (isCurrent) {
      backgroundColor = AppTheme.lightTheme.colorScheme.primary;
      foregroundColor = AppTheme.lightTheme.colorScheme.onPrimary;
      child = Text(
        stepNumber.toString(),
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: foregroundColor,
        ),
      );
    } else {
      backgroundColor = AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
      foregroundColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
      child = Text(
        stepNumber.toString(),
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: foregroundColor,
        ),
      );
    }

    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
                width: 3,
              )
            : null,
      ),
      child: Center(child: child),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 6.w,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.lightTheme.colorScheme.primary
            : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
