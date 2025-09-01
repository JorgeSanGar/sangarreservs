import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/role_service.dart';
import '../../services/workshop_service.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/role_based_navigation_bar.dart';
import './widgets/dashboard_filter_widget.dart';
import './widgets/kpi_metric_card_widget.dart';
import './widgets/performance_chart_widget.dart';
import './widgets/performance_leaderboard_widget.dart';
import './widgets/revenue_chart_widget.dart';
import './widgets/team_performance_widget.dart';
import './widgets/utilization_heatmap_widget.dart';

class KpiDashboard extends StatefulWidget {
  const KpiDashboard({Key? key}) : super(key: key);

  @override
  State<KpiDashboard> createState() => _KpiDashboardState();
}

class _KpiDashboardState extends State<KpiDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _kpiData = {};
  Map<String, dynamic>? _currentUserRole;
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'month';

  @override
  void initState() {
    super.initState();
    _loadKpiData();
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

    // Check access permissions
    if (!_canAccessKpiDashboard && !_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Dashboard KPI',
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
                iconName: 'block',
                color: colorScheme.error,
                size: 20.w,
              ),
              SizedBox(height: 3.h),
              Text(
                'Acceso Restringido',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'No tienes permisos para ver el dashboard de KPIs.\nEsta funcionalidad está disponible solo para gerentes.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 5.w,
                ),
                label: const Text('Volver'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/kpi-dashboard',
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Dashboard KPI',
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
                'Cargando métricas...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/kpi-dashboard',
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Dashboard KPI',
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
                'Error al cargar métricas',
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
                onPressed: _loadKpiData,
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
          currentRoute: '/kpi-dashboard',
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dashboard KPI',
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
          // Navigate to Service Catalog
          IconButton(
            onPressed: () => _navigateToServiceCatalog(context),
            icon: CustomIconWidget(
              iconName: 'build',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Catálogo de Servicios',
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
      body: RefreshIndicator(
        onRefresh: _refreshKpiData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with period selector
              _buildHeaderSection(),

              // Key metrics cards
              _buildKeyMetricsSection(),

              // Performance charts
              _buildPerformanceChartsSection(),

              // Team performance
              _buildTeamPerformanceSection(),

              // Revenue and trend analysis
              _buildRevenueSection(),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: RoleBasedNavigationBar(
        currentRoute: '/kpi-dashboard',
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
                iconName: 'analytics',
                color: colorScheme.primary,
                size: 8.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard KPI',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Métricas de rendimiento del taller',
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

          // Period selector
          DashboardFilterWidget(
            selectedTimeRange: _selectedPeriod,
            selectedServiceType: 'all',
            selectedTeamMembers: const [],
            onFiltersChanged: (period, _, __) {
              setState(() {
                _selectedPeriod = period;
              });
              _loadKpiData();
            },
          ),

          SizedBox(height: 2.h),

          // Quick navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToServiceCatalog(context),
                  icon: CustomIconWidget(
                    iconName: 'build',
                    color: colorScheme.primary,
                    size: 4.w,
                  ),
                  label: const Text('Servicios'),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToTeamManagement(context),
                  icon: CustomIconWidget(
                    iconName: 'group',
                    color: colorScheme.secondary,
                    size: 4.w,
                  ),
                  label: const Text('Equipo'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Métricas Clave',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Key metrics grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 1.5,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          children: [
            KpiMetricCardWidget(
              title: 'Citas este Mes',
              value: _kpiData['bookings_this_month']?.toString() ?? '0',
              trend: 12.5,
              icon: Icons.event,
              color: theme.colorScheme.primary,
            ),
            KpiMetricCardWidget(
              title: 'Servicios Activos',
              value: _kpiData['services_count']?.toString() ?? '0',
              trend: 3,
              icon: Icons.build,
              color: theme.colorScheme.secondary,
            ),
            KpiMetricCardWidget(
              title: 'Recursos',
              value: _kpiData['resources_count']?.toString() ?? '0',
              trend: 0,
              icon: Icons.inventory,
              color: theme.colorScheme.tertiary,
            ),
            KpiMetricCardWidget(
              title: 'Miembros Equipo',
              value: _kpiData['team_count']?.toString() ?? '0',
              trend: 1,
              icon: Icons.group,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceChartsSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Rendimiento',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Performance chart
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: PerformanceChartWidget(
            data: _kpiData['performance_data'] ?? [],
          ),
        ),

        SizedBox(height: 2.h),

        // Utilization heatmap
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: UtilizationHeatmapWidget(
            utilizationData: _kpiData['utilization_data'] ?? [],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamPerformanceSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rendimiento del Equipo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton.icon(
                onPressed: () => _navigateToTeamManagement(context),
                icon: CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: theme.colorScheme.primary,
                  size: 4.w,
                ),
                label: const Text('Ver Equipo'),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),

        // Team performance widget
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: TeamPerformanceWidget(
            teamData: (_kpiData['team_data'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          ),
        ),

        SizedBox(height: 2.h),

        // Performance leaderboard
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: PerformanceLeaderboardWidget(
            teamData: (_kpiData['leaderboard_data'] as List?)?.cast<Map<String, dynamic>>() ?? [],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Análisis Financiero',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Revenue chart
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          child: RevenueChartWidget(
            data: _kpiData['revenue_data'] ?? [],
          ),
        ),
      ],
    );
  }

  Future<void> _refreshKpiData() async {
    await _loadKpiData();
  }

  /// Navigate to Service Catalog with role-based access control
  Future<void> _navigateToServiceCatalog(BuildContext context) async {
    final hasAccess = await RoleService.checkRouteAccess(
        context, '/service-catalog-management');
    if (hasAccess) {
      Navigator.pushNamed(context, '/service-catalog-management');
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

  /// Load KPI data from Supabase
  Future<void> _loadKpiData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WorkshopService.instance.getWorkshopStats(),
        RoleService.instance.getCurrentUserRole(),
      ]);

      setState(() {
        _kpiData = results[0] ?? {};
        _currentUserRole = results[1];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  /// Check if current user can access KPI dashboard (is manager/admin)
  bool get _canAccessKpiDashboard {
    if (_currentUserRole == null) return false;
    final role = _currentUserRole!['role'] as String;
    return role == 'manager' || role == 'admin';
  }

  double _calculateRevenueTrend() {
    // Simple trend calculation based on last few days of revenue data
    final revenueData = _kpiData['revenue_data'] as List<Map<String, dynamic>>? ?? [];
    if (revenueData.length < 2) return 0;

    final recent = revenueData.take(7).map((d) => (d['revenue'] as num).toDouble()).toList();
    final previous = revenueData
        .skip(7)
        .take(7)
        .map((d) => (d['revenue'] as num).toDouble())
        .toList();

    if (previous.isEmpty) return 0;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final previousAvg = previous.reduce((a, b) => a + b) / previous.length;

    return previousAvg > 0
        ? ((recentAvg - previousAvg) / previousAvg * 100)
        : 0;
  }

  double _calculateCompletionTrend() {
    // Simple trend calculation for completion rate
    final completionData = _kpiData['performance_data'] as List<Map<String, dynamic>>? ?? [];
    if (completionData.length < 2) return 0;

    final recent = completionData
        .take(7)
        .map((d) => (d['completion_rate'] as num).toDouble())
        .toList();
    final previous = completionData
        .skip(7)
        .take(7)
        .map((d) => (d['completion_rate'] as num).toDouble())
        .toList();

    if (previous.isEmpty) return 0;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final previousAvg = previous.reduce((a, b) => a + b) / previous.length;

    return recentAvg - previousAvg;
  }

  Color _getCompletionRateColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 75) return Colors.orange;
    return Colors.red;
  }
}