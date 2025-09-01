import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../models/tire_timing_model.dart';

class AddServiceModalWidget extends StatefulWidget {
  final Map<String, dynamic>? service;
  final List<Map<String, dynamic>> categories;
  final ValueChanged<Map<String, dynamic>> onSave;

  const AddServiceModalWidget({
    super.key,
    this.service,
    required this.categories,
    required this.onSave,
  });

  @override
  State<AddServiceModalWidget> createState() => _AddServiceModalWidgetState();
}

class _AddServiceModalWidgetState extends State<AddServiceModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '';
  int _duration = 30;
  int _bufferTime = 5;
  bool _isActive = true;
  String _skillRequired = 'basic';
  String _equipment = 'standard';
  bool _seasonalAvailable = true;
  bool _showAdvanced = false;
  bool _showTireRecommendations = false;

  // Tire service specific fields
  String _selectedVehicleType = 'turismo';
  int _selectedWheelCount = 1;
  bool _withBalancing = false;
  bool _useRecommendedTiming = false;

  final List<String> _skillLevels = ['basic', 'intermediate', 'advanced'];
  final List<String> _equipmentTypes = [
    'standard',
    'specialized',
    'balancer',
    'alignment_rack',
    'repair_tools',
    'precision_balancer'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _populateFields();
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first['id'];
    }
    _checkIfTireService();
  }

  void _populateFields() {
    final service = widget.service!;
    _nameController.text = service['name'] ?? '';
    _priceController.text = service['price']?.toString() ?? '';
    _descriptionController.text = service['description'] ?? '';
    _selectedCategory = service['categoryId'] ?? '';
    _duration = service['duration'] ?? 30;
    _bufferTime = service['bufferTime'] ?? 5;
    _isActive = service['isActive'] ?? true;
    _skillRequired = service['skillRequired'] ?? 'basic';
    _equipment = service['equipment'] ?? 'standard';
    _seasonalAvailable = service['seasonalAvailable'] ?? true;

    // Tire service specific fields
    _selectedVehicleType = service['vehicleType'] ?? 'turismo';
    _selectedWheelCount = service['wheelCount'] ?? 1;
    _withBalancing = service['withBalancing'] ?? false;
    _useRecommendedTiming = service['useRecommendedTiming'] ?? false;
  }

  void _checkIfTireService() {
    final categoryName = widget.categories.firstWhere(
        (cat) => cat['id'] == _selectedCategory,
        orElse: () => {})['name'];

    if (categoryName?.toLowerCase().contains('neumático') == true ||
        categoryName?.toLowerCase().contains('llanta') == true ||
        categoryName?.toLowerCase().contains('rueda') == true) {
      setState(() {
        _showTireRecommendations = true;
      });
    }
  }

  void _updateTimingFromRecommendation() {
    if (!_useRecommendedTiming) return;

    final recommendation =
        TireTimingRecommendations.getRecommendationForVehicle(
            _selectedVehicleType);
    if (recommendation != null) {
      final recommendedTime = recommendation
          .getTimeForWheels(_selectedWheelCount, withBalancing: _withBalancing);
      if (recommendedTime != null) {
        setState(() {
          _duration = recommendedTime.round();
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveService() {
    if (_formKey.currentState?.validate() ?? false) {
      final serviceData = {
        'id': widget.service?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategory,
        'duration': _duration,
        'bufferTime': _bufferTime,
        'isActive': _isActive,
        'skillRequired': _skillRequired,
        'equipment': _equipment,
        'seasonalAvailable': _seasonalAvailable,
        'createdAt':
            widget.service?['createdAt'] ?? DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        // Tire service specific data
        if (_showTireRecommendations) ...{
          'vehicleType': _selectedVehicleType,
          'wheelCount': _selectedWheelCount,
          'withBalancing': _withBalancing,
          'useRecommendedTiming': _useRecommendedTiming,
        },
      };

      widget.onSave(serviceData);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 10.w,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.service == null
                            ? 'Nuevo Servicio'
                            : 'Editar Servicio',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    children: [
                      // Basic Information
                      _buildSectionTitle('Información Básica'),
                      SizedBox(height: 2.h),

                      // Service Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Servicio',
                          hintText: 'Ej. Instalación Estándar',
                        ),
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'El nombre es requerido';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Category Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedCategory.isNotEmpty
                            ? _selectedCategory
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                        ),
                        items: widget.categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category['id'],
                            child: Row(
                              children: [
                                Icon(
                                  category['icon'],
                                  size: 18,
                                  color: category['color'],
                                ),
                                SizedBox(width: 2.w),
                                Text(category['name']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                            _checkIfTireService();
                          });
                        },
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Seleccione una categoría';
                          }
                          return null;
                        },
                      ),

                      // Tire Service Recommendations Section
                      if (_showTireRecommendations) ...[
                        SizedBox(height: 3.h),
                        _buildTireRecommendationsSection(),
                      ],

                      SizedBox(height: 2.h),

                      // Duration and Price Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildDurationPicker(),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: InputDecoration(
                                labelText: 'Precio (EUR)',
                                prefixText: '€',
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value?.trim().isEmpty ?? true) {
                                  return 'Precio requerido';
                                }
                                final price = double.tryParse(value!);
                                if (price == null || price <= 0) {
                                  return 'Precio inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción (Opcional)',
                          hintText: 'Detalles adicionales del servicio...',
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Advanced Options Toggle
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showAdvanced = !_showAdvanced;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              _showAdvanced
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Opciones Avanzadas',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_showAdvanced) ...[
                        SizedBox(height: 3.h),

                        // Buffer Time
                        _buildBufferTimePicker(),

                        SizedBox(height: 2.h),

                        // Skill Level
                        DropdownButtonFormField<String>(
                          value: _skillRequired,
                          decoration: InputDecoration(
                            labelText: 'Nivel de Habilidad Requerido',
                          ),
                          items: _skillLevels.map((skill) {
                            return DropdownMenuItem<String>(
                              value: skill,
                              child: Text(_getSkillLabel(skill)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _skillRequired = value ?? 'basic';
                            });
                          },
                        ),

                        SizedBox(height: 2.h),

                        // Equipment Required
                        DropdownButtonFormField<String>(
                          value: _equipment,
                          decoration: InputDecoration(
                            labelText: 'Equipo Requerido',
                          ),
                          items: _equipmentTypes.map((equipment) {
                            return DropdownMenuItem<String>(
                              value: equipment,
                              child: Text(_getEquipmentLabel(equipment)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _equipment = value ?? 'standard';
                            });
                          },
                        ),

                        SizedBox(height: 2.h),

                        // Switches
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(
                                  'Servicio Activo',
                                  style: GoogleFonts.inter(fontSize: 14.sp),
                                ),
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                activeColor: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        SwitchListTile(
                          title: Text(
                            'Disponible Todo el Año',
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                          subtitle: Text(
                            'Desactivar para servicios estacionales',
                            style: GoogleFonts.inter(fontSize: 12.sp),
                          ),
                          value: _seasonalAvailable,
                          onChanged: (value) {
                            setState(() {
                              _seasonalAvailable = value;
                            });
                          },
                          activeColor: colorScheme.primary,
                        ),
                      ],

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar'),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveService,
                        child: Text(
                          widget.service == null
                              ? 'Crear Servicio'
                              : 'Guardar Cambios',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTireRecommendationsSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recomendaciones de Timing',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Use recommendations toggle
          SwitchListTile(
            title: Text(
              'Usar tiempos recomendados',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            subtitle: Text(
              'Aplicar tiempos basados en tipo de vehículo y número de ruedas',
              style: GoogleFonts.inter(fontSize: 12.sp),
            ),
            value: _useRecommendedTiming,
            onChanged: (value) {
              setState(() {
                _useRecommendedTiming = value;
                if (value) {
                  _updateTimingFromRecommendation();
                }
              });
            },
            activeColor: colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),

          if (_useRecommendedTiming) ...[
            SizedBox(height: 2.h),

            // Vehicle Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedVehicleType,
              decoration: InputDecoration(
                labelText: 'Tipo de Vehículo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              items: TireTimingRecommendations.getVehicleTypes()
                  .map((vehicleType) {
                return DropdownMenuItem<String>(
                  value: vehicleType,
                  child: Text(TireTimingRecommendations.getVehicleDisplayName(
                      vehicleType)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value ?? 'turismo';
                  _updateTimingFromRecommendation();
                });
              },
            ),

            SizedBox(height: 2.h),

            // Wheel Count Dropdown
            DropdownButtonFormField<int>(
              value: _selectedWheelCount,
              decoration: InputDecoration(
                labelText: 'Número de Ruedas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              items: TireTimingRecommendations.getRecommendationForVehicle(
                          _selectedVehicleType)
                      ?.getAvailableWheelCounts()
                      .map((wheelCount) {
                    return DropdownMenuItem<int>(
                      value: wheelCount,
                      child:
                          Text('$wheelCount rueda${wheelCount > 1 ? 's' : ''}'),
                    );
                  }).toList() ??
                  [],
              onChanged: (value) {
                setState(() {
                  _selectedWheelCount = value ?? 1;
                  _updateTimingFromRecommendation();
                });
              },
            ),

            // Balancing option if available
            if (TireTimingRecommendations.getRecommendationForVehicle(
                        _selectedVehicleType)
                    ?.hasBalancingOption() ==
                true) ...[
              SizedBox(height: 2.h),
              SwitchListTile(
                title: Text(
                  'Con Equilibrado Delanteras',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                subtitle: Text(
                  'Incluir tiempo adicional para equilibrado',
                  style: GoogleFonts.inter(fontSize: 12.sp),
                ),
                value: _withBalancing,
                onChanged: (value) {
                  setState(() {
                    _withBalancing = value;
                    _updateTimingFromRecommendation();
                  });
                },
                activeColor: colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
            ],

            SizedBox(height: 2.h),

            // Show recommended time
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Tiempo recomendado: $_duration min',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duración: $_duration min',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (_useRecommendedTiming)
          Text(
            'Tiempo basado en recomendación',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        SizedBox(height: 1.h),
        Slider(
          value: _duration.toDouble(),
          min: 15,
          max: 150,
          divisions: 27,
          label: '$_duration min',
          onChanged: _useRecommendedTiming
              ? null // Disable manual adjustment when using recommendations
              : (value) {
                  setState(() {
                    _duration = value.round();
                  });
                },
        ),
      ],
    );
  }

  Widget _buildBufferTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tiempo de Buffer: $_bufferTime min',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          'Tiempo adicional entre citas',
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _bufferTime.toDouble(),
          min: 0,
          max: 30,
          divisions: 6, // 0, 5, 10, 15, 20, 25, 30
          label: '$_bufferTime min',
          onChanged: (value) {
            setState(() {
              _bufferTime = value.round();
            });
          },
        ),
      ],
    );
  }

  String _getSkillLabel(String skill) {
    switch (skill) {
      case 'basic':
        return 'Básico';
      case 'intermediate':
        return 'Intermedio';
      case 'advanced':
        return 'Avanzado';
      default:
        return skill;
    }
  }

  String _getEquipmentLabel(String equipment) {
    switch (equipment) {
      case 'standard':
        return 'Estándar';
      case 'specialized':
        return 'Especializado';
      case 'balancer':
        return 'Balanceadora';
      case 'alignment_rack':
        return 'Banco de Alineación';
      case 'repair_tools':
        return 'Herramientas de Reparación';
      case 'precision_balancer':
        return 'Balanceadora de Precisión';
      default:
        return equipment;
    }
  }
}
