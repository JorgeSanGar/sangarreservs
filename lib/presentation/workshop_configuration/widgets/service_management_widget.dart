import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceManagementWidget extends StatefulWidget {
  final List<Map<String, dynamic>> services;
  final Function(List<Map<String, dynamic>>) onServicesChanged;

  const ServiceManagementWidget({
    super.key,
    required this.services,
    required this.onServicesChanged,
  });

  @override
  State<ServiceManagementWidget> createState() =>
      _ServiceManagementWidgetState();
}

class _ServiceManagementWidgetState extends State<ServiceManagementWidget> {
  String _selectedCategory = 'all';
  final List<String> _categories = [
    'all',
    'tire_change',
    'balancing',
    'alignment',
    'repair',
    'maintenance'
  ];

  final Map<String, String> _categoryLabels = {
    'all': 'Todos',
    'tire_change': 'Cambio de neumáticos',
    'balancing': 'Balanceado',
    'alignment': 'Alineación',
    'repair': 'Reparación',
    'maintenance': 'Mantenimiento',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredServices = _getFilteredServices();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with add button
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'build',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo de servicios',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Gestiona los servicios disponibles',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addNewService,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 4.w,
                ),
                label: const Text('Nuevo'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Category filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(_categoryLabels[category] ?? category),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 3.h),

        // Services list
        if (filteredServices.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          ...filteredServices
              .map((service) => _buildServiceCard(service))
              .toList(),
        ],
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredServices() {
    if (_selectedCategory == 'all') {
      return widget.services;
    }

    return widget.services.where((service) {
      return (service['category'] as String?) == _selectedCategory;
    }).toList();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'build',
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            _selectedCategory == 'all'
                ? 'No hay servicios configurados'
                : 'No hay servicios en esta categoría',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Agrega servicios para comenzar a gestionar tu taller',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _addNewService,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 4.w,
            ),
            label: const Text('Agregar primer servicio'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = service['isActive'] as bool? ?? true;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: () => _editService(service),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Service icon
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                              service['category'] as String? ?? 'maintenance')
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: _getCategoryIcon(
                            service['category'] as String? ?? 'maintenance'),
                        color: _getCategoryColor(
                            service['category'] as String? ?? 'maintenance'),
                        size: 5.w,
                      ),
                    ),
                  ),

                  SizedBox(width: 3.w),

                  // Service info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['name'] as String? ?? 'Servicio sin nombre',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _categoryLabels[service['category'] as String? ??
                                  'maintenance'] ??
                              'Categoría',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status indicator
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isActive ? 'Activo' : 'Inactivo',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Service details
              Row(
                children: [
                  // Duration
                  Expanded(
                    child: _buildDetailItem(
                      'Duración',
                      '${service['baseDuration'] ?? 60} min',
                      'schedule',
                      colorScheme.primary,
                    ),
                  ),

                  // Price
                  Expanded(
                    child: _buildDetailItem(
                      'Precio',
                      '€${service['price'] ?? '0.00'}',
                      'euro',
                      colorScheme.tertiary,
                    ),
                  ),

                  // Buffer time
                  Expanded(
                    child: _buildDetailItem(
                      'Buffer',
                      '${service['bufferTime'] ?? 15} min',
                      'timer',
                      colorScheme.secondary,
                    ),
                  ),
                ],
              ),

              if (service['description'] != null &&
                  (service['description'] as String).isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  service['description'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, String iconName, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: color,
          size: 4.w,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tire_change':
        return 'tire_repair';
      case 'balancing':
        return 'balance';
      case 'alignment':
        return 'straighten';
      case 'repair':
        return 'build';
      case 'maintenance':
        return 'settings';
      default:
        return 'build';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'tire_change':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'balancing':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'alignment':
        return AppTheme.warningLight;
      case 'repair':
        return AppTheme.errorLight;
      case 'maintenance':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  void _addNewService() {
    showDialog(
      context: context,
      builder: (context) => _ServiceEditorDialog(
        onSave: (serviceData) {
          final updatedServices = [...widget.services, serviceData];
          widget.onServicesChanged(updatedServices);
        },
      ),
    );
  }

  void _editService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceEditorDialog(
        service: service,
        onSave: (serviceData) {
          final updatedServices = widget.services.map((s) {
            return s['id'] == serviceData['id'] ? serviceData : s;
          }).toList();
          widget.onServicesChanged(updatedServices);
        },
      ),
    );
  }
}

