import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ResourceEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? resource;
  final Function(Map<String, dynamic>) onSave;

  const ResourceEditorDialog({
    super.key,
    this.resource,
    required this.onSave,
  });

  @override
  State<ResourceEditorDialog> createState() => _ResourceEditorDialogState();
}

class _ResourceEditorDialogState extends State<ResourceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'bay';
  bool _isActive = true;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _hasCustomHours = false;

  final List<String> _resourceTypes = ['bay', 'elevator', 'equipment', 'tool'];

  @override
  void initState() {
    super.initState();
    if (widget.resource != null) {
      _nameController.text = widget.resource!['name'] as String? ?? '';
      _descriptionController.text =
          widget.resource!['description'] as String? ?? '';
      _selectedType = widget.resource!['type'] as String? ?? 'bay';
      _isActive = widget.resource!['isActive'] as bool? ?? true;
      _hasCustomHours = widget.resource!['hasCustomHours'] as bool? ?? false;

      if (widget.resource!['startTime'] != null) {
        final startParts = (widget.resource!['startTime'] as String).split(':');
        _startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
      }

      if (widget.resource!['endTime'] != null) {
        final endParts = (widget.resource!['endTime'] as String).split(':');
        _endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.resource != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 80.h,
        ),
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
                    iconName: isEditing ? 'edit' : 'add',
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      isEditing ? 'Editar Recurso' : 'Nuevo Recurso',
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

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del recurso',
                          hintText: 'Ej: Bahía 1, Elevador Principal',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Type selector
                      Text(
                        'Tipo de recurso',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: _resourceTypes.map((type) {
                          final isSelected = _selectedType == type;
                          return FilterChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: _getResourceIcon(type),
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.primary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 2.w),
                                Text(_getResourceTypeLabel(type)),
                              ],
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedType = type);
                              }
                            },
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 3.h),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          hintText: 'Detalles adicionales sobre el recurso',
                        ),
                        maxLines: 3,
                      ),

                      SizedBox(height: 3.h),

                      // Active status
                      SwitchListTile(
                        title: Text(
                          'Recurso activo',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _isActive
                              ? 'El recurso está disponible para reservas'
                              : 'El recurso no está disponible',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        contentPadding: EdgeInsets.zero,
                      ),

                      SizedBox(height: 2.h),

                      // Custom hours
                      SwitchListTile(
                        title: Text(
                          'Horario personalizado',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _hasCustomHours
                              ? 'Usar horario específico para este recurso'
                              : 'Usar horario general del taller',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _hasCustomHours,
                        onChanged: (value) =>
                            setState(() => _hasCustomHours = value),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (_hasCustomHours) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTimeField(
                                'Hora inicio',
                                _startTime,
                                (time) => setState(() => _startTime = time),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: _buildTimeField(
                                'Hora fin',
                                _endTime,
                                (time) => setState(() => _endTime = time),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
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
                      onPressed: _saveResource,
                      child: Text(isEditing ? 'Guardar' : 'Crear'),
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

  Widget _buildTimeField(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    final theme = Theme.of(context);

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 0.5.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: theme.colorScheme.primary,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium?.copyWith(
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

  void _saveResource() {
    if (!_formKey.currentState!.validate()) return;

    final resourceData = {
      'id': widget.resource?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _selectedType,
      'isActive': _isActive,
      'hasCustomHours': _hasCustomHours,
      'startTime': _hasCustomHours
          ? '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}'
          : null,
      'endTime': _hasCustomHours
          ? '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}'
          : null,
      'createdAt':
          widget.resource?['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    widget.onSave(resourceData);
    Navigator.of(context).pop();
  }

  String _getResourceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bay':
        return 'garage';
      case 'elevator':
        return 'elevator';
      case 'equipment':
        return 'build';
      case 'tool':
        return 'handyman';
      default:
        return 'settings';
    }
  }

  String _getResourceTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'bay':
        return 'Bahía';
      case 'elevator':
        return 'Elevador';
      case 'equipment':
        return 'Equipo';
      case 'tool':
        return 'Herramienta';
      default:
        return 'Recurso';
    }
  }
}
