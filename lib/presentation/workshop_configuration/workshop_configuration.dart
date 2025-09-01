import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/workshop_service.dart';
import '../../services/role_service.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/role_based_navigation_bar.dart';
import './widgets/resource_card_widget.dart';
import './widgets/resource_editor_dialog.dart';
import './widgets/service_management_widget.dart';
import './widgets/team_management_widget.dart';
import './widgets/working_hours_widget.dart';

class WorkshopConfiguration extends StatefulWidget {
  const WorkshopConfiguration({super.key});

  @override
  State<WorkshopConfiguration> createState() => _WorkshopConfigurationState();
}

class _WorkshopConfigurationState extends State<WorkshopConfiguration>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Replace mock data with Supabase data
  List<Map<String, dynamic>> _resources = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _teamMembers = [];
  Map<String, dynamic> _workingHours = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWorkshopData();
  }

  /// Load all workshop data from Supabase
  Future<void> _loadWorkshopData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workshopService = WorkshopService.instance;

      // Load data in parallel
      final results = await Future.wait([
        workshopService.getResources(),
        workshopService.getServices(),
        workshopService.getTeamMembers(),
        workshopService.getWorkingHours(),
      ]);

      setState(() {
        _resources = results[0];
        _services = results[1];
        _teamMembers = results[2];
        _workingHours = _processWorkingHours(results[3]);
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// Process working hours data from database format
  Map<String, dynamic> _processWorkingHours(
      List<Map<String, dynamic>> workingHoursData) {
    // Convert database working hours to expected format
    final processedHours = <String, dynamic>{};

    final days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];

    for (final day in days) {
      final dayData =
          workingHoursData.where((wh) => wh['day'] == day).firstOrNull;
      processedHours[day] = {
        'enabled': dayData?['enabled'] ?? false,
        'start': dayData?['start_time'] ?? '09:00',
        'end': dayData?['end_time'] ?? '18:00',
      };
    }

    processedHours['breaks'] = workingHoursData
        .where((wh) => wh['type'] == 'break')
        .map((br) => {
              'name': br['name'],
              'start': br['start_time'],
              'end': br['end_time'],
            })
        .toList();

    processedHours['blackoutDates'] = workingHoursData
        .where((wh) => wh['type'] == 'blackout')
        .map((bd) => {
              'name': bd['name'],
              'date': bd['date'],
            })
        .toList();

    return processedHours;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Configuración del Taller',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 2.h),
              Text(
                'Cargando configuración...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/workshop-configuration',
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Configuración del Taller',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: colorScheme.error,
                size: 15.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Error al cargar datos',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _loadWorkshopData,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/workshop-configuration',
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Configuración del Taller',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios',
            color: colorScheme.onSurface,
            size: 5.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _saveAllConfiguration,
            icon: CustomIconWidget(
              iconName: 'save',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Guardar configuración',
          ),
          // Add navigation to Service Catalog
          IconButton(
            onPressed: () => _navigateToServiceCatalog(context),
            icon: CustomIconWidget(
              iconName: 'build',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Catálogo de Servicios',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'settings',
                color: _tabController.index == 0
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Recursos',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'schedule',
                color: _tabController.index == 1
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Horarios',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'build',
                color: _tabController.index == 2
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Servicios',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'group',
                color: _tabController.index == 3
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Equipo',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Resources tab
          _buildResourcesTab(),
          // Working hours tab
          _buildWorkingHoursTab(),
          // Services tab
          _buildServicesTab(),
          // Team tab
          _buildTeamTab(),
        ],
      ),
      bottomNavigationBar: RoleBasedNavigationBar(
        currentRoute: '/workshop-configuration',
      ),
    );
  }

  Widget _buildResourcesTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshResources,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              margin: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'settings',
                        color: colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Recursos del Taller',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addNewResource,
                        icon: CustomIconWidget(
                          iconName: 'add',
                          color: Colors.white,
                          size: 4.w,
                        ),
                        label: const Text('Nuevo'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Gestiona bahías, elevadores y equipos disponibles',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Resources statistics
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total',
                      _resources.length.toString(),
                      'inventory',
                      colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildStatCard(
                      'Activos',
                      _resources
                          .where((r) => r['is_active'] == true)
                          .length
                          .toString(),
                      'check_circle',
                      colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildStatCard(
                      'Inactivos',
                      _resources
                          .where((r) => r['is_active'] == false)
                          .length
                          .toString(),
                      'cancel',
                      colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Resources list
            if (_resources.isEmpty) ...[
              _buildEmptyResourcesState(),
            ] else ...[
              ..._resources.map((resource) {
                return ResourceCardWidget(
                  resource: resource,
                  onTap: () => _editResource(resource),
                  onToggle: (isActive) =>
                      _toggleResourceStatus(resource, isActive),
                );
              }).toList(),
            ],

            SizedBox(height: 10.h), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursTab() {
    return RefreshIndicator(
      onRefresh: _refreshWorkingHours,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: WorkingHoursWidget(
          workingHours: _workingHours,
          onHoursChanged: (updatedHours) {
            setState(() {
              _workingHours = updatedHours;
            });
            _showConfigurationSavedSnackBar('Horarios actualizados');
          },
        ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return RefreshIndicator(
      onRefresh: _refreshServices,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: ServiceManagementWidget(
          services: _services,
          onServicesChanged: (updatedServices) {
            setState(() {
              _services = updatedServices;
            });
            _showConfigurationSavedSnackBar('Servicios actualizados');
          },
        ),
      ),
    );
  }

  Widget _buildTeamTab() {
    return RefreshIndicator(
      onRefresh: _refreshTeam,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: TeamManagementWidget(
          teamMembers: _teamMembers,
          onTeamChanged: (updatedTeam) {
            setState(() {
              _teamMembers = updatedTeam;
            });
            _showConfigurationSavedSnackBar('Equipo actualizado');
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, String iconName, Color color) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 6.w,
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResourcesState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'settings',
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 15.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No hay recursos configurados',
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Agrega bahías, elevadores y equipos para comenzar a gestionar tu taller',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: _addNewResource,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: const Text('Agregar primer recurso'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate to Service Catalog Management with data flow connection
  Future<void> _navigateToServiceCatalog(BuildContext context) async {
    final hasAccess = await RoleService.checkRouteAccess(
        context, '/service-catalog-management');
    if (hasAccess) {
      Navigator.pushNamed(
        context,
        '/service-catalog-management',
        arguments: {
          'services': _services,
          'resources': _resources,
          'fromWorkshopConfig': true,
        },
      );
    }
  }

  void _addNewResource() {
    showDialog(
      context: context,
      builder: (context) => ResourceEditorDialog(
        onSave: (resourceData) async {
          try {
            final newResource = await WorkshopService.instance.createResource(
              name: resourceData['name'],
              type: resourceData['type'],
              isActive: resourceData['is_active'] ?? true,
            );

            setState(() {
              _resources.add(newResource);
            });

            _showConfigurationSavedSnackBar('Recurso creado exitosamente');
          } catch (error) {
            _showErrorSnackBar('Error al crear recurso: $error');
          }
        },
      ),
    );
  }

  void _editResource(Map<String, dynamic> resource) {
    showDialog(
      context: context,
      builder: (context) => ResourceEditorDialog(
        resource: resource,
        onSave: (resourceData) async {
          try {
            final updatedResource =
                await WorkshopService.instance.updateResource(
              resourceId: resource['id'],
              name: resourceData['name'],
              type: resourceData['type'],
              isActive: resourceData['is_active'],
            );

            setState(() {
              final index =
                  _resources.indexWhere((r) => r['id'] == resource['id']);
              if (index != -1) {
                _resources[index] = updatedResource;
              }
            });

            _showConfigurationSavedSnackBar('Recurso actualizado');
          } catch (error) {
            _showErrorSnackBar('Error al actualizar recurso: $error');
          }
        },
      ),
    );
  }

  void _toggleResourceStatus(
      Map<String, dynamic> resource, bool isActive) async {
    try {
      await WorkshopService.instance.updateResource(
        resourceId: resource['id'],
        isActive: isActive,
      );

      setState(() {
        final index = _resources.indexWhere((r) => r['id'] == resource['id']);
        if (index != -1) {
          _resources[index] = {
            ..._resources[index],
            'is_active': isActive,
          };
        }
      });

      _showConfigurationSavedSnackBar(
        isActive ? 'Recurso activado' : 'Recurso desactivado',
      );
    } catch (error) {
      _showErrorSnackBar('Error al actualizar recurso: $error');
    }
  }

  Future<void> _refreshResources() async {
    try {
      final resources = await WorkshopService.instance.getResources();
      setState(() {
        _resources = resources;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recursos actualizados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      _showErrorSnackBar('Error al actualizar recursos: $error');
    }
  }

  Future<void> _refreshWorkingHours() async {
    try {
      final workingHours = await WorkshopService.instance.getWorkingHours();
      setState(() {
        _workingHours = _processWorkingHours(workingHours);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horarios actualizados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      _showErrorSnackBar('Error al actualizar horarios: $error');
    }
  }

  Future<void> _refreshServices() async {
    try {
      final services = await WorkshopService.instance.getServices();
      setState(() {
        _services = services;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Servicios actualizados'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      _showErrorSnackBar('Error al actualizar servicios: $error');
    }
  }

  Future<void> _refreshTeam() async {
    try {
      final teamMembers = await WorkshopService.instance.getTeamMembers();
      setState(() {
        _teamMembers = teamMembers;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Equipo actualizado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      _showErrorSnackBar('Error al actualizar equipo: $error');
    }
  }

  void _saveAllConfiguration() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'save',
              color: Theme.of(context).colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            const Text('Guardar configuración'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que quieres guardar todos los cambios de configuración? Esta acción aplicará los cambios a todo el taller.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performSaveConfiguration();
            },
            child: const Text('Guardar todo'),
          ),
        ],
      ),
    );
  }

  void _performSaveConfiguration() {
    // Simulate saving configuration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            const Expanded(
              child: Text('Configuración guardada exitosamente'),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver cambios',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to summary or show changes
          },
        ),
      ),
    );
  }

  void _showConfigurationSavedSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
