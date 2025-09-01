import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../models/tire_timing_model.dart';
import '../../../services/tire_timing_service.dart';

class VehicleConfigurationStep extends StatefulWidget {
  final Map<String, dynamic>? vehicleConfig;
  final Map<String, dynamic>? selectedService;
  final Function(Map<String, dynamic>) onConfigChanged;

  const VehicleConfigurationStep({
    super.key,
    this.vehicleConfig,
    this.selectedService,
    required this.onConfigChanged,
  });

  @override
  State<VehicleConfigurationStep> createState() =>
      _VehicleConfigurationStepState();
}

class _VehicleConfigurationStepState extends State<VehicleConfigurationStep> {
  late Map<String, dynamic> config;
  bool _isLoadingRecommendation = false;
  TireTiming? _currentRecommendation;
  bool _showTireRecommendations = false;

  @override
  void initState() {
    super.initState();
    config = widget.vehicleConfig ??
        {
          "vehicleType": "turismo",
          "wheelCount": 4,
          "punctureRepair": false,
          "balancing": false,
          "alignment": false,
          "useRecommendedTiming": false,
        };

    _checkIfTireService();
    if (_showTireRecommendations) {
      _loadTireRecommendation();
    }
  }

  void _checkIfTireService() {
    final serviceName =
        widget.selectedService?['name']?.toString().toLowerCase() ?? '';
    final serviceCategory =
        widget.selectedService?['category']?.toString().toLowerCase() ?? '';

    if (serviceName.contains('neumático') ||
        serviceName.contains('llanta') ||
        serviceName.contains('rueda') ||
        serviceCategory.contains('neumático')) {
      setState(() {
        _showTireRecommendations = true;
      });
    }
  }

