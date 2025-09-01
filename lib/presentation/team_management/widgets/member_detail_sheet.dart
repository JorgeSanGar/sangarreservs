import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MemberDetailSheet extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MemberDetailSheet({
    super.key,
    required this.member,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isActive = member['isActive'] ?? true;
    final joinDate = DateTime.parse(member['joinDate']);
    final lastActive = DateTime.parse(member['lastActive']);
    final specializations = member['specializations'] as List<String>? ?? [];
    final performance = member['performance'] as Map<String, dynamic>? ?? {};
    final schedule = member['schedule'] as Map<String, dynamic>? ?? {};

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 12.w,
                height: 1.h,
                margin: EdgeInsets.only(top: 2.w),
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member header
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 10.w,
                                backgroundColor:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                backgroundImage: member['avatar'] != null
                                    ? CachedNetworkImageProvider(
                                        member['avatar'])
                                    : null,
                                child: member['avatar'] == null
                                    ? CustomIconWidget(
                                        iconName: 'person',
                                        color: colorScheme.primary,
                                        size: 10.w,
                                      )
                                    : null,
                              ),
                              if (isActive &&
                                  _isRecentlyActive(lastActive)) ...[
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 5.w,
                                    height: 5.w,
                                    decoration: BoxDecoration(
                                      color: colorScheme.tertiary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.surface,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['name'],
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  member['email'],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                _buildRoleBadge(context),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (action) {
                              switch (action) {
                                case 'edit':
                                  onEdit();
                                  break;
                                case 'delete':
                                  onDelete();
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Editar permisos'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Eliminar miembro',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            child: CustomIconWidget(
                              iconName: 'more_vert',
                              color: colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // Status and join info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              'Estado',
                              isActive ? 'Activo' : 'Inactivo',
                              isActive ? 'check_circle' : 'cancel',
                              isActive
                                  ? colorScheme.tertiary
                                  : colorScheme.error,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildInfoCard(
                              context,
                              'Se unió',
                              _formatDate(joinDate),
                              'calendar_today',
                              colorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      if (isActive) ...[
                        SizedBox(height: 2.h),
                        _buildInfoCard(
                          context,
                          'Última actividad',
                          _formatLastActive(lastActive),
                          'access_time',
                          colorScheme.secondary,
                        ),
                      ],

                      SizedBox(height: 3.h),

                      // Specializations
                      if (specializations.isNotEmpty) ...[
                        Text(
                          'Especializaciones',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 2.w,
                          children: specializations.map((spec) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 2.w,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'build',
                                    color: colorScheme.onPrimaryContainer,
                                    size: 3.w,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    spec,
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 3.h),
                      ],

                      // Performance metrics
                      if (performance.isNotEmpty && isActive) ...[
                        Text(
                          'Rendimiento',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Servicios completados',
                                performance['completedServices'].toString(),
                                'build',
                                colorScheme.primary,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildMetricCard(
                                context,
                                'Rating promedio',
                                '${performance['customerRating']}★',
                                'star',
                                colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        _buildMetricCard(
                          context,
                          'Eficiencia',
                          '${performance['efficiency']}%',
                          'trending_up',
                          colorScheme.secondary,
                        ),
                        SizedBox(height: 3.h),
                      ],

                      // Schedule preferences
                      if (schedule.isNotEmpty) ...[
                        Text(
                          'Horario de trabajo',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        _buildScheduleInfo(context, schedule),
                        SizedBox(height: 3.h),
                      ],

                      // Permissions summary
                      Text(
                        'Permisos actuales',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildPermissionsSummary(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String roleName;
    Color roleColor;

    switch (member['role']) {
      case 'manager':
        roleName = 'Gerente';
        roleColor = colorScheme.error;
        break;
      case 'technician':
        roleName = 'Técnico';
        roleColor = colorScheme.primary;
        break;
      case 'assistant':
        roleName = 'Asistente';
        roleColor = colorScheme.secondary;
        break;
      default:
        roleName = member['role'];
        roleColor = colorScheme.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: roleColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        roleName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: roleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: iconName,
                  color: color,
                  size: 4.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String iconName,
    Color color,
  ) {
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
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleInfo(
      BuildContext context, Map<String, dynamic> schedule) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final workingDays = <String>[];
    final daysMap = {
      'monday': 'Lun',
      'tuesday': 'Mar',
      'wednesday': 'Mié',
      'thursday': 'Jue',
      'friday': 'Vie',
      'saturday': 'Sáb',
      'sunday': 'Dom',
    };

    daysMap.forEach((key, value) {
      final daySchedule = schedule[key] as Map<String, dynamic>?;
      if (daySchedule != null && (daySchedule['enabled'] ?? true)) {
        workingDays.add(value);
      }
    });

    return Card(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Días de trabajo',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              children: workingDays.map((day) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 1.w,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    day,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final permissions = member['permissions'] as Map<String, dynamic>? ?? {};

    final permissionIcons = {
      'booking_creation': 'event_note',
      'calendar_access': 'calendar_today',
      'customer_data': 'contacts',
      'reporting': 'analytics',
      'configuration': 'settings',
    };

    final permissionNames = {
      'booking_creation': 'Reservas',
      'calendar_access': 'Calendario',
      'customer_data': 'Clientes',
      'reporting': 'Reportes',
      'configuration': 'Configuración',
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          children: permissions.entries.map((entry) {
            final hasPermission = entry.value as bool? ?? false;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 1.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: permissionIcons[entry.key] ?? 'security',
                    color: hasPermission
                        ? colorScheme.tertiary
                        : colorScheme.outline,
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      permissionNames[entry.key] ?? entry.key,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasPermission
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  CustomIconWidget(
                    iconName: hasPermission ? 'check_circle' : 'cancel',
                    color: hasPermission
                        ? colorScheme.tertiary
                        : colorScheme.outline,
                    size: 4.w,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _isRecentlyActive(DateTime lastActive) {
    return DateTime.now().difference(lastActive).inMinutes < 15;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'hace ${weeks} semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'hace ${months} mes${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'hace ${years} año${years > 1 ? 's' : ''}';
    }
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} horas';
    } else {
      return 'hace ${difference.inDays} días';
    }
  }
}
