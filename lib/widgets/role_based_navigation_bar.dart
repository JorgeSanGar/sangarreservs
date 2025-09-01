import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../services/role_service.dart';
import '../widgets/custom_icon_widget.dart';

/// Navigation item data class with role permissions
class RoleBasedNavigationItem {
  final String iconName;
  final String activeIconName;
  final String label;
  final String route;
  final List<String> allowedRoles;

  const RoleBasedNavigationItem({
    required this.iconName,
    required this.activeIconName,
    required this.label,
    required this.route,
    required this.allowedRoles,
  });
}

/// Role-based bottom navigation bar that shows different items based on user role
class RoleBasedNavigationBar extends StatefulWidget {
  final String currentRoute;
  final Function(String route)? onTap;

  const RoleBasedNavigationBar({
    super.key,
    required this.currentRoute,
    this.onTap,
  });

  @override
  State<RoleBasedNavigationBar> createState() => _RoleBasedNavigationBarState();
}

class _RoleBasedNavigationBarState extends State<RoleBasedNavigationBar> {
  List<Map<String, dynamic>> _navigationItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNavigationItems();
  }

  /// Load navigation items based on user role
  Future<void> _loadNavigationItems() async {
    try {
      final items = await RoleService.instance.getAccessibleNavigationItems();
      setState(() {
        _navigationItems = items;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _navigationItems = _getDefaultItems();
        _isLoading = false;
      });
    }
  }

  /// Get default navigation items if role check fails
  List<Map<String, dynamic>> _getDefaultItems() {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Find current index
    int currentIndex = _navigationItems.indexWhere(
      (item) => item['route'] == widget.currentRoute,
    );

    // Default to first item if route not found
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildNavigationItem(
                context,
                item,
                isSelected,
                () => _handleNavigation(context, item['route'] as String),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Builds individual navigation item
  Widget _buildNavigationItem(
    BuildContext context,
    Map<String, dynamic> item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itemColor =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSelected ? 2.w : 1.5.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? itemColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: isSelected
                        ? (item['activeIcon'] as String)
                        : (item['icon'] as String),
                    color: itemColor,
                    size: isSelected ? 6.w : 5.w,
                  ),
                ),

                // Label with animation
                SizedBox(height: 0.5.h),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  style: GoogleFonts.inter(
                    fontSize: isSelected ? 11.sp : 10.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: itemColor,
                  ),
                  child: Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handles navigation with role-based access control
  Future<void> _handleNavigation(BuildContext context, String route) async {
    // Don't navigate if already on the same route
    if (widget.currentRoute == route) return;

    // Check if user has access to the route
    final hasAccess = await RoleService.checkRouteAccess(context, route);
    if (!hasAccess) return;

    // Use callback if provided
    if (widget.onTap != null) {
      widget.onTap!(route);
      return;
    }

    // Handle special navigation cases
    switch (route) {
      case '/today-s-agenda':
        Navigator.pushNamedAndRemoveUntil(
          context,
          route,
          (route) => false,
        );
        break;

      case '/calendar-view':
        if (widget.currentRoute == '/today-s-agenda') {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            route,
            (route) => route.settings.name == '/today-s-agenda',
          );
        }
        break;

      case '/booking-creation-wizard':
        Navigator.pushNamed(context, route);
        break;

      case '/service-catalog-management':
      case '/team-management':
      case '/kpi-dashboard':
      case '/workshop-configuration':
        Navigator.pushNamed(context, route);
        break;

      default:
        Navigator.pushNamed(context, route);
    }
  }
}
