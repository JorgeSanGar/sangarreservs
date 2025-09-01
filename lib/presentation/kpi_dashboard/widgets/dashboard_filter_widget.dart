import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DashboardFilterWidget extends StatefulWidget {
  final String selectedTimeRange;
  final String selectedServiceType;
  final List<String> selectedTeamMembers;
  final Function(String, String, List<String>) onFiltersChanged;

  const DashboardFilterWidget({
    super.key,
    required this.selectedTimeRange,
    required this.selectedServiceType,
    required this.selectedTeamMembers,
    required this.onFiltersChanged,
  });

  @override
  State<DashboardFilterWidget> createState() => _DashboardFilterWidgetState();
}

class _DashboardFilterWidgetState extends State<DashboardFilterWidget> {
  late String _selectedTimeRange;
  late String _selectedServiceType;
  late List<String> _selectedTeamMembers;

  final Map<String, String> _timeRangeOptions = {
    'day': 'Hoy',
    'week': 'Esta semana',
    'month': 'Este mes',
    'year': 'Este año',
  };

  final Map<String, String> _serviceTypeOptions = {
    'all': 'Todos los servicios',
    'tire_change': 'Cambio de neumáticos',
    'balancing': 'Balanceado',
    'alignment': 'Alineación',
    'repair': 'Reparaciones',
  };

  final List<Map<String, String>> _teamMemberOptions = [
    {'id': '1', 'name': 'Miguel Rodríguez'},
    {'id': '2', 'name': 'Carmen López'},
    {'id': '3', 'name': 'José García'},
    {'id': '4', 'name': 'Ana Martínez'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedTimeRange = widget.selectedTimeRange;
    _selectedServiceType = widget.selectedServiceType;
    _selectedTeamMembers = List.from(widget.selectedTeamMembers);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Filtros del Dashboard',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time range filter
                    Text(
                      'Rango de tiempo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ..._timeRangeOptions.entries.map((entry) {
                      return _buildRadioOption(
                        entry.key,
                        entry.value,
                        _selectedTimeRange,
                        (value) {
                          setState(() {
                            _selectedTimeRange = value;
                          });
                        },
                      );
                    }).toList(),

                    SizedBox(height: 3.h),

                    // Service type filter
                    Text(
                      'Tipo de servicio',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ..._serviceTypeOptions.entries.map((entry) {
                      return _buildRadioOption(
                        entry.key,
                        entry.value,
                        _selectedServiceType,
                        (value) {
                          setState(() {
                            _selectedServiceType = value;
                          });
                        },
                      );
                    }).toList(),

                    SizedBox(height: 3.h),

                    // Team members filter
                    Text(
                      'Miembros del equipo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Selecciona los miembros a incluir en el análisis',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ..._teamMemberOptions.map((member) {
                      return _buildCheckboxOption(
                        member['id']!,
                        member['name']!,
                        _selectedTeamMembers.contains(member['id']),
                        (value, id) {
                          setState(() {
                            if (value) {
                              _selectedTeamMembers.add(id);
                            } else {
                              _selectedTeamMembers.remove(id);
                            }
                          });
                        },
                      );
                    }).toList(),

                    SizedBox(height: 2.h),

                    // Select/Deselect all buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTeamMembers = _teamMemberOptions
                                    .map((member) => member['id']!)
                                    .toList();
                              });
                            },
                            child: const Text('Seleccionar todos'),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTeamMembers.clear();
                              });
                            },
                            child: const Text('Deseleccionar todos'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      child: const Text('Resetear'),
                    ),
                  ),
                  SizedBox(width: 3.w),
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
      ),
    );
  }

  Widget _buildRadioOption(
    String value,
    String label,
    String selectedValue,
    Function(String) onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedValue == value;

    return Container(
      margin: EdgeInsets.only(bottom: 1.w),
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 3.w),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxOption(
    String id,
    String label,
    bool isSelected,
    Function(bool, String) onChanged,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 1.w),
      child: InkWell(
        onTap: () => onChanged(!isSelected, id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              Container(
                width: 5.w,
                height: 5.w,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 3.w,
                      )
                    : null,
              ),
              SizedBox(width: 3.w),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedTimeRange = 'week';
      _selectedServiceType = 'all';
      _selectedTeamMembers.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _selectedTimeRange,
      _selectedServiceType,
      _selectedTeamMembers,
    );
    Navigator.of(context).pop();
  }
}
