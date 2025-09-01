import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResourceUtilizationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> resourceData;

  const ResourceUtilizationWidget({
    super.key,
    required this.resourceData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'bar_chart',
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Utilización de Recursos',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...resourceData
              .map((resource) => _buildResourceBar(context, resource)),
        ],
      ),
    );
  }

  Widget _buildResourceBar(
      BuildContext context, Map<String, dynamic> resource) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final utilization = (resource['utilization'] as double).clamp(0.0, 1.0);

    Color getUtilizationColor() {
      if (utilization >= 0.9) return colorScheme.error;
      if (utilization >= 0.7) return AppTheme.warningLight;
      return AppTheme.successLight;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                resource['name'] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '${(utilization * 100).toInt()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: getUtilizationColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: utilization,
              child: Container(
                decoration: BoxDecoration(
                  color: getUtilizationColor(),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
