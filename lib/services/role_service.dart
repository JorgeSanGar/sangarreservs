import 'package:flutter/material.dart';

import './supabase_service.dart';

/// Service for handling role-based access control and permissions
class RoleService {
  static final RoleService _instance = RoleService._internal();
  static RoleService get instance => _instance;
  RoleService._internal();

  final _client = SupabaseService.instance.client;

  /// User roles available in the system
  static const String roleManager = 'manager';
  static const String roleWorker = 'worker';
  static const String roleAdmin = 'admin';

  /// Manager-only accessible routes
  static const List<String> _managerOnlyRoutes = [
    '/team-management',
    '/kpi-dashboard',
    '/service-catalog-management',
  ];

  /// Get current user's role and organization membership
  Future<Map<String, dynamic>?> getCurrentUserRole() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response = await _client
          .from('org_members')
          .select('role, org_id, orgs!inner(name)')
          .eq('user_id', user.id)
          .single();

      return {
        'user_id': user.id,
        'role': response['role'] as String,
        'org_id': response['org_id'] as String,
        'org_name': response['orgs']['name'] as String,
      };
    } catch (error) {
      throw Exception('Failed to get user role: $error');
    }
  }

  /// Check if current user has manager privileges
  Future<bool> isManager() async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole != null &&
          (userRole['role'] == roleManager || userRole['role'] == roleAdmin);
    } catch (error) {
      return false;
    }
  }

  /// Check if current user has worker privileges only
  Future<bool> isWorker() async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole != null && userRole['role'] == roleWorker;
    } catch (error) {
      return false;
    }
  }

  /// Check if user can access a specific route
  Future<bool> canAccessRoute(String route) async {
    try {
      // Public routes are accessible to everyone
      if (!_managerOnlyRoutes.contains(route)) {
        return true;
      }

      // Manager-only routes require manager privileges
      return await isManager();
    } catch (error) {
      return false;
    }
  }

  /// Get accessible navigation items based on user role
  Future<List<Map<String, dynamic>>> getAccessibleNavigationItems() async {
    try {
      final isManagerRole = await isManager();

      // Base navigation items for all users
      final allNavItems = [
        {
          'icon': 'today_outlined',
          'activeIcon': 'today_rounded',
          'label': 'Agenda',
          'route': '/today-s-agenda',
          'roles': ['manager', 'worker', 'admin']
        },
        {
          'icon': 'calendar_month_outlined',
          'activeIcon': 'calendar_month_rounded',
          'label': 'Calendario',
          'route': '/calendar-view',
          'roles': ['manager', 'worker', 'admin']
        },
        {
          'icon': 'add_circle_outline_rounded',
          'activeIcon': 'add_circle_rounded',
          'label': 'Nueva Cita',
          'route': '/booking-creation-wizard',
          'roles': ['manager', 'worker', 'admin']
        },
        {
          'icon': 'build_outlined',
          'activeIcon': 'build_rounded',
          'label': 'Servicios',
          'route': '/service-catalog-management',
          'roles': ['manager', 'admin']
        },
        {
          'icon': 'group_outlined',
          'activeIcon': 'group_rounded',
          'label': 'Equipo',
          'route': '/team-management',
          'roles': ['manager', 'admin']
        },
        {
          'icon': 'analytics_outlined',
          'activeIcon': 'analytics_rounded',
          'label': 'KPIs',
          'route': '/kpi-dashboard',
          'roles': ['manager', 'admin']
        },
        {
          'icon': 'settings_outlined',
          'activeIcon': 'settings_rounded',
          'label': 'Configuración',
          'route': '/workshop-configuration',
          'roles': ['manager', 'admin']
        },
      ];

      // Filter items based on user role
      final accessibleItems = allNavItems.where((item) {
        final roles = item['roles'] as List<String>;
        if (isManagerRole) {
          return roles.contains('manager') || roles.contains('admin');
        } else {
          return roles.contains('worker');
        }
      }).toList();

      return accessibleItems;
    } catch (error) {
      // Return basic items if role check fails
      return [
        {
          'icon': 'today_outlined',
          'activeIcon': 'today_rounded',
          'label': 'Agenda',
          'route': '/today-s-agenda',
        },
        {
          'icon': 'calendar_month_outlined',
          'activeIcon': 'calendar_month_rounded',
          'label': 'Calendario',
          'route': '/calendar-view',
        },
      ];
    }
  }

  /// Show access denied dialog for restricted routes
  static void showAccessDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.block_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Acceso Restringido'),
          ],
        ),
        content: const Text(
          'No tienes permisos para acceder a esta sección. Esta funcionalidad está disponible solo para gerentes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Middleware function to check route access before navigation
  static Future<bool> checkRouteAccess(
      BuildContext context, String route) async {
    final canAccess = await RoleService.instance.canAccessRoute(route);

    if (!canAccess) {
      showAccessDeniedDialog(context);
      return false;
    }

    return true;
  }
}