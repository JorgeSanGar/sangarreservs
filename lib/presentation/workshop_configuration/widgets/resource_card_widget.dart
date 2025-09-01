import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResourceCardWidget extends StatelessWidget {
  final Map<String, dynamic> resource;
  final VoidCallback onTap;
  final Function(bool) onToggle;

  const ResourceCardWidget({
    super.key,
    required this.resource,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = resource['isActive'] as bool? ?? true;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              // Resource type icon
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getResourceColor(resource['type'] as String? ?? 'bay')
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName:
                        _getResourceIcon(resource['type'] as String? ?? 'bay'),
                    color:
                        _getResourceColor(resource['type'] as String? ?? 'bay'),
                    size: 6.w,
                  ),
                ),
              ),

              SizedBox(width: 4.w),

              // Resource details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource['name'] as String? ?? 'Recurso sin nombre',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getResourceTypeLabel(
                          resource['type'] as String? ?? 'bay'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (resource['description'] != null &&
                        (resource['description'] as String).isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        resource['description'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 2.w),

              // Status toggle
              Column(
                children: [
                  Switch(
                    value: isActive,
                    onChanged: onToggle,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bay':
        return 'garage';
      case 'elevator':
        return 'elevator';
      case 'equipment':
        return 'build';
      case 'tool':
        return 'handyman';
      default:
        return 'settings';
    }
  }

  Color _getResourceColor(String type) {
    switch (type.toLowerCase()) {
      case 'bay':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'elevator':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'equipment':
        return AppTheme.warningLight;
      case 'tool':
        return AppTheme.successLight;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  String _getResourceTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'bay':
        return 'Bahía de trabajo';
      case 'elevator':
        return 'Elevador';
      case 'equipment':
        return 'Equipo';
      case 'tool':
        return 'Herramienta';
      default:
        return 'Recurso';
    }
  }
}
