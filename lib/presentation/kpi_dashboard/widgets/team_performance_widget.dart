import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeamPerformanceWidget extends StatelessWidget {
  final List<Map<String, dynamic>> teamData;

  const TeamPerformanceWidget({
    Key? key,
    required this.teamData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (teamData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color:
                  Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(128),
            ),
            SizedBox(height: 16),
            Text(
              'No team data available',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Team performance metrics will appear here once team members are added',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Overview Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Overview',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildOverviewStat(
                        context,
                        'Total Members',
                        teamData.length.toString(),
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildOverviewStat(
                        context,
                        'Active Members',
                        teamData
                            .where((m) => m['role'] != 'inactive')
                            .length
                            .toString(),
                        Icons.help_outline,
                        Colors.green,
                      ),
                      _buildOverviewStat(
                        context,
                        'Managers',
                        teamData
                            .where((m) => m['role'] == 'manager')
                            .length
                            .toString(),
                        Icons.admin_panel_settings,
                        Colors.purple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Individual Team Member Cards
          Text(
            'Team Members Performance',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          SizedBox(height: 12),

          ...teamData.map((member) => _buildTeamMemberCard(context, member)),

          SizedBox(height: 16),

          // Role Distribution Chart
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Distribution',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  SizedBox(height: 16),
                  ..._getRoleDistribution().entries.map((entry) =>
                      _buildRoleDistributionItem(
                          context, entry.key, entry.value)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTeamMemberCard(
      BuildContext context, Map<String, dynamic> member) {
    final role = member['role'] as String;
    final name = member['name'] as String;
    final email = member['email'] as String;

    Color roleColor = _getRoleColor(role);
    IconData roleIcon = _getRoleIcon(role);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: roleColor.withAlpha(51),
                  child: Text(
                    name[0].toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: roleColor.withAlpha(77)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 14, color: roleColor),
                      SizedBox(width: 4),
                      Text(
                        role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: roleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Performance Metrics (placeholder data since we don't have actual performance tracking)
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceMetric(
                    context,
                    'Tasks Completed',
                    member['total_bookings'].toString(),
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    context,
                    'Success Rate',
                    '${(member['completed_bookings'] / (member['total_bookings'] > 0 ? member['total_bookings'] : 1) * 100).toStringAsFixed(0)}%',
                    Icons.trending_up,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceMetric(
                    context,
                    'Avg Rating',
                    member['avg_rating'].toStringAsFixed(1),
                    Icons.star,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon,
            size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleDistributionItem(
      BuildContext context, String role, int count) {
    final total = teamData.length;
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    final color = _getRoleColor(role);
    final icon = _getRoleIcon(role);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      role.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    Text(
                      '$count (${percentage.toStringAsFixed(1)}%)',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withAlpha(51),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getRoleDistribution() {
    Map<String, int> distribution = {};
    for (var member in teamData) {
      final role = member['role'] as String;
      distribution[role] = (distribution[role] ?? 0) + 1;
    }
    return distribution;
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return Colors.purple;
      case 'technician':
        return Colors.blue;
      case 'assistant':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return Icons.admin_panel_settings;
      case 'technician':
        return Icons.build;
      case 'assistant':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }
}
