import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class WorkingHoursWidget extends StatefulWidget {
  final Map<String, dynamic> workingHours;
  final Function(Map<String, dynamic>) onHoursChanged;

  const WorkingHoursWidget({
    super.key,
    required this.workingHours,
    required this.onHoursChanged,
  });

  @override
  State<WorkingHoursWidget> createState() => _WorkingHoursWidgetState();
}

class _WorkingHoursWidgetState extends State<WorkingHoursWidget> {
  late Map<String, dynamic> _hours;

  final List<String> _weekDays = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  final Map<String, String> _dayLabels = {
    'monday': 'Lunes',
    'tuesday': 'Martes',
    'wednesday': 'Miércoles',
    'thursday': 'Jueves',
    'friday': 'Viernes',
    'saturday': 'Sábado',
    'sunday': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _hours = Map<String, dynamic>.from(widget.workingHours);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Horario de trabajo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Configura los horarios de apertura y cierre',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Weekly schedule
        ...(_weekDays.map((day) => _buildDaySchedule(day)).toList()),

        SizedBox(height: 3.h),

        // Break times section
        _buildBreakTimesSection(),

        SizedBox(height: 3.h),

        // Blackout dates section
        _buildBlackoutDatesSection(),
      ],
    );
  }

  Widget _buildDaySchedule(String day) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dayData = _hours[day] as Map<String, dynamic>? ?? {};
    final isEnabled = dayData['enabled'] as bool? ?? true;
    final startTime = dayData['start'] as String? ?? '08:00';
    final endTime = dayData['end'] as String? ?? '18:00';

    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Day header with toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    _dayLabels[day] ?? day,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Switch(
                  value: isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _hours[day] = {
                        ...dayData,
                        'enabled': value,
                      };
                    });
                    widget.onHoursChanged(_hours);
                  },
                ),
              ],
            ),

            if (isEnabled) ...[
              SizedBox(height: 2.h),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      'Apertura',
                      startTime,
                      (time) {
                        setState(() {
                          _hours[day] = {
                            ...dayData,
                            'start': time,
                          };
                        });
                        widget.onHoursChanged(_hours);
                      },
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: _buildTimePicker(
                      'Cierre',
                      endTime,
                      (time) {
                        setState(() {
                          _hours[day] = {
                            ...dayData,
                            'end': time,
                          };
                        });
                        widget.onHoursChanged(_hours);
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 1.h),
              Text(
                'Cerrado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
      String label, String time, Function(String) onChanged) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () async {
        final timeParts = time.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );

        final selectedTime = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (selectedTime != null) {
          final formattedTime =
              '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
          onChanged(formattedTime);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  time,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakTimesSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final breaks = (_hours['breaks'] as List<dynamic>?) ?? [];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'coffee',
                  color: colorScheme.secondary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Descansos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addBreakTime,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            if (breaks.isEmpty) ...[
              SizedBox(height: 2.h),
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 8.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No hay descansos configurados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 2.h),
              ...(breaks.asMap().entries.map((entry) {
                final index = entry.key;
                final breakData = entry.value as Map<String, dynamic>;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${breakData['start']} - ${breakData['end']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        breakData['name'] as String? ?? 'Descanso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      IconButton(
                        onPressed: () => _removeBreakTime(index),
                        icon: CustomIconWidget(
                          iconName: 'delete',
                          color: colorScheme.error,
                          size: 4.w,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBlackoutDatesSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final blackoutDates = (_hours['blackoutDates'] as List<dynamic>?) ?? [];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'event_busy',
                  color: colorScheme.error,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Fechas no laborables',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addBlackoutDate,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: colorScheme.primary,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            if (blackoutDates.isEmpty) ...[
              SizedBox(height: 2.h),
              Center(
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'event_available',
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 8.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No hay fechas bloqueadas',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 2.h),
              ...(blackoutDates.asMap().entries.map((entry) {
                final index = entry.key;
                final dateData = entry.value as Map<String, dynamic>;

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: colorScheme.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'event_busy',
                        color: colorScheme.error,
                        size: 4.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateData['name'] as String? ?? 'Fecha bloqueada',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              dateData['date'] as String? ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeBlackoutDate(index),
                        icon: CustomIconWidget(
                          iconName: 'delete',
                          color: colorScheme.error,
                          size: 4.w,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  void _addBreakTime() {
    showDialog(
      context: context,
      builder: (context) => _BreakTimeDialog(
        onSave: (breakData) {
          setState(() {
            final breaks = (_hours['breaks'] as List<dynamic>?) ?? [];
            breaks.add(breakData);
            _hours['breaks'] = breaks;
          });
          widget.onHoursChanged(_hours);
        },
      ),
    );
  }

  void _removeBreakTime(int index) {
    setState(() {
      final breaks = (_hours['breaks'] as List<dynamic>?) ?? [];
      breaks.removeAt(index);
      _hours['breaks'] = breaks;
    });
    widget.onHoursChanged(_hours);
  }

  void _addBlackoutDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _showBlackoutDateDialog(selectedDate);
      }
    });
  }

  void _showBlackoutDateDialog(DateTime date) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fecha no laborable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Fecha: ${date.day}/${date.month}/${date.year}'),
            SizedBox(height: 2.h),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Ej: Vacaciones, Mantenimiento',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final blackoutData = {
                'date': '${date.day}/${date.month}/${date.year}',
                'name': nameController.text.trim().isEmpty
                    ? 'Fecha bloqueada'
                    : nameController.text.trim(),
                'timestamp': date.millisecondsSinceEpoch,
              };

              setState(() {
                final blackoutDates =
                    (_hours['blackoutDates'] as List<dynamic>?) ?? [];
                blackoutDates.add(blackoutData);
                _hours['blackoutDates'] = blackoutDates;
              });
              widget.onHoursChanged(_hours);
              Navigator.of(context).pop();
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _removeBlackoutDate(int index) {
    setState(() {
      final blackoutDates = (_hours['blackoutDates'] as List<dynamic>?) ?? [];
      blackoutDates.removeAt(index);
      _hours['blackoutDates'] = blackoutDates;
    });
    widget.onHoursChanged(_hours);
  }
}

class _BreakTimeDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const _BreakTimeDialog({required this.onSave});

  @override
  State<_BreakTimeDialog> createState() => _BreakTimeDialogState();
}

class _BreakTimeDialogState extends State<_BreakTimeDialog> {
  final _nameController = TextEditingController();
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 13, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo descanso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del descanso',
              hintText: 'Ej: Almuerzo, Descanso',
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: _buildTimeSelector('Inicio', _startTime, (time) {
                  setState(() => _startTime = time);
                }),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: _buildTimeSelector('Fin', _endTime, (time) {
                  setState(() => _endTime = time);
                }),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final breakData = {
              'name': _nameController.text.trim().isEmpty
                  ? 'Descanso'
                  : _nameController.text.trim(),
              'start':
                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
              'end':
                  '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
            };

            widget.onSave(breakData);
            Navigator.of(context).pop();
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return MediaQuery(
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          },
        );

        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
