import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyAgendaWidget extends StatelessWidget {
  final VoidCallback? onCreateBooking;

  const EmptyAgendaWidget({
    super.key,
    this.onCreateBooking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'event_available',
                color: colorScheme.primary,
                size: 20.w,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '¡Sin servicios programados hoy!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Aprovecha este tiempo libre para organizar el taller o crear nuevas reservas para los próximos días.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onCreateBooking,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Crear Nueva Reserva'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/calendar-view'),
              icon: CustomIconWidget(
                iconName: 'calendar_month',
                color: colorScheme.primary,
                size: 18,
              ),
              label: const Text('Ver Calendario Completo'),
            ),
          ],
        ),
      ),
    );
  }
}