  Future<void> _loadTireRecommendation() async {
    if (!_showTireRecommendations) return;

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final recommendation = await TireTimingService.instance
          .getTireTimingRecommendation(config["vehicleType"]);

      setState(() {
        _currentRecommendation = recommendation;
        _isLoadingRecommendation = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingRecommendation = false;
      });
      print('Error loading tire recommendation: $error');
    }
  }

  void _updateConfig(String key, dynamic value) {
    setState(() {
      config[key] = value;
    });

    // Reload recommendation when vehicle type changes
    if (key == "vehicleType" && _showTireRecommendations) {
      _loadTireRecommendation();
    }

    widget.onConfigChanged(config);
  }

  int _calculateTotalDuration() {
    if (_showTireRecommendations &&
        config["useRecommendedTiming"] == true &&
        _currentRecommendation != null) {
      final recommendedTime = _currentRecommendation!.getTimeForWheels(
        config["wheelCount"] as int,
        withBalancing: config["balancing"] as bool,
      );

      if (recommendedTime != null) {
        return recommendedTime.round();
      }
    }

    // Fallback to previous calculation method
    int baseDuration = 30;

    // Vehicle type multiplier
    switch (config["vehicleType"]) {
      case "turismo":
        baseDuration = 30;
        break;
      case "suv_4x4":
        baseDuration = 40;
        break;
      case "todoterreno_puro":
        baseDuration = 45;
        break;
      case "camion":
        baseDuration = 35;
        break;
      case "furgoneta_SRW":
      case "furgoneta_DRW":
        baseDuration = 40;
        break;
    }

    // Wheel count multiplier
    baseDuration = (baseDuration * (config["wheelCount"] as int) / 4).round();

    // Additional services
    if (config["punctureRepair"] as bool) baseDuration += 15;
    if (config["balancing"] as bool) baseDuration += 20;
    if (config["alignment"] as bool) baseDuration += 30;

    return baseDuration;
  }

  double _calculateTotalPrice() {
    double basePrice = 25.0;

    // Vehicle type multiplier
    switch (config["vehicleType"]) {
      case "turismo":
        basePrice = 25.0;
        break;
      case "suv_4x4":
        basePrice = 35.0;
        break;
      case "todoterreno_puro":
        basePrice = 40.0;
        break;
      case "camion":
        basePrice = 35.0;
        break;
      case "furgoneta_SRW":
        basePrice = 30.0;
        break;
      case "furgoneta_DRW":
        basePrice = 35.0;
        break;
    }

    // Wheel count multiplier
    basePrice = basePrice * (config["wheelCount"] as int) / 4;

    // Additional services
    if (config["punctureRepair"] as bool) basePrice += 15.0;
    if (config["balancing"] as bool) basePrice += 20.0;
    if (config["alignment"] as bool) basePrice += 35.0;

    return basePrice;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuración del Vehículo',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Personaliza el servicio según tu vehículo y necesidades',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehicleTypeSelector(),
                SizedBox(height: 3.h),
                _buildWheelCountSelector(),
                if (_showTireRecommendations) ...[
                  SizedBox(height: 3.h),
                  _buildTireRecommendationsSection(),
                ],
                SizedBox(height: 3.h),
                _buildAdditionalServices(),
                SizedBox(height: 3.h),
                _buildSummaryCard(),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeSelector() {
    final vehicleTypes =
        TireTimingService.instance.getVehicleTypesWithDisplayNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Vehículo',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: vehicleTypes.entries.map((entry) {
            final isSelected = config["vehicleType"] == entry.key;
            return GestureDetector(
              onTap: () => _updateConfig("vehicleType", entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  entry.value,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWheelCountSelector() {
    final maxWheels = TireTimingService.instance
        .getMaxWheelCountForVehicleType(config["vehicleType"]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Número de Ruedas',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ruedas a cambiar',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: config["wheelCount"] > 1
                        ? () => _updateConfig(
                            "wheelCount", config["wheelCount"] - 1)
                        : null,
                    icon: CustomIconWidget(
                      iconName: 'remove_circle_outline',
                      color: config["wheelCount"] > 1
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                      size: 6.w,
                    ),
                  ),
                  Container(
                    width: 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${config["wheelCount"]}',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: config["wheelCount"] < maxWheels
                        ? () => _updateConfig(
                            "wheelCount", config["wheelCount"] + 1)
                        : null,
                    icon: CustomIconWidget(
                      iconName: 'add_circle_outline',
                      color: config["wheelCount"] < maxWheels
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (maxWheels > 4) ...[
          SizedBox(height: 1.h),
          Text(
            'Este tipo de vehículo soporta hasta $maxWheels ruedas',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTireRecommendationsSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Recomendaciones de Timing',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SwitchListTile(
            title: Text(
              'Usar tiempos recomendados',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Aplicar tiempos basados en tipo de vehículo y número de ruedas',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            value: config["useRecommendedTiming"] ?? false,
            onChanged: (value) {
              _updateConfig("useRecommendedTiming", value);
            },
            activeColor: AppTheme.lightTheme.colorScheme.primary,
            contentPadding: EdgeInsets.zero,
          ),
          if (_isLoadingRecommendation) ...[
            SizedBox(height: 2.h),
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ],
          if (!_isLoadingRecommendation &&
              config["useRecommendedTiming"] == true &&
              _currentRecommendation != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentRecommendation!.description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Tiempo recomendado: ${_calculateTotalDuration()} min',
                        style:
                            AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme
                              .lightTheme.colorScheme.onSecondaryContainer,
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
    );
  }

  Widget _buildAdditionalServices() {
    final supportsBalancing =
        TireTimingService.instance.supportsBalancing(config["vehicleType"]);

    final services = [
      {
        "key": "punctureRepair",
        "title": "Reparación de Pinchazos",
        "description": "Incluir reparación de pinchazos existentes",
        "icon": "build",
        "price": 15.0,
        "enabled": true,
      },
      {
        "key": "balancing",
        "title": "Balanceado de Ruedas",
        "description": "Balanceado preciso para mejor rendimiento",
        "icon": "settings",
        "price": 20.0,
        "enabled": supportsBalancing,
      },
      {
        "key": "alignment",
        "title": "Alineación de Dirección",
        "description": "Alineación completa del sistema",
        "icon": "straighten",
        "price": 35.0,
        "enabled": true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios Adicionales',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        ...services
            .where((service) => service["enabled"] == true)
            .map((service) => _buildServiceToggle(service)),
      ],
    );
  }

  Widget _buildServiceToggle(Map<String, dynamic> service) {
    final isEnabled = config[service["key"]] as bool;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: service["icon"] as String,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service["title"] as String,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  service["description"] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '+€${(service["price"] as double).toStringAsFixed(2)}',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) =>
                _updateConfig(service["key"] as String, value),
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final duration = _calculateTotalDuration();
    final price = _calculateTotalPrice();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen de Configuración',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duración Estimada',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$duration minutos',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  if (config["useRecommendedTiming"] == true)
                    Text(
                      'Tiempo recomendado',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Precio Total',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '€${price.toStringAsFixed(2)}',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
