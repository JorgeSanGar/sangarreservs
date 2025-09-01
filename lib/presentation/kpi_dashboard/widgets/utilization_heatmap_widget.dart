import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class UtilizationHeatmapWidget extends StatelessWidget {
  final List<Map<String, dynamic>> utilizationData;

  const UtilizationHeatmapWidget({
    super.key,
    required this.utilizationData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Group data by resource and hour
    final groupedData = <String, Map<int, int>>{};
    final resources = <String>{};
    final hours = <int>{};

    for (final data in utilizationData) {
      final resource = data['resource'] as String;
      final hour = data['hour'] as int;
      final utilization = data['utilization'] as int;

      resources.add(resource);
      hours.add(hour);

      if (!groupedData.containsKey(resource)) {
        groupedData[resource] = {};
      }
      groupedData[resource]![hour] = utilization;
    }

    final sortedHours = hours.toList()..sort();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mapa de Calor - Utilización',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'grid_view',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Text(
              'Utilización de recursos por hora (porcentaje)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 3.h),

            // Heatmap grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with hours
                  Row(
                    children: [
                      SizedBox(width: 25.w), // Space for resource labels
                      ...sortedHours.map((hour) {
                        return Container(
                          width: 12.w,
                          height: 4.h,
                          alignment: Alignment.center,
                          child: Text(
                            '${hour}:00',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                  // Data rows
                  ...resources.map((resource) {
                    return Row(
                      children: [
                        // Resource label
                        Container(
                          width: 25.w,
                          height: 8.h,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(right: 2.w),
                          child: Text(
                            resource,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Utilization cells
                        ...sortedHours.map((hour) {
                          final utilization = groupedData[resource]?[hour] ?? 0;
                          return _buildUtilizationCell(
                            context,
                            utilization,
                            resource,
                            hour,
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilizationCell(
    BuildContext context,
    int utilization,
    String resource,
    int hour,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color cellColor;
    Color textColor;

    if (utilization >= 90) {
      cellColor = colorScheme.error;
      textColor = Colors.white;
    } else if (utilization >= 75) {
      cellColor = colorScheme.primary;
      textColor = Colors.white;
    } else if (utilization >= 50) {
      cellColor = colorScheme.secondary;
      textColor = Colors.white;
    } else if (utilization >= 25) {
      cellColor = colorScheme.tertiary.withValues(alpha: 0.7);
      textColor = colorScheme.onSurface;
    } else {
      cellColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: () =>
          _showUtilizationDetails(context, resource, hour, utilization),
      child: Container(
        width: 12.w,
        height: 8.h,
        margin: EdgeInsets.all(0.5.w),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${utilization}%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            if (utilization > 0) ...[
              CustomIconWidget(
                iconName: _getUtilizationIcon(utilization),
                color: textColor,
                size: 3.w,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leyenda de Utilización',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.h,
          children: [
            _buildLegendItem(
              context,
              '90%+',
              'Sobrecarga',
              colorScheme.error,
            ),
            _buildLegendItem(
              context,
              '75-89%',
              'Alta',
              colorScheme.primary,
            ),
            _buildLegendItem(
              context,
              '50-74%',
              'Media',
              colorScheme.secondary,
            ),
            _buildLegendItem(
              context,
              '25-49%',
              'Baja',
              colorScheme.tertiary.withValues(alpha: 0.7),
            ),
            _buildLegendItem(
              context,
              '0-24%',
              'Muy baja',
              colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String range,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '$range - $label',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getUtilizationIcon(int utilization) {
    if (utilization >= 90) {
      return 'warning';
    } else if (utilization >= 75) {
      return 'trending_up';
    } else if (utilization >= 50) {
      return 'trending_flat';
    } else {
      return 'trending_down';
    }
  }

  void _showUtilizationDetails(
    BuildContext context,
    String resource,
    int hour,
    int utilization,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detalles de Utilización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recurso: $resource'),
            Text('Hora: ${hour}:00 - ${hour + 1}:00'),
            Text('Utilización: $utilization%'),
            SizedBox(height: 2.h),
            Text(
              _getUtilizationDescription(utilization),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _getUtilizationDescription(int utilization) {
    if (utilization >= 90) {
      return 'Recurso en sobrecarga. Considere reasignar servicios o agregar más recursos.';
    } else if (utilization >= 75) {
      return 'Alta utilización. El recurso está siendo bien aprovechado.';
    } else if (utilization >= 50) {
      return 'Utilización media. Hay capacidad disponible para más servicios.';
    } else if (utilization >= 25) {
      return 'Baja utilización. Considere promociones o reasignación de recursos.';
    } else {
      return 'Muy baja utilización. Recurso subutilizado, requiere atención.';
    }
  }
}
