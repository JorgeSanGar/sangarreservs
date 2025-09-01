import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ServiceSelectionStep extends StatefulWidget {
  final Map<String, dynamic>? selectedService;
  final Function(Map<String, dynamic>) onServiceSelected;

  const ServiceSelectionStep({
    super.key,
    this.selectedService,
    required this.onServiceSelected,
  });

  @override
  State<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends State<ServiceSelectionStep> {
  final List<Map<String, dynamic>> services = [
    {
      "id": 1,
      "name": "Cambio de Neumáticos",
      "category": "Instalación",
      "description": "Cambio completo de neumáticos con balanceado incluido",
      "baseDuration": 45,
      "price": 25.0,
      "icon": "tire_repair",
      "color": 0xFF2563EB,
      "supportsTireRecommendations": true,
    },
    {
      "id": 2,
      "name": "Reparación de Pinchazos",
      "category": "Reparación",
      "description": "Reparación profesional de pinchazos y parches",
      "baseDuration": 20,
      "price": 15.0,
      "icon": "build",
      "color": 0xFF059669,
    },
    {
      "id": 3,
      "name": "Balanceado de Ruedas",
      "category": "Mantenimiento",
      "description": "Balanceado preciso para mejor rendimiento",
      "baseDuration": 30,
      "price": 20.0,
      "icon": "settings",
      "color": 0xFFD97706,
    },
    {
      "id": 4,
      "name": "Alineación de Dirección",
      "category": "Mantenimiento",
      "description": "Alineación completa del sistema de dirección",
      "baseDuration": 60,
      "price": 35.0,
      "icon": "straighten",
      "color": 0xFFDC2626,
    },
    {
      "id": 5,
      "name": "Rotación de Neumáticos",
      "category": "Mantenimiento",
      "description": "Rotación para desgaste uniforme",
      "baseDuration": 25,
      "price": 12.0,
      "icon": "rotate_right",
      "color": 0xFF7C3AED,
      "supportsTireRecommendations": true,
    },
    {
      "id": 6,
      "name": "Inspección Completa",
      "category": "Diagnóstico",
      "description": "Revisión completa del estado de los neumáticos",
      "baseDuration": 15,
      "price": 8.0,
      "icon": "search",
      "color": 0xFF0891B2,
    },
  ];

  Map<String, List<Map<String, dynamic>>> get groupedServices {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final service in services) {
      final category = service["category"] as String;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(service);
    }
    return grouped;
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
                'Selecciona el Servicio',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Elige el tipo de servicio que necesitas para tu vehículo',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: groupedServices.keys.length,
            itemBuilder: (context, index) {
              final category = groupedServices.keys.elementAt(index);
              final categoryServices = groupedServices[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0) SizedBox(height: 3.h),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Text(
                      category,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ...categoryServices
                      .map((service) => _buildServiceCard(service)),
                  if (index == groupedServices.keys.length - 1)
                    SizedBox(height: 2.h),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isSelected = widget.selectedService?["id"] == service["id"];
    final supportsTireRecommendations =
        service["supportsTireRecommendations"] == true;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onServiceSelected(service),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primaryContainer
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color:
                        Color(service["color"] as int).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: service["icon"] as String,
                      color: Color(service["color"] as int),
                      size: 6.w,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              service["name"] as String,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (supportsTireRecommendations)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: AppTheme
                                    .lightTheme.colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'auto_awesome',
                                    color: AppTheme
                                        .lightTheme.colorScheme.secondary,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    'Timing',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme
                                          .lightTheme.colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        service["description"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${service["baseDuration"]} min',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '€${(service["price"] as double).toStringAsFixed(2)}',
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 4.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
