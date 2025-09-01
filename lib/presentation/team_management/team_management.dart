import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/role_service.dart';
import '../../services/team_service.dart';
import '../../services/workshop_service.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/role_based_navigation_bar.dart';
import './widgets/invitation_dialog.dart';
import './widgets/invite_member_dialog_widget.dart';
import './widgets/member_detail_sheet.dart';
import './widgets/role_management_dialog_widget.dart';
import './widgets/team_member_card_widget.dart';

class TeamManagement extends StatefulWidget {
  const TeamManagement({Key? key}) : super(key: key);

  @override
  State<TeamManagement> createState() => _TeamManagementState();
}

class _TeamManagementState extends State<TeamManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> _inviteRequests = [];
  Map<String, dynamic>? _currentUserRole;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WorkshopService.instance.getTeamMembers(),
        RoleService.instance.getCurrentUserRole(),
      ]);

      setState(() {
        _teamMembers = results[0] as List<Map<String, dynamic>>;
        _currentUserRole = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showInviteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const InviteMemberDialogWidget(),
    );

    if (result == true) {
      _loadTeamData(); // Refresh data after successful invite
    }
  }

  Future<void> _showRoleDialog(Map<String, dynamic> member) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RoleManagementDialogWidget(member: member),
    );

    if (result == true) {
      _loadTeamData(); // Refresh data after role update
    }
  }

  Future<void> _removeMember(String userId, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Team Member'),
        content:
            Text('Are you sure you want to remove $memberName from the team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await TeamService.removeMember(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$memberName has been removed from the team'),
            backgroundColor: Colors.green,
          ),
        );
        _loadTeamData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove member: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  bool get _canManageTeam {
    if (_currentUserRole == null) return false;
    final role = _currentUserRole!['role'] as String;
    return role == 'manager' || role == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Check access permissions
    if (!_canManageTeam && !_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Gestión de Equipo',
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
                'No tienes permisos para gestionar el equipo.\nEsta funcionalidad está disponible solo para gerentes.',
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
          currentRoute: '/team-management',
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Gestión de Equipo',
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
                'Cargando equipo...',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: RoleBasedNavigationBar(
          currentRoute: '/team-management',
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Gestión de Equipo',
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
                'Error al cargar equipo',
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
                onPressed: _loadTeamData,
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
          currentRoute: '/team-management',
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Gestión de Equipo',
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
          // Navigate to KPI Dashboard
          IconButton(
            onPressed: () => _navigateToKpiDashboard(context),
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: colorScheme.primary,
              size: 5.w,
            ),
            tooltip: 'Dashboard KPI',
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
                iconName: 'group',
                color: _tabController.index == 0
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Miembros del Equipo',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: _tabController.index == 1
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              text: 'Invitaciones',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Team members tab
          _buildTeamMembersTab(),
          // Invitations tab
          _buildInvitationsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _inviteNewMember,
        icon: CustomIconWidget(
          iconName: 'person_add',
          color: Colors.white,
          size: 6.w,
        ),
        label: const Text('Invitar Miembro'),
      ),
      bottomNavigationBar: RoleBasedNavigationBar(
        currentRoute: '/team-management',
      ),
    );
  }

  Widget _buildTeamMembersTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshTeamMembers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with statistics
            Container(
              width: double.infinity,
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
                        iconName: 'group',
                        color: colorScheme.primary,
                        size: 8.w,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Equipo de Trabajo',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Gestiona roles y permisos del equipo',
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

                  // Team statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildTeamStatCard(
                          'Total',
                          _teamMembers.length.toString(),
                          'group',
                          colorScheme.primary,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildTeamStatCard(
                          'Gerentes',
                          _teamMembers
                              .where((m) =>
                                  m['role'] == 'manager' ||
                                  m['role'] == 'admin')
                              .length
                              .toString(),
                          'admin_panel_settings',
                          colorScheme.secondary,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: _buildTeamStatCard(
                          'Técnicos',
                          _teamMembers
                              .where((m) => m['role'] == 'worker')
                              .length
                              .toString(),
                          'build',
                          colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Team members list
            if (_teamMembers.isEmpty) ...[
              _buildEmptyTeamState(),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Miembros del Equipo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              ..._teamMembers.map((member) {
                return TeamMemberCardWidget(
                  member: member,
                  onTap: () => _showMemberDetails(member),
                  onEditRole: () => _updateMemberRole(member, 'newRole'),
                  onRemove: () => _toggleMemberStatus(member, false),
                );
              }).toList(),
            ],

            SizedBox(height: 10.h), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsTab() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: _refreshInvitations,
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
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'person_add',
                    color: colorScheme.secondary,
                    size: 8.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invitaciones Pendientes',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
                          ),
                        ),
                        Text(
                          'Gestiona invitaciones enviadas al equipo',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Invitations list
            if (_inviteRequests.isEmpty) ...[
              _buildEmptyInvitationsState(),
            ] else ...[
              ..._inviteRequests.map((invitation) {
                return InvitationDialog(
                  onSend: (data) => _acceptInvitation(invitation),
                );
              }).toList(),
            ],

            SizedBox(height: 10.h), // Bottom padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildTeamStatCard(
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

  Widget _buildEmptyTeamState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'group_add',
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Equipo vacío',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Invita a tu equipo para comenzar a gestionar el taller colaborativamente',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _inviteNewMember,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: Colors.white,
                size: 5.w,
              ),
              label: const Text('Invitar primer miembro'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyInvitationsState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'mail_outline',
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'No hay invitaciones pendientes',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Las invitaciones que envíes aparecerán aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _inviteNewMember() {
    showDialog(
      context: context,
      builder: (context) => InviteMemberDialogWidget(),
    );
  }

  void _showMemberDetails(Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MemberDetailSheet(
        member: member,
        onEdit: () => _updateMemberRole(member, 'newRole'),
        onDelete: () => _toggleMemberStatus(member, false),
      ),
    );
  }

  Future<void> _updateMemberRole(
      Map<String, dynamic> member, String newRole) async {
    try {
      await WorkshopService.instance.updateTeamMemberRole(
        userId: member['user_id'],
        newRole: newRole,
      );

      setState(() {
        final index =
            _teamMembers.indexWhere((m) => m['user_id'] == member['user_id']);
        if (index != -1) {
          _teamMembers[index] = {
            ..._teamMembers[index],
            'role': newRole,
          };
        }
      });

      _showSuccessSnackBar('Rol actualizado exitosamente');
    } catch (error) {
      _showErrorSnackBar('Error al actualizar rol: $error');
    }
  }

  void _toggleMemberStatus(Map<String, dynamic> member, bool isActive) {
    // Implement member status toggle logic
    _showSuccessSnackBar(
      isActive ? 'Miembro activado' : 'Miembro desactivado',
    );
  }

  void _acceptInvitation(Map<String, dynamic> invitation) {
    // Implement invitation acceptance logic
    _showSuccessSnackBar('Invitación aceptada');
  }

  void _rejectInvitation(Map<String, dynamic> invitation) {
    // Implement invitation rejection logic
    _showSuccessSnackBar('Invitación rechazada');
  }

  void _resendInvitation(Map<String, dynamic> invitation) {
    // Implement invitation resend logic
    _showSuccessSnackBar('Invitación reenviada');
  }

  Future<void> _refreshTeamMembers() async {
    try {
      final teamMembers = await WorkshopService.instance.getTeamMembers();
      setState(() {
        _teamMembers = teamMembers;
      });
    } catch (error) {
      _showErrorSnackBar('Error al actualizar equipo: $error');
    }
  }

  Future<void> _refreshInvitations() async {
    // Implement invitations refresh
    await Future.delayed(const Duration(seconds: 1));
  }

  /// Navigate to Service Catalog with role-based access control
  Future<void> _navigateToServiceCatalog(BuildContext context) async {
    final hasAccess = await RoleService.checkRouteAccess(
        context, '/service-catalog-management');
    if (hasAccess) {
      Navigator.pushNamed(context, '/service-catalog-management');
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
}