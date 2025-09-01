import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BulkActionsSheet extends StatelessWidget {
  final List<Map<String, dynamic>> selectedMembers;
  final Function(String) onBulkAction;

  const BulkActionsSheet({
    super.key,
    required this.selectedMembers,
    required this.onBulkAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          SizedBox(height: 3.h),

          // Title
          Text(
            'Acciones para ${selectedMembers.length} miembro(s)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 3.h),

          // Action buttons
          _buildActionTile(
            context,
            'Activar miembros',
            'Activar todos los miembros seleccionados',
            'check_circle',
            colorScheme.tertiary,
            () => onBulkAction('activate'),
          ),

          _buildActionTile(
            context,
            'Desactivar miembros',
            'Desactivar todos los miembros seleccionados',
            'cancel',
            colorScheme.secondary,
            () => onBulkAction('deactivate'),
          ),

          _buildActionTile(
            context,
            'Eliminar miembros',
            'Eliminar permanentemente los miembros seleccionados',
            'delete',
            colorScheme.error,
            () => onBulkAction('delete'),
          ),

          SizedBox(height: 2.h),

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 5.w,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: CustomIconWidget(
          iconName: 'arrow_forward_ios',
          color: theme.colorScheme.onSurfaceVariant,
          size: 4.w,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
    );
  }
}
