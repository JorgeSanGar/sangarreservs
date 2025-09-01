import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BookingContextMenu extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;

  const BookingContextMenu({
    super.key,
    required this.booking,
    required this.onEdit,
    required this.onDuplicate,
    required this.onReschedule,
    required this.onCancel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Booking info header
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status'] as String),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['customerName'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        booking['serviceType'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu options
          _buildMenuItem(
            context,
            icon: 'visibility',
            title: 'Ver detalles',
            onTap: () {
              Navigator.of(context).pop();
              onViewDetails();
            },
          ),

          if (_canEdit()) ...[
            _buildMenuItem(
              context,
              icon: 'edit',
              title: 'Editar reserva',
              onTap: () {
                Navigator.of(context).pop();
                onEdit();
              },
            ),
            _buildMenuItem(
              context,
              icon: 'schedule',
              title: 'Reprogramar',
              onTap: () {
                Navigator.of(context).pop();
                onReschedule();
              },
            ),
          ],

          _buildMenuItem(
            context,
            icon: 'copy',
            title: 'Duplicar reserva',
            onTap: () {
              Navigator.of(context).pop();
              onDuplicate();
            },
          ),

          if (_canCancel()) ...[
            Divider(
              color: AppTheme.lightTheme.dividerColor,
              height: 1,
            ),
            _buildMenuItem(
              context,
              icon: 'cancel',
              title: 'Cancelar reserva',
              textColor: AppTheme.lightTheme.colorScheme.error,
              iconColor: AppTheme.lightTheme.colorScheme.error,
              onTap: () {
                Navigator.of(context).pop();
                _showCancelConfirmation(context);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: iconColor ??
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color:
                        textColor ?? AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canEdit() {
    final status = booking['status'] as String;
    return status.toLowerCase() == 'programada';
  }

  bool _canCancel() {
    final status = booking['status'] as String;
    return status.toLowerCase() != 'cancelada' &&
        status.toLowerCase() != 'completada';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'programada':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'en_progreso':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'completada':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'cancelada':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar reserva',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres cancelar esta reserva?',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cliente: ${booking['customerName']}',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Servicio: ${booking['serviceType']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                  Text(
                    'Fecha: ${_formatDateTime(booking['startTime'] as String)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Esta acción no se puede deshacer.',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mantener reserva'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onCancel();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              foregroundColor: AppTheme.lightTheme.colorScheme.onError,
            ),
            child: const Text('Cancelar reserva'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
