import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RoleManagementModal extends StatefulWidget {
  final Map<String, dynamic> member;
  final Function(Map<String, dynamic>) onSave;

  const RoleManagementModal({
    super.key,
    required this.member,
    required this.onSave,
  });

  @override
  State<RoleManagementModal> createState() => _RoleManagementModalState();
}

class _RoleManagementModalState extends State<RoleManagementModal> {
  late String _selectedRole;
  late Map<String, bool> _permissions;

  final Map<String, String> _roleNames = {
    'manager': 'Gerente',
    'technician': 'Técnico',
    'assistant': 'Asistente',
  };

  final Map<String, Map<String, dynamic>> _rolePermissions = {
    'manager': {
      'booking_creation': true,
      'calendar_access': true,
      'customer_data': true,
      'reporting': true,
      'configuration': true,
    },
    'technician': {
      'booking_creation': true,
      'calendar_access': true,
      'customer_data': false,
      'reporting': false,
      'configuration': false,
    },
    'assistant': {
      'booking_creation': false,
      'calendar_access': true,
      'customer_data': false,
      'reporting': false,
      'configuration': false,
    },
  };

  final Map<String, String> _permissionNames = {
    'booking_creation': 'Crear reservas',
    'calendar_access': 'Acceso al calendario',
    'customer_data': 'Datos de clientes',
    'reporting': 'Reportes y analíticas',
    'configuration': 'Configuración del taller',
  };

  final Map<String, String> _permissionDescriptions = {
    'booking_creation':
        'Permite crear, modificar y eliminar reservas de servicio',
    'calendar_access': 'Ver y gestionar el calendario de citas del taller',
    'customer_data': 'Acceder y modificar información personal de clientes',
    'reporting': 'Generar reportes y ver métricas de rendimiento',
    'configuration': 'Modificar configuración del taller y gestionar equipo',
  };

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member['role'] ?? 'assistant';
    _permissions = Map<String, bool>.from(widget.member['permissions'] ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'security',
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestionar permisos',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          widget.member['name'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role selection
                    Text(
                      'Rol del miembro',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    ..._roleNames.entries.map((entry) {
                      return _buildRoleOption(context, entry.key, entry.value);
                    }).toList(),

                    SizedBox(height: 3.h),

                    // Permissions matrix
                    Text(
                      'Permisos específicos',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Personaliza los permisos para este miembro del equipo',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    ..._permissionNames.entries.map((entry) {
                      return _buildPermissionTile(
                          context, entry.key, entry.value);
                    }).toList(),

                    SizedBox(height: 3.h),

                    // Role preset info
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'info',
                                color: colorScheme.primary,
                                size: 4.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Configuraciones predeterminadas',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            _getRoleDescription(_selectedRole),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePermissions,
                      child: const Text('Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
      BuildContext context, String roleKey, String roleName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedRole == roleKey;

    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRole = roleKey;
            // Update permissions to role defaults
            _permissions =
                Map<String, bool>.from(_rolePermissions[roleKey] ?? {});
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: isSelected
                      ? 'radio_button_checked'
                      : 'radio_button_unchecked',
                  color:
                      isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                  size: 4.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _getRoleDescription(roleKey),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
      BuildContext context, String permissionKey, String permissionName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabled = _permissions[permissionKey] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: _getPermissionIcon(permissionKey),
                color: isEnabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permissionName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _permissionDescriptions[permissionKey] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    _permissions[permissionKey] = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleDescription(String role) {
    switch (role) {
      case 'manager':
        return 'Acceso completo a todas las funciones del sistema';
      case 'technician':
        return 'Puede gestionar reservas y acceder al calendario';
      case 'assistant':
        return 'Acceso básico para tareas de apoyo';
      default:
        return '';
    }
  }

  String _getPermissionIcon(String permission) {
    switch (permission) {
      case 'booking_creation':
        return 'event_note';
      case 'calendar_access':
        return 'calendar_today';
      case 'customer_data':
        return 'contacts';
      case 'reporting':
        return 'analytics';
      case 'configuration':
        return 'settings';
      default:
        return 'security';
    }
  }

  void _savePermissions() {
    final updatedMember = {
      ...widget.member,
      'role': _selectedRole,
      'permissions': _permissions,
    };

    widget.onSave(updatedMember);
    Navigator.of(context).pop();
  }
}
