import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingCardWidget extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onTap;
  final VoidCallback? onStartService;
  final VoidCallback? onContactCustomer;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;

  const BookingCardWidget({
    super.key,
    required this.booking,
    this.onTap,
    this.onStartService,
    this.onContactCustomer,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(booking['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onStartService?.call(),
              backgroundColor: AppTheme.successLight,
              foregroundColor: Colors.white,
              icon: Icons.play_arrow_rounded,
              label: 'Iniciar',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onContactCustomer?.call(),
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.phone_rounded,
              label: 'Contactar',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onReschedule?.call(),
              backgroundColor: AppTheme.warningLight,
              foregroundColor: Colors.white,
              icon: Icons.schedule_rounded,
              label: 'Reprogramar',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onCancel?.call(),
              backgroundColor: colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.cancel_rounded,
              label: 'Cancelar',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      _getStatusColor(booking['status'] as String, colorScheme)
                          .withValues(alpha: 0.3),
                  width: 1,
                ),
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
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getServiceIconColor(
                                  booking['serviceType'] as String)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName:
                              _getServiceIcon(booking['serviceType'] as String),
                          color: _getServiceIconColor(
                              booking['serviceType'] as String),
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking['customerName'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              booking['serviceType'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(context, booking['status'] as String),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${booking['startTime']} - ${booking['endTime']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      CustomIconWidget(
                        iconName: 'timer',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${booking['estimatedDuration']} min',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (booking['vehicleInfo'] != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'directions_car',
                          color: colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          booking['vehicleInfo'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(status, colorScheme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return colorScheme.primary;
      case 'in-progress':
        return AppTheme.warningLight;
      case 'completed':
        return AppTheme.successLight;
      case 'delayed':
        return colorScheme.error;
      case 'cancelled':
        return colorScheme.onSurfaceVariant;
      default:
        return colorScheme.primary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Programado';
      case 'in-progress':
        return 'En Progreso';
      case 'completed':
        return 'Completado';
      case 'delayed':
        return 'Retrasado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Programado';
    }
  }

  String _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cambio de neumáticos':
        return 'tire_repair';
      case 'reparación de pinchazos':
        return 'build';
      case 'equilibrado':
        return 'balance';
      case 'alineación':
        return 'straighten';
      default:
        return 'tire_repair';
    }
  }

  Color _getServiceIconColor(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'cambio de neumáticos':
        return AppTheme.primaryLight;
      case 'reparación de pinchazos':
        return AppTheme.warningLight;
      case 'equilibrado':
        return AppTheme.successLight;
      case 'alineación':
        return AppTheme.secondaryLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
