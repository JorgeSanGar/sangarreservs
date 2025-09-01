import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class BulkOperationsToolbarWidget extends StatelessWidget {
  final int selectedCount;
  final ValueChanged<String> onOperation;
  final VoidCallback onClear;

  const BulkOperationsToolbarWidget({
    super.key,
    required this.selectedCount,
    required this.onOperation,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Selection Info
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.checklist_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  '$selectedCount servicios seleccionados',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            children: [
              // Activate/Deactivate
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.toggle_on_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Cambiar Estado',
                onSelected: onOperation,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 18, color: Colors.green),
                        SizedBox(width: 12),
                        Text('Activar Todos'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Row(
                      children: [
                        Icon(Icons.cancel_rounded,
                            size: 18, color: Colors.orange),
                        SizedBox(width: 12),
                        Text('Desactivar Todos'),
                      ],
                    ),
                  ),
                ],
              ),

              // Price Update
              IconButton(
                icon: Icon(
                  Icons.euro_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                onPressed: () => onOperation('price_update'),
                tooltip: 'Actualizar Precios',
              ),

              // Duplicate
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                onPressed: () => onOperation('duplicate'),
                tooltip: 'Duplicar',
              ),

              // More Options
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
                tooltip: 'Más Opciones',
                onSelected: onOperation,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded, size: 18),
                        SizedBox(width: 12),
                        Text('Exportar Seleccionados'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'move_category',
                    child: Row(
                      children: [
                        Icon(Icons.folder_rounded, size: 18),
                        SizedBox(width: 12),
                        Text('Cambiar Categoría'),
                      ],
                    ),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Eliminar Todos',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(width: 2.w),

              // Clear Selection
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onPrimaryContainer,
                ),
                child: Text(
                  'Limpiar',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
