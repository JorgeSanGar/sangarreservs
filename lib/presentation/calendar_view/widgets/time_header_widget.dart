import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimeHeaderWidget extends StatelessWidget {
  final DateTime startTime;
  final DateTime endTime;
  final double timeSlotWidth;
  final bool showCurrentTime;

  const TimeHeaderWidget({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.timeSlotWidth,
    this.showCurrentTime = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Empty space for resource header
          Container(
            width: 20.w,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Center(
              child: Text(
                'Recursos',
                style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Time slots
          Expanded(
            child: Stack(
              children: [
                // Time labels
                _buildTimeLabels(),

                // Current time indicator
                if (showCurrentTime) _buildCurrentTimeIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeLabels() {
    final totalHours = endTime.difference(startTime).inHours;

    return Row(
      children: List.generate(totalHours + 1, (index) {
        final time = startTime.add(Duration(hours: index));
        final isLastItem = index == totalHours;

        return Container(
          width: isLastItem ? null : timeSlotWidth,
          child: isLastItem
              ? null
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${time.hour.toString().padLeft(2, '0')}:00',
                      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      height: 2,
                      width: 1,
                      color: AppTheme.lightTheme.dividerColor,
                    ),
                  ],
                ),
        );
      }),
    );
  }

  Widget _buildCurrentTimeIndicator() {
    final now = DateTime.now();

    // Check if current time is within the displayed range
    if (now.isBefore(startTime) || now.isAfter(endTime)) {
      return const SizedBox.shrink();
    }

    final minutesFromStart = now.difference(startTime).inMinutes;
    final position = (minutesFromStart / 60.0) * timeSlotWidth;

    return Positioned(
      left: position,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.error,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Container(
                width: 2,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
