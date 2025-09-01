import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarFilterSheet extends StatefulWidget {
  final List<Map<String, dynamic>> resources;
  final List<String> selectedResourceIds;
  final List<String> selectedServiceTypes;
  final Function(List<String> resourceIds, List<String> serviceTypes)
      onApplyFilters;

  const CalendarFilterSheet({
    super.key,
    required this.resources,
    required this.selectedResourceIds,
    required this.selectedServiceTypes,
    required this.onApplyFilters,
  });

  @override
  State<CalendarFilterSheet> createState() => _CalendarFilterSheetState();
}

class _CalendarFilterSheetState extends State<CalendarFilterSheet> {
  late List<String> _selectedResourceIds;
  late List<String> _selectedServiceTypes;

  final List<String> _serviceTypes = [
    'Cambio de neumáticos',
    'Reparación de pinchazos',
    'Equilibrado',
    'Alineación',
    'Rotación',
    'Inspección',
  ];

  @override
  void initState() {
    super.initState();
    _selectedResourceIds = List.from(widget.selectedResourceIds);
    _selectedServiceTypes = List.from(widget.selectedServiceTypes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 10.w,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Filtros de calendario',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Limpiar todo',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: AppTheme.lightTheme.dividerColor),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),

                  // Resources section
                  _buildSectionHeader('Recursos', _selectedResourceIds.length),
                  SizedBox(height: 1.h),
                  _buildResourceFilters(),

                  SizedBox(height: 3.h),

                  // Service types section
                  _buildSectionHeader(
                      'Tipos de servicio', _selectedServiceTypes.length),
                  SizedBox(height: 1.h),
                  _buildServiceTypeFilters(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int selectedCount) {
    return Row(
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (selectedCount > 0) ...[
          SizedBox(width: 2.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              selectedCount.toString(),
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResourceFilters() {
    final groupedResources = <String, List<Map<String, dynamic>>>{};

    for (final resource in widget.resources) {
      final type = resource['type'] as String;
      groupedResources.putIfAbsent(type, () => []).add(resource);
    }

    return Column(
      children: groupedResources.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              child: Text(
                entry.key,
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...entry.value.map((resource) => _buildResourceCheckbox(resource)),
            SizedBox(height: 1.h),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildResourceCheckbox(Map<String, dynamic> resource) {
    final isSelected = _selectedResourceIds.contains(resource['id'] as String);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedResourceIds.add(resource['id'] as String);
          } else {
            _selectedResourceIds.remove(resource['id'] as String);
          }
        });
      },
      title: Row(
        children: [
          CustomIconWidget(
            iconName: _getResourceIcon(resource['type'] as String),
            color: _getResourceColor(resource['type'] as String),
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              resource['name'] as String,
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildServiceTypeFilters() {
    return Column(
      children: _serviceTypes.map((serviceType) {
        final isSelected = _selectedServiceTypes.contains(serviceType);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _selectedServiceTypes.add(serviceType);
              } else {
                _selectedServiceTypes.remove(serviceType);
              }
            });
          },
          title: Text(
            serviceType,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  String _getResourceIcon(String type) {
    switch (type) {
      case 'Elevador':
        return 'elevator';
      case 'Bahía':
        return 'garage';
      case 'Técnico':
        return 'person';
      default:
        return 'build';
    }
  }

  Color _getResourceColor(String type) {
    switch (type) {
      case 'Elevador':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'Bahía':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'Técnico':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedResourceIds.clear();
      _selectedServiceTypes.clear();
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_selectedResourceIds, _selectedServiceTypes);
    Navigator.of(context).pop();
  }
}