class _ServiceEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? service;
  final Function(Map<String, dynamic>) onSave;

  const _ServiceEditorDialog({
    this.service,
    required this.onSave,
  });

  @override
  State<_ServiceEditorDialog> createState() => _ServiceEditorDialogState();
}

class _ServiceEditorDialogState extends State<_ServiceEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'tire_change';
  int _baseDuration = 60;
  int _bufferTime = 15;
  bool _isActive = true;

  final Map<String, String> _categoryLabels = {
    'tire_change': 'Cambio de neumáticos',
    'balancing': 'Balanceado',
    'alignment': 'Alineación',
    'repair': 'Reparación',
    'maintenance': 'Mantenimiento',
  };

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!['name'] as String? ?? '';
      _descriptionController.text =
          widget.service!['description'] as String? ?? '';
      _priceController.text =
          (widget.service!['price'] as num?)?.toString() ?? '0.00';
      _selectedCategory =
          widget.service!['category'] as String? ?? 'tire_change';
      _baseDuration = widget.service!['baseDuration'] as int? ?? 60;
      _bufferTime = widget.service!['bufferTime'] as int? ?? 15;
      _isActive = widget.service!['isActive'] as bool? ?? true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.service != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 90.w,
          maxHeight: 85.h,
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
                      isEditing ? 'Editar Servicio' : 'Nuevo Servicio',
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
                          labelText: 'Nombre del servicio',
                          hintText: 'Ej: Cambio de 4 neumáticos',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Category selector
                      Text(
                        'Categoría',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: _categoryLabels.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Price field
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Precio (€)',
                          hintText: '0.00',
                          prefixText: '€ ',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El precio es obligatorio';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Ingresa un precio válido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Duration sliders
                      Text(
                        'Duración base: $_baseDuration minutos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Slider(
                        value: _baseDuration.toDouble(),
                        min: 15,
                        max: 240,
                        divisions: 15,
                        label: '$_baseDuration min',
                        onChanged: (value) {
                          setState(() => _baseDuration = value.round());
                        },
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        'Tiempo de buffer: $_bufferTime minutos',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      Slider(
                        value: _bufferTime.toDouble(),
                        min: 0,
                        max: 60,
                        divisions: 12,
                        label: '$_bufferTime min',
                        onChanged: (value) {
                          setState(() => _bufferTime = value.round());
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción (opcional)',
                          hintText: 'Detalles adicionales del servicio',
                        ),
                        maxLines: 3,
                      ),

                      SizedBox(height: 3.h),

                      // Active status
                      SwitchListTile(
                        title: Text(
                          'Servicio activo',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _isActive
                              ? 'El servicio está disponible para reservas'
                              : 'El servicio no está disponible',
                          style: theme.textTheme.bodySmall,
                        ),
                        value: _isActive,
                        onChanged: (value) => setState(() => _isActive = value),
                        contentPadding: EdgeInsets.zero,
                      ),
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
                      onPressed: _saveService,
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

  void _saveService() {
    if (!_formKey.currentState!.validate()) return;

    final serviceData = {
      'id': widget.service?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'baseDuration': _baseDuration,
      'bufferTime': _bufferTime,
      'isActive': _isActive,
      'createdAt':
          widget.service?['createdAt'] ?? DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    widget.onSave(serviceData);
    Navigator.of(context).pop();
  }
}
