import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class BookingTimelineWidget extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingTimelineWidget({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeline = booking['timeline'] as List<Map<String, dynamic>>;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'timeline',
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Cronología de la Cita',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timeline.length,
              itemBuilder: (context, index) {
                final event = timeline[index];
                final isLast = index == timeline.length - 1;
                final isCompleted = event['completed'] as bool;
                final isCurrent = event['current'] as bool? ?? false;

                return _buildTimelineItem(
                  context,
                  event,
                  isLast,
                  isCompleted,
                  isCurrent,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> event,
    bool isLast,
    bool isCompleted,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color dotColor;
    Color lineColor;
    Color textColor;

    if (isCompleted) {
      dotColor = AppTheme.successLight;
      lineColor = AppTheme.successLight.withValues(alpha: 0.3);
      textColor = colorScheme.onSurface;
    } else if (isCurrent) {
      dotColor = AppTheme.warningLight;
      lineColor = colorScheme.outline;
      textColor = colorScheme.onSurface;
    } else {
      dotColor = colorScheme.outline;
      lineColor = colorScheme.outline.withValues(alpha: 0.3);
      textColor = colorScheme.onSurfaceVariant;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: dotColor,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 8,
                      ),
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 6.h,
                color: lineColor,
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (event['description'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    event['description'] as String,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (event['timestamp'] != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        event['timestamp'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
                if (event['user'] != null) ...[
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'person',
                        color: colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        event['user'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}