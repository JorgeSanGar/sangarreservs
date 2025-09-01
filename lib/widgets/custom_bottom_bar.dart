import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data class
class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom bottom navigation bar for tire workshop management application
/// Provides quick access to main application sections
class CustomBottomBar extends StatelessWidget {
  /// Current active route
  final String currentRoute;

  /// Callback when navigation item is tapped
  final Function(String route)? onTap;

  /// Whether to show labels
  final bool showLabels;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom selected item color
  final Color? selectedItemColor;

  /// Custom unselected item color
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentRoute,
    this.onTap,
    this.showLabels = true,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  /// Navigation items for workshop management
  static const List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.today_outlined,
      activeIcon: Icons.today_rounded,
      label: 'Today',
      route: '/today-s-agenda',
    ),
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Calendar',
      route: '/calendar-view',
    ),
    NavigationItem(
      icon: Icons.add_circle_outline_rounded,
      activeIcon: Icons.add_circle_rounded,
      label: 'New Booking',
      route: '/booking-creation-wizard',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
      route: '/workshop-configuration',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Find current index
    int currentIndex = _navigationItems.indexWhere(
      (item) => item.route == currentRoute,
    );

    // Default to first item if route not found
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
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
          height: showLabels ? 80 : 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                () => _handleNavigation(context, item.route),
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
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final itemColor = isSelected
        ? (selectedItemColor ?? colorScheme.primary)
        : (unselectedItemColor ?? colorScheme.onSurfaceVariant);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? itemColor.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: itemColor,
                    size: isSelected ? 26 : 24,
                  ),
                ),

                // Label with animation
                if (showLabels) ...[
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    style: GoogleFonts.inter(
                      fontSize: isSelected ? 12 : 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: itemColor,
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handles navigation with proper route management
  void _handleNavigation(BuildContext context, String route) {
    // Don't navigate if already on the same route
    if (currentRoute == route) return;

    // Use callback if provided
    if (onTap != null) {
      onTap!(route);
      return;
    }

    // Handle special navigation cases
    switch (route) {
      case '/today-s-agenda':
        // Navigate to today's agenda and clear stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          route,
          (route) => false,
        );
        break;

      case '/calendar-view':
        // Navigate to calendar view
        if (currentRoute == '/today-s-agenda') {
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
        // Navigate to booking creation as modal
        Navigator.pushNamed(context, route);
        break;

      case '/workshop-configuration':
        // Navigate to settings
        Navigator.pushNamed(context, route);
        break;

      default:
        Navigator.pushNamed(context, route);
    }
  }

  /// Creates a floating variant of the bottom bar
  static Widget floating({
    required String currentRoute,
    Function(String route)? onTap,
    bool showLabels = false,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    EdgeInsets margin = const EdgeInsets.all(16),
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Container(
          margin: margin,
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CustomBottomBar(
            currentRoute: currentRoute,
            onTap: onTap,
            showLabels: showLabels,
            backgroundColor: Colors.transparent,
            selectedItemColor: selectedItemColor,
            unselectedItemColor: unselectedItemColor,
          ),
        );
      },
    );
  }

  /// Creates a compact variant with icons only
  static Widget compact({
    required String currentRoute,
    Function(String route)? onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return CustomBottomBar(
      currentRoute: currentRoute,
      onTap: onTap,
      showLabels: false,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
    );
  }
}
