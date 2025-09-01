import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/role_service.dart';
import '../../services/workshop_service.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/role_based_navigation_bar.dart';
import './widgets/add_service_modal_widget.dart';
import './widgets/bulk_operations_toolbar_widget.dart';
import './widgets/search_and_filter_widget.dart';
import './widgets/service_card_widget.dart';

class ServiceCatalogManagement extends StatefulWidget {
  const ServiceCatalogManagement({super.key});

  @override
  State<ServiceCatalogManagement> createState() =>
      _ServiceCatalogManagementState();
}

class _ServiceCatalogManagementState extends State<ServiceCatalogManagement>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'all';
  List<Map<String, dynamic>> _selectedServices = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _arguments;

  // Add missing instance variables
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _resources = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Add this line
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _loadServiceCatalogData();
    });
  }

  /// Load service catalog data from Supabase or arguments
  Future<void> _loadServiceCatalogData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workshopService = WorkshopService.instance;

      // Check if data passed from workshop configuration
      if (_arguments != null && _arguments!['fromWorkshopConfig'] == true) {
        setState(() {
          _services =
              List<Map<String, dynamic>>.from(_arguments!['services'] ?? []);
          _resources =
              List<Map<String, dynamic>>.from(_arguments!['resources'] ?? []);
          _categories = _extractCategories(_services);
          _isLoading = false;
        });
      } else {
        // Load data from Supabase
        final results = await Future.wait([
          workshopService.getServices(),
          workshopService.getResources(),
        ]);

        setState(() {
          _services = results[0];
          _resources = results[1];
          _categories = _extractCategories(_services);
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// Extract unique categories from services
  List<String> _extractCategories(List<Map<String, dynamic>> services) {
    final categories = <String>{'all'};
    for (final service in services) {
      final category = service['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categories.add(category);
      }
    }
    return categories.toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleServiceSelection(Map<String, dynamic> service) {
    setState(() {
      final isSelected = _selectedServices.any((s) => s['id'] == service['id']);
      if (isSelected) {
        _selectedServices.removeWhere((s) => s['id'] == service['id']);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedServices.clear();
    });
  }

  void _showAddServiceModal([Map<String, dynamic>? service]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddServiceModalWidget(
        service: service,
        categories: _categories
            .where((c) => c != 'all')
            .map((cat) => {'id': cat, 'name': cat})
            .toList(),
        onSave: (serviceData) async {
          try {
            final newService = await WorkshopService.instance.createService(
              name: serviceData['name'],
              category: serviceData['category'],
              price: serviceData['price'],
              durationMin: serviceData['durationMin'],
            );

            setState(() {
              _services.add(newService);
              _categories = _extractCategories(_services);
            });

            _showSuccessSnackBar('Servicio creado exitosamente');
          } catch (error) {
            _showErrorSnackBar('Error al crear servicio: $error');
          }
        },
      ),
    );
  }

  void _exportCatalog() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Catálogo exportado como PDF',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () {
            // TODO: Open exported PDF
          },
        ),
      ),
    );
  }

  void _performBulkOperation(String operation) {
    HapticFeedback.mediumImpact();
    String message = '';

    switch (operation) {
      case 'activate':
        message = '${_selectedServices.length} servicios activados';
        break;
      case 'deactivate':
        message = '${_selectedServices.length} servicios desactivados';
        break;
      case 'delete':
        message = '${_selectedServices.length} servicios eliminados';
        break;
      case 'duplicate':
        message = '${_selectedServices.length} servicios duplicados';
        break;
      case 'price_update':
        _showBulkPriceUpdateDialog();
        return;
    }

    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.inter(fontSize: 14.sp),
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      _clearSelection();
    }
  }

  void _showBulkPriceUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Actualización Masiva de Precios',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Seleccione el tipo de actualización para ${_selectedServices.length} servicios:',
              style: GoogleFonts.inter(fontSize: 14.sp),
            ),
            SizedBox(height: 2.h),
            // Price update options would go here
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Precios actualizados exitosamente',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                );
                _clearSelection();
              },
              child: Text('Aplicar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBulkDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicios seleccionados'),
        content: Text(
          '¿Estás seguro de que quieres eliminar ${_selectedServices.length} servicio(s)? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performBulkDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _performBulkDelete() async {
    try {
      // Implement bulk delete logic
      for (final service in _selectedServices) {
        // await WorkshopService.instance.deleteService(service['id']);
      }

      setState(() {
        _services.removeWhere((service) => _selectedServices
            .any((selected) => selected['id'] == service['id']));
        _selectedServices.clear();
      });

      _showSuccessSnackBar('Servicios eliminados exitosamente');
    } catch (error) {
      _showErrorSnackBar('Error al eliminar servicios: $error');
    }
  }

  void _exportSelectedServices() {
    // Implement service export functionality
    _showSuccessSnackBar('Exportando ${_selectedServices.length} servicios...');
  }

  void _handleBulkAction(String action) {
    switch (action) {
      case 'delete':
        _showBulkDeleteConfirmation();
        break;
      case 'export':
        _exportSelectedServices();
        break;
      case 'duplicate':
        _performBulkOperation('duplicate');
        break;
      case 'activate':
        _performBulkOperation('activate');
        break;
      case 'deactivate':
        _performBulkOperation('deactivate');
        break;
      case 'price_update':
        _performBulkOperation('price_update');
        break;
      default:
        _performBulkOperation(action);
    }
  }

  void _addNewService() {
    showDialog(
      context: context,
      builder: (context) => AddServiceModalWidget(
        categories: _categories
            .where((c) => c != 'all')
            .map((cat) => {'id': cat, 'name': cat})
            .toList(),
        onSave: (serviceData) async {
          try {
            final newService = await WorkshopService.instance.createService(
              name: serviceData['name'],
              category: serviceData['category'],
              price: serviceData['price'],
              durationMin: serviceData['durationMin'],
            );

            setState(() {
              _services.add(newService);
              _categories = _extractCategories(_services);
            });

            _showSuccessSnackBar('Servicio creado exitosamente');
          } catch (error) {
            _showErrorSnackBar('Error al crear servicio: $error');
          }
        },
      ),
    );
  }

  void _editService(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AddServiceModalWidget(
        service: service,
        categories: _categories
            .where((c) => c != 'all')
            .map((cat) => {'id': cat, 'name': cat})
            .toList(),
        onSave: (serviceData) async {
          try {
            final updatedService = await WorkshopService.instance.updateService(
              serviceId: service['id'],
              name: serviceData['name'],
              category: serviceData['category'],
              price: serviceData['price'],
              durationMin: serviceData['durationMin'],
            );

            setState(() {
              final index =
                  _services.indexWhere((s) => s['id'] == service['id']);
              if (index != -1) {
                _services[index] = updatedService;
              }
              _categories = _extractCategories(_services);
            });

            _showSuccessSnackBar('Servicio actualizado');
          } catch (error) {
            _showErrorSnackBar('Error al actualizar servicio: $error');
          }
        },
      ),
    );
  }

  Future<void> _refreshServices() async {
    try {
      final services = await WorkshopService.instance.getServices();
      setState(() {
        _services = services;
        _categories = _extractCategories(_services);
      });
    } catch (error) {
      _showErrorSnackBar('Error al actualizar servicios: $error');
    }
  }

  /// Navigate to Workshop Configuration with data flow connection
  Future<void> _navigateToWorkshopConfiguration(BuildContext context) async {
    final hasAccess =
        await RoleService.checkRouteAccess(context, '/workshop-configuration');
    if (hasAccess) {
      Navigator.pushNamed(
        context,
        '/workshop-configuration',
        arguments: {
          'services': _services,
          'resources': _resources,
          'fromServiceCatalog': true,
        },
      );
    }
  }

  /// Navigate to Team Management with role-based access control
  Future<void> _navigateToTeamManagement(BuildContext context) async {
    final hasAccess =
        await RoleService.checkRouteAccess(context, '/team-management');
    if (hasAccess) {
      Navigator.pushNamed(context, '/team-management');
    }
  }

  /// Navigate to KPI Dashboard with role-based access control
  Future<void> _navigateToKpiDashboard(BuildContext context) async {
    final hasAccess =
        await RoleService.checkRouteAccess(context, '/kpi-dashboard');
    if (hasAccess) {
      Navigator.pushNamed(context, '/kpi-dashboard');
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Catálogo de Servicios',
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
                'Cargando servicios...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/service-catalog-management',
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Catálogo de Servicios',
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
                'Error al cargar servicios',
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
                onPressed: _loadServiceCatalogData,
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
          currentRoute: '/service-catalog-management',
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Catálogo de Servicios',
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
          // Navigate to Workshop Configuration
          IconButton(
            onPressed: () => _navigateToWorkshopConfiguration(context),
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Configuración del Taller',
          ),
          // Navigate to Team Management
          IconButton(
            onPressed: () => _navigateToTeamManagement(context),
            icon: CustomIconWidget(
              iconName: 'group',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Gestión de Equipo',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with statistics and quick actions
          _buildHeaderSection(),

          // Search and filter section
          _buildSearchAndFilterSection(),

          // Services grid/list
          Expanded(
            child: _buildServicesContent(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewService,
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 6.w,
        ),
        label: const Text('Nuevo Servicio'),
      ),
      bottomNavigationBar: RoleBasedNavigationBar(
        currentRoute: '/service-catalog-management',
      ),
    );
  }

  Widget _buildHeaderSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'build',
                color: colorScheme.primary,
                size: 8.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catálogo de Servicios',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Gestiona todos los servicios disponibles en el taller',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Total Servicios',
                  _services.length.toString(),
                  'build',
                  colorScheme.primary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickStatCard(
                  'Categorías',
                  (_categories.length - 1).toString(), // Exclude 'all'
                  'category',
                  colorScheme.secondary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildQuickStatCard(
                  'Recursos',
                  _resources.length.toString(),
                  'inventory',
                  colorScheme.tertiary,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToWorkshopConfiguration(context),
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  label: const Text('Configuración'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToKpiDashboard(context),
                  icon: CustomIconWidget(
                    iconName: 'analytics',
                    color: colorScheme.secondary,
                    size: 4.w,
                  ),
                  label: const Text('KPIs'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(
      String label, String value, String iconName, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return SearchAndFilterWidget(
      searchQuery: _searchQuery,
      onSearchChanged: (query) {
        setState(() {
          _searchQuery = query;
        });
      },
      selectedCategory: _selectedCategory,
      categories: _categories.map((cat) => {'id': cat, 'name': cat}).toList(),
      onCategoryChanged: (category) {
        setState(() {
          _selectedCategory = category;
        });
      },
      minPrice: 0.0,
      maxPrice: 500.0,
      onPriceRangeChanged: (range) {
        // Handle price range change
      },
    );
  }

  Widget _buildServicesContent() {
    if (_filteredServices.isEmpty) {
      return _buildEmptyServicesState();
    }

    return Column(
      children: [
        // Bulk operations toolbar
        if (_selectedServices.isNotEmpty)
          BulkOperationsToolbarWidget(
            selectedCount: _selectedServices.length,
            onOperation: _handleBulkAction,
            onClear: () {
              setState(() {
                _selectedServices.clear();
              });
            },
          ),

        // Services list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshServices,
            child: ListView.builder(
              padding: EdgeInsets.all(4.w),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                final service = _filteredServices[index];
                final isSelected =
                    _selectedServices.any((s) => s['id'] == service['id']);

                return ServiceCardWidget(
                  key: ValueKey(service['id']),
                  service: service,
                  isSelected: isSelected,
                  onTap: () => _editService(service),
                  onEdit: () => _editService(service),
                  onDuplicate: () {
                    // Handle duplicate
                  },
                  onDelete: () => _showDeleteConfirmation(service),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyServicesState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'build',
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20.w,
            ),
            SizedBox(height: 3.h),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'all'
                  ? 'No se encontraron servicios'
                  : 'No hay servicios configurados',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != 'all'
                  ? 'Intenta ajustar los filtros de búsqueda'
                  : 'Agrega servicios para comenzar a gestionar tu catálogo',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            if (_searchQuery.isEmpty && _selectedCategory == 'all')
              ElevatedButton.icon(
                onPressed: _addNewService,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: const Text('Agregar primer servicio'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Servicio',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${service['name']}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Servicio eliminado'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredServices {
    return _services.where((service) {
      final matchesSearch = _searchQuery.isEmpty ||
          service['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (service['category'] ?? '')
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == 'all' ||
          service['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }
}
