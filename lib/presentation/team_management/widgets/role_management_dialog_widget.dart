import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/team_service.dart';

class RoleManagementDialogWidget extends StatefulWidget {
  final Map<String, dynamic> member;

  const RoleManagementDialogWidget({
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  State<RoleManagementDialogWidget> createState() =>
      _RoleManagementDialogWidgetState();
}

class _RoleManagementDialogWidgetState
    extends State<RoleManagementDialogWidget> {
  late String _selectedRole;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'value': 'manager',
      'label': 'Manager',
      'description': 'Full access to manage team, bookings, and settings',
      'permissions': [
        'Manage team members',
        'Access all bookings',
        'View financial reports',
        'Configure workshop settings',
        'Access KPI dashboard',
      ],
      'icon': Icons.admin_panel_settings,
      'color': Colors.purple,
    },
    {
      'value': 'technician',
      'label': 'Technician',
      'description': 'Can manage bookings and customer interactions',
      'permissions': [
        'View and update bookings',
        'Access customer information',
        'Manage service progress',
        'Update booking status',
        'View basic reports',
      ],
      'icon': Icons.build,
      'color': Colors.blue,
    },
    {
      'value': 'assistant',
      'label': 'Assistant',
      'description': 'Limited access to help with daily operations',
      'permissions': [
        'View assigned bookings',
        'Update booking progress',
        'Access customer contact info',
        'View daily schedule',
      ],
      'icon': Icons.support_agent,
      'color': Colors.green,
    },
    {
      'value': 'worker',
      'label': 'Worker',
      'description': 'Basic access to assigned tasks only',
      'permissions': [
        'View own assignments',
        'Update task status',
        'Access basic customer info',
      ],
      'icon': Icons.person,
      'color': Colors.grey,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.member['role'] ?? 'worker';
  }

  Future<void> _updateRole() async {
    if (_selectedRole == widget.member['role']) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isLoading = true);

    try {
      await TeamService.updateMemberRole(
          widget.member['user_id'], _selectedRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.member['users'];
    final memberName =
        user['raw_user_meta_data']?['full_name'] ?? user['email'].split('@')[0];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxWidth: 600, maxHeight: 700),
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Role & Permissions',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color:
                              Theme.of(context).textTheme.headlineSmall?.color,
                        ),
                      ),
                      Text(
                        'for $memberName',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Current Role Info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(13),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withAlpha(51),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Role',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.member['role'].toString().toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Role Selection
            Text(
              'Select New Role',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];
                  final isSelected = _selectedRole == role['value'];
                  final isCurrent = widget.member['role'] == role['value'];

                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedRole = role['value']),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : isCurrent
                                    ? Colors.orange
                                    : Theme.of(context).dividerColor,
                            width: isSelected || isCurrent ? 2 : 1,
                          ),
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(13)
                              : isCurrent
                                  ? Colors.orange.withAlpha(13)
                                  : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Role header
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: role['color'].withAlpha(26),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    role['icon'],
                                    color: role['color'],
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            role['label'],
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.color,
                                            ),
                                          ),
                                          if (isCurrent) ...[
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.orange.withAlpha(51),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'CURRENT',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        role['description'],
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Radio<String>(
                                  value: role['value'],
                                  groupValue: _selectedRole,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedRole = value);
                                    }
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 12),

                            // Permissions list
                            Text(
                              'Permissions:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.color,
                              ),
                            ),
                            SizedBox(height: 8),

                            ...role['permissions']
                                .map<Widget>((permission) => Padding(
                                      padding: EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 14,
                                            color: role['color'],
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              permission,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Warning message for role change
            if (_selectedRole != widget.member['role']) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(77)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Changing roles will immediately update the member\'s access permissions.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateRole,
                  child: _isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_selectedRole == widget.member['role']
                          ? 'Close'
                          : 'Update Role'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
