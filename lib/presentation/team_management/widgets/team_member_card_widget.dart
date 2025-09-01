import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TeamMemberCardWidget extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback? onTap;
  final VoidCallback onEditRole;
  final VoidCallback onRemove;

  const TeamMemberCardWidget({
    Key? key,
    required this.member,
    this.onTap,
    required this.onEditRole,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = member['users'];
    final email = user['email'] as String;
    final role = member['role'] as String;
    final joinedAt = DateTime.parse(member['joined_at']);
    final metadata = user['raw_user_meta_data'] as Map<String, dynamic>?;

    final name = metadata?['full_name'] ?? email.split('@')[0];
    final avatarUrl = metadata?['avatar_url'] as String?;
    final phone = metadata?['phone'] as String?;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with avatar, name, and actions
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withAlpha(51),
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12),

                  // Name and email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit_role') {
                        onEditRole();
                      } else if (value == 'remove') {
                        onRemove();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit_role',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit Role'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Remove', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(Icons.more_vert),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Role and status badges
              Row(
                children: [
                  _buildRoleBadge(role),
                  SizedBox(width: 8),
                  _buildStatusBadge('Active', Colors.green),
                  if (phone != null) ...[
                    SizedBox(width: 8),
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                  ],
                ],
              ),

              SizedBox(height: 8),

              // Additional information
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    'Joined ${_formatJoinDate(joinedAt)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  if (phone != null) ...[
                    SizedBox(width: 16),
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      phone,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ],
              ),

              // Specialization badges (if available)
              if (metadata?['specializations'] != null) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (metadata!['specializations'] as List<dynamic>)
                      .map((spec) => Chip(
                            label: Text(
                              spec.toString(),
                              style: GoogleFonts.inter(fontSize: 10),
                            ),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withAlpha(51),
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    IconData icon;

    switch (role.toLowerCase()) {
      case 'manager':
        color = Colors.purple;
        icon = Icons.admin_panel_settings;
        break;
      case 'technician':
        color = Colors.blue;
        icon = Icons.build;
        break;
      case 'assistant':
        color = Colors.green;
        icon = Icons.support_agent;
        break;
      default:
        color = Colors.grey;
        icon = Icons.person;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            role.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    }
  }
}
