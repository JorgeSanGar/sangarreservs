import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TeamManagementWidget extends StatefulWidget {
  final List<Map<String, dynamic>> teamMembers;
  final Function(List<Map<String, dynamic>>) onTeamChanged;

  const TeamManagementWidget({
    super.key,
    required this.teamMembers,
    required this.onTeamChanged,
  });

  @override
  State<TeamManagementWidget> createState() => _TeamManagementWidgetState();
}

class _TeamManagementWidgetState extends State<TeamManagementWidget> {
  String _selectedRole = 'all';
  final List<String> _roles = ['all', 'manager', 'technician', 'admin'];

  final Map<String, String> _roleLabels = {
    'all': 'Todos',
    'manager': 'Gerente',
    'technician': 'Técnico',
    'admin': 'Administrador',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredMembers = _getFilteredMembers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with invite button
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'group',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de equipo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${widget.teamMembers.length} miembros en el equipo',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _inviteNewMember,
                icon: CustomIconWidget(
                  iconName: 'person_add',
                  color: Colors.white,
                  size: 4.w,
                ),
                label: const Text('Invitar'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 3.h),

        // Role filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            children: _roles.map((role) {
              final isSelected = _selectedRole == role;
              final count = role == 'all'
                  ? widget.teamMembers.length
                  : widget.teamMembers.where((m) => m['role'] == role).length;

              return Container(
                margin: EdgeInsets.only(right: 2.w),
                child: FilterChip(
                  selected: isSelected,
                  label: Text('${_roleLabels[role]} ($count)'),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRole = role);
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        SizedBox(height: 3.h),

        // Team members list
        if (filteredMembers.isEmpty) ...[
          _buildEmptyState(),
        ] else ...[
          ...filteredMembers.map((member) => _buildMemberCard(member)).toList(),
        ],

        SizedBox(height: 3.h),

        // Pending invitations section
        _buildPendingInvitations(),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredMembers() {
    if (_selectedRole == 'all') {
      return widget.teamMembers;
    }

    return widget.teamMembers.where((member) {
      return (member['role'] as String?) == _selectedRole;
    }).toList();
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'group',
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            _selectedRole == 'all'
                ? 'No hay miembros en el equipo'
                : 'No hay miembros con este rol',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Invita a tu equipo para comenzar a colaborar',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _inviteNewMember,
            icon: CustomIconWidget(
              iconName: 'person_add',
              color: Colors.white,
              size: 4.w,
            ),
            label: const Text('Invitar primer miembro'),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isActive = member['isActive'] as bool? ?? true;
    final role = member['role'] as String? ?? 'technician';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: () => _editMember(member),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 6.w,
                backgroundColor: _getRoleColor(role).withValues(alpha: 0.1),
                child: member['avatar'] != null
                    ? CustomImageWidget(
                        imageUrl: member['avatar'] as String,
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                      )
                    : CustomIconWidget(
                        iconName: 'person',
                        color: _getRoleColor(role),
                        size: 6.w,
                      ),
              ),

              SizedBox(width: 4.w),

              // Member info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member['name'] as String? ?? 'Miembro sin nombre',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Role badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _roleLabels[role] ?? role,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _getRoleColor(role),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      member['email'] as String? ?? 'Sin email',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (member['lastActive'] != null) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            size: 3.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Último acceso: ${member['lastActive']}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(width: 2.w),

              // Status and actions
              Column(
                children: [
                  // Status indicator
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // More actions
                  PopupMenuButton<String>(
                    icon: CustomIconWidget(
                      iconName: 'more_vert',
                      color: colorScheme.onSurfaceVariant,
                      size: 4.w,
                    ),
                    onSelected: (value) => _handleMemberAction(value, member),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: isActive ? 'deactivate' : 'activate',
                        child: Row(
                          children: [
                            Icon(isActive ? Icons.block : Icons.check_circle),
                            const SizedBox(width: 8),
                            Text(isActive ? 'Desactivar' : 'Activar'),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Eliminar',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPendingInvitations() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Mock pending invitations data
    final pendingInvitations = [
      {
        'id': 1,
        'email': 'carlos.martinez@email.com',
        'role': 'technician',
        'invitedAt': '2025-08-30',
        'expiresAt': '2025-09-06',
      },
      {
        'id': 2,
        'email': 'ana.rodriguez@email.com',
        'role': 'manager',
        'invitedAt': '2025-08-29',
        'expiresAt': '2025-09-05',
      },
    ];

    if (pendingInvitations.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'mail_outline',
                  color: colorScheme.secondary,
                  size: 5.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Invitaciones pendientes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${pendingInvitations.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...pendingInvitations.map((invitation) {
              return Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule_send',
                      color: colorScheme.secondary,
                      size: 4.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitation['email'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${_roleLabels[invitation['role']]} • Expira: ${invitation['expiresAt']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: CustomIconWidget(
                        iconName: 'more_vert',
                        color: colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      onSelected: (value) =>
                          _handleInvitationAction(value, invitation),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'resend',
                          child: Row(
                            children: [
                              Icon(Icons.refresh),
                              SizedBox(width: 8),
                              Text('Reenviar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Row(
                            children: [
                              Icon(Icons.cancel, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Cancelar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'admin':
        return AppTheme.errorLight;
      case 'technician':
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  void _inviteNewMember() {
    showDialog(
      context: context,
      builder: (context) => _InviteMemberDialog(
        onInvite: (inviteData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invitación enviada a ${inviteData['email']}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  void _editMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => _MemberEditorDialog(
        member: member,
        onSave: (memberData) {
          final updatedMembers = widget.teamMembers.map((m) {
            return m['id'] == memberData['id'] ? memberData : m;
          }).toList();
          widget.onTeamChanged(updatedMembers);
        },
      ),
    );
  }

  void _handleMemberAction(String action, Map<String, dynamic> member) {
    switch (action) {
      case 'edit':
        _editMember(member);
        break;
      case 'activate':
      case 'deactivate':
        final updatedMember = {...member, 'isActive': action == 'activate'};
        final updatedMembers = widget.teamMembers.map((m) {
          return m['id'] == updatedMember['id'] ? updatedMember : m;
        }).toList();
        widget.onTeamChanged(updatedMembers);
        break;
      case 'remove':
        _showRemoveMemberDialog(member);
        break;
    }
  }

  void _handleInvitationAction(String action, Map<String, dynamic> invitation) {
    switch (action) {
      case 'resend':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación reenviada a ${invitation['email']}'),
          ),
        );
        break;
      case 'cancel':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación cancelada para ${invitation['email']}'),
          ),
        );
        break;
    }
  }

  void _showRemoveMemberDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar miembro'),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${member['name']} del equipo? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedMembers = widget.teamMembers
                  .where((m) => m['id'] != member['id'])
                  .toList();
              widget.onTeamChanged(updatedMembers);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member['name']} eliminado del equipo'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
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
}

class _InviteMemberDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onInvite;

  const _InviteMemberDialog({required this.onInvite});

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedRole = 'technician';

  final Map<String, String> _roleLabels = {
    'manager': 'Gerente',
    'technician': 'Técnico',
    'admin': 'Administrador',
  };

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'person_add',
            color: colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          const Text('Invitar miembro'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'ejemplo@email.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es obligatorio';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
            SizedBox(height: 3.h),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rol',
              ),
              items: _roleLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final inviteData = {
                'email': _emailController.text.trim(),
                'role': _selectedRole,
                'invitedAt': DateTime.now().toIso8601String(),
              };

              widget.onInvite(inviteData);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Enviar invitación'),
        ),
      ],
    );
  }
}

class _MemberEditorDialog extends StatefulWidget {
  final Map<String, dynamic> member;
  final Function(Map<String, dynamic>) onSave;

  const _MemberEditorDialog({
    required this.member,
    required this.onSave,
  });

  @override
  State<_MemberEditorDialog> createState() => _MemberEditorDialogState();
}

class _MemberEditorDialogState extends State<_MemberEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedRole = 'technician';
  bool _isActive = true;

  final Map<String, String> _roleLabels = {
    'manager': 'Gerente',
    'technician': 'Técnico',
    'admin': 'Administrador',
  };

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.member['name'] as String? ?? '';
    _emailController.text = widget.member['email'] as String? ?? '';
    _selectedRole = widget.member['role'] as String? ?? 'technician';
    _isActive = widget.member['isActive'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'edit',
            color: colorScheme.primary,
            size: 6.w,
          ),
          SizedBox(width: 3.w),
          const Text('Editar miembro'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El email es obligatorio';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rol',
              ),
              items: _roleLabels.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
            ),
            SizedBox(height: 2.h),
            SwitchListTile(
              title: const Text('Miembro activo'),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final memberData = {
                ...widget.member,
                'name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'role': _selectedRole,
                'isActive': _isActive,
                'updatedAt': DateTime.now().toIso8601String(),
              };

              widget.onSave(memberData);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
