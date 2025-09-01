import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget for tire workshop management application
/// Provides consistent navigation and branding across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (defaults to true when there's a previous route)
  final bool showBackButton;

  /// Custom leading widget (overrides back button if provided)
  final Widget? leading;

  /// List of action widgets to display on the right side
  final List<Widget>? actions;

  /// Whether to show elevation shadow
  final bool showElevation;

  /// Custom background color (uses theme color if not provided)
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom bottom widget (like TabBar)
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.showElevation = true,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: showElevation ? 2.0 : 0.0,
      shadowColor: colorScheme.shadow,
      surfaceTintColor: Colors.transparent,
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: foregroundColor ?? colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                )
              : null),
      actions: actions ?? _buildDefaultActions(context),
      bottom: bottom,
      toolbarHeight: 56.0,
      leadingWidth: 56.0,
    );
  }

  /// Builds default actions based on current route
  List<Widget> _buildDefaultActions(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final colorScheme = Theme.of(context).colorScheme;

    switch (currentRoute) {
      case '/today-s-agenda':
        return [
          IconButton(
            icon: Icon(
              Icons.calendar_today_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pushNamed(context, '/calendar-view'),
            tooltip: 'Calendar View',
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/workshop-configuration'),
            tooltip: 'Settings',
          ),
        ];

      case '/calendar-view':
        return [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/booking-creation-wizard'),
            tooltip: 'New Booking',
          ),
          IconButton(
            icon: Icon(
              Icons.settings_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/workshop-configuration'),
            tooltip: 'Settings',
          ),
        ];

      case '/booking-creation-wizard':
        return [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            ),
          ),
        ];

      case '/booking-details':
        return [
          IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () {
              // Navigate to edit booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit booking functionality')),
              );
            },
            tooltip: 'Edit Booking',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicate booking')),
                  );
                  break;
                case 'cancel':
                  _showCancelBookingDialog(context);
                  break;
                case 'share':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share booking details')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded),
                    SizedBox(width: 12),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share_rounded),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'cancel',
                child: Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Cancel Booking', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ];

      case '/workshop-configuration':
        return [
          IconButton(
            icon: Icon(
              Icons.save_rounded,
              color: foregroundColor ?? colorScheme.onSurface,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved')),
              );
            },
            tooltip: 'Save Settings',
          ),
        ];

      default:
        return [];
    }
  }

  /// Shows cancel booking confirmation dialog
  void _showCancelBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Booking cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
