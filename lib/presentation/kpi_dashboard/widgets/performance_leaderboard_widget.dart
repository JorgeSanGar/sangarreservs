import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PerformanceLeaderboardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> teamData;

  const PerformanceLeaderboardWidget({
    super.key,
    required this.teamData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sort team members by efficiency
    final sortedTeam = List<Map<String, dynamic>>.from(teamData)
      ..sort(
          (a, b) => (b['efficiency'] as int).compareTo(a['efficiency'] as int));

    return Card(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Ranking de Rendimiento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'emoji_events',
                  color: colorScheme.tertiary,
                  size: 5.w,
                ),
              ],
            ),

            SizedBox(height: 1.h),

            Text(
              'Clasificación por eficiencia y rendimiento',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 3.h),

            // Top 3 podium
            if (sortedTeam.isNotEmpty) ...[
              _buildPodium(context, sortedTeam.take(3).toList()),
              SizedBox(height: 3.h),
            ],

            // Full leaderboard
            ...sortedTeam.asMap().entries.map((entry) {
              final index = entry.key;
              final member = entry.value;

              return _buildLeaderboardItem(
                context,
                member,
                index + 1,
                index < 3, // Is top 3
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(
      BuildContext context, List<Map<String, dynamic>> topThree) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (topThree.length < 3) return const SizedBox.shrink();

    return Container(
      height: 25.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Second place
          Expanded(
            child: _buildPodiumPosition(
              context,
              topThree[1],
              2,
              18.h,
              colorScheme.secondary,
            ),
          ),

          // First place (tallest)
          Expanded(
            child: _buildPodiumPosition(
              context,
              topThree[0],
              1,
              22.h,
              colorScheme.tertiary,
            ),
          ),

          // Third place
          Expanded(
            child: _buildPodiumPosition(
              context,
              topThree[2],
              3,
              15.h,
              colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(
    BuildContext context,
    Map<String, dynamic> member,
    int position,
    double height,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Medal
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Text(
            position.toString(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(height: 1.h),

        // Avatar
        CircleAvatar(
          radius: 6.w,
          backgroundImage: CachedNetworkImageProvider(member['avatar']),
        ),

        SizedBox(height: 1.h),

        // Name
        Text(
          member['name'].split(' ')[0],
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        // Efficiency
        Text(
          '${member['efficiency']}%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 1.h),

        // Podium base
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    Map<String, dynamic> member,
    int position,
    bool isTopThree,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color positionColor = colorScheme.onSurfaceVariant;
    if (position == 1)
      positionColor = colorScheme.tertiary;
    else if (position == 2)
      positionColor = colorScheme.secondary;
    else if (position == 3) positionColor = colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isTopThree
            ? positionColor.withValues(alpha: 0.05)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isTopThree
            ? Border.all(color: positionColor.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        children: [
          // Position indicator
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: positionColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Avatar
          CircleAvatar(
            radius: 6.w,
            backgroundImage: CachedNetworkImageProvider(member['avatar']),
          ),

          SizedBox(width: 3.w),

          // Member info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'build',
                      color: colorScheme.onSurfaceVariant,
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${member['completedServices']} servicios',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Performance metrics
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${member['efficiency']}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: positionColor,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: positionColor,
                    size: 4.w,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: colorScheme.tertiary,
                    size: 3.w,
                  ),
                  SizedBox(width: 0.5.w),
                  Text(
                    '${member['customerRating']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isTopThree) ...[
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: position <= 3 ? 'emoji_events' : 'trending_up',
              color: positionColor,
              size: 5.w,
            ),
          ],
        ],
      ),
    );
  }
}
