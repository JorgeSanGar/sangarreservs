import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class ServiceCardWidget extends StatefulWidget {
  final Map<String, dynamic> service;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const ServiceCardWidget({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  State<ServiceCardWidget> createState() => _ServiceCardWidgetState();
}

class _ServiceCardWidgetState extends State<ServiceCardWidget> {
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _isActive = widget.service['isActive'] ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor =
        widget.service['categoryColor'] as Color? ?? colorScheme.primary;

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: widget.isSelected ? 4 : 2,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onTap, // For selection on long press
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Selection Checkbox
                    Checkbox(
                      value: widget.isSelected,
                      onChanged: (_) => widget.onTap(),
                      activeColor: colorScheme.primary,
                    ),

                    // Drag Handle
                    Icon(
                      Icons.drag_handle_rounded,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),

                    SizedBox(width: 3.w),

                    // Service Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.service['name'],
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              // Active Status Toggle
                              Switch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                  // TODO: Update service active status
                                },
                                activeColor: categoryColor,
                              ),
                            ],
                          ),

                          SizedBox(height: 0.5.h),

                          // Category and Duration
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.service['categoryName'] ??
                                      'Sin categoría',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: categoryColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '${widget.service['duration']} min',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€${widget.service['price'].toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.tertiary,
                          ),
                        ),
                        Text(
                          'EUR',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 2.w),

                    // More Options
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            widget.onEdit();
                            break;
                          case 'duplicate':
                            widget.onDuplicate();
                            break;
                          case 'delete':
                            widget.onDelete();
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 18),
                              SizedBox(width: 12),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy_rounded, size: 18),
                              SizedBox(width: 12),
                              Text('Duplicar'),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded,
                                  size: 18, color: colorScheme.error),
                              SizedBox(width: 12),
                              Text('Eliminar',
                                  style: TextStyle(color: colorScheme.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Additional Info (expandable)
                if (widget.isSelected) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Skill Requirements
                        Row(
                          children: [
                            Icon(
                              Icons.engineering_rounded,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Habilidad requerida:',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getSkillColor(
                                    widget.service['skillRequired']),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getSkillLabel(widget.service['skillRequired']),
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        // Equipment Requirements
                        Row(
                          children: [
                            Icon(
                              Icons.build_rounded,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Equipo:',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              widget.service['equipment'] ?? 'No especificado',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSkillColor(String? skill) {
    switch (skill?.toLowerCase()) {
      case 'basic':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSkillLabel(String? skill) {
    switch (skill?.toLowerCase()) {
      case 'basic':
        return 'Básico';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return 'No especificado';
    }
  }
}
