import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class ResourceAssignmentCard extends StatelessWidget {
  final Map<String, dynamic> resources;
  final String userRole;
  final VoidCallback? onReassign;

  const ResourceAssignmentCard({
    super.key,
    required this.resources,
    required this.userRole,
    this.onReassign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'assignment',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Asignación de Recursos',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (userRole == 'manager' && onReassign != null) ...[
                  IconButton(
                    onPressed: onReassign,
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    tooltip: 'Reasignar Recursos',
                  ),
                ],
              ],
            ),
            SizedBox(height: 3.h),
            _buildResourceItem(
              context,
              'Bahía de Servicio',
              resources['bay'] as String,
              Icons.garage_rounded,
              resources['bayStatus'] as String,
            ),
            SizedBox(height: 2.h),
            _buildResourceItem(
              context,
              'Técnico Asignado',
              resources['technician'] as String,
              Icons.person_rounded,
              resources['technicianStatus'] as String,
            ),
            if (resources['equipment'] != null) ...[
              SizedBox(height: 2.h),
              _buildResourceItem(
                context,
                'Equipo Especializado',
                resources['equipment'] as String,
                Icons.build_rounded,
                resources['equipmentStatus'] as String,
              ),
            ],
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horario de Trabajo',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${resources['startTime']} - ${resources['endTime']}',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    String status,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'disponible':
      case 'available':
        statusColor = AppTheme.successLight;
        break;
      case 'ocupado':
      case 'busy':
        statusColor = AppTheme.warningLight;
        break;
      case 'mantenimiento':
      case 'maintenance':
        statusColor = AppTheme.errorLight;
        break;
      default:
        statusColor = colorScheme.onSurfaceVariant;
    }

    return Row(
      children: [
        CustomIconWidget(
          iconName: _getIconName(icon),
          color: colorScheme.onSurfaceVariant,
          size: 16,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.garage_rounded) return 'garage';
    if (icon == Icons.person_rounded) return 'person';
    if (icon == Icons.build_rounded) return 'build';
    return 'info';
  }
}