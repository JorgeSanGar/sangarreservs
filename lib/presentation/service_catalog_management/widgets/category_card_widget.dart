import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CategoryCardWidget extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = category['color'] as Color;

    return Card(
      margin: EdgeInsets.only(bottom: 3.w),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Row(
                children: [
                  // Category Icon
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category['icon'],
                      color: categoryColor,
                      size: 6.w,
                    ),
                  ),

                  SizedBox(width: 4.w),

                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category['name'],
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '${category['serviceCount']} servicios',
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Revenue Display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '€${category['totalRevenue'].toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.tertiary,
                        ),
                      ),
                      Text(
                        'ingresos total',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
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
                          onEdit();
                          break;
                        case 'add_service':
                          // TODO: Add service to this category
                          break;
                        case 'export':
                          // TODO: Export category services
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'add_service',
                        child: Row(
                          children: [
                            Icon(Icons.add_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Agregar Servicio'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Editar Categoría'),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.download_rounded, size: 18),
                            SizedBox(width: 12),
                            Text('Exportar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Service Preview List
              if (category['services'] != null &&
                  (category['services'] as List).isNotEmpty)
                _buildServicePreviewList(colorScheme, categoryColor),

              // Expand/Collapse Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: categoryColor,
                    ),
                    label: Text(
                      'Ver todos los servicios',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: categoryColor,
                      ),
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

  Widget _buildServicePreviewList(
      ColorScheme colorScheme, Color categoryColor) {
    final services = category['services'] as List<Map<String, dynamic>>;
    final previewServices = services.take(3).toList();

    return Column(
      children: previewServices.map((service) {
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Service Status Indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      service['isActive'] ? categoryColor : colorScheme.outline,
                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 3.w),

              // Service Name and Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${service['duration']} min',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Service Price
              Text(
                '€${service['price'].toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: categoryColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
