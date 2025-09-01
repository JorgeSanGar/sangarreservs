import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ResourceLaneWidget extends StatelessWidget {
  final Map<String, dynamic> resource;
  final List<Map<String, dynamic>> bookings;
  final DateTime startTime;
  final DateTime endTime;
  final double timeSlotWidth;
  final Function(Map<String, dynamic> booking) onBookingTap;
  final Function(Map<String, dynamic> booking) onBookingLongPress;
  final Function(DateTime time, String resourceId) onEmptySlotLongPress;

  const ResourceLaneWidget({
    super.key,
    required this.resource,
    required this.bookings,
    required this.startTime,
    required this.endTime,
    required this.timeSlotWidth,
    required this.onBookingTap,
    required this.onBookingLongPress,
    required this.onEmptySlotLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Resource Header
          Container(
            width: 20.w,
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              border: Border(
                right: BorderSide(
                  color: AppTheme.lightTheme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getResourceIcon(),
                      color: _getResourceColor(),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        resource['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  resource['type'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Timeline Area
          Expanded(
            child: GestureDetector(
              onLongPressStart: (details) {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final localPosition =
                    renderBox.globalToLocal(details.globalPosition);
                final timeOffset = (localPosition.dx - 20.w) / timeSlotWidth;
                final selectedTime =
                    startTime.add(Duration(minutes: (timeOffset * 60).round()));
                onEmptySlotLongPress(selectedTime, resource['id'] as String);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _isResourceAvailable()
                      ? AppTheme.lightTheme.colorScheme.surface
                      : AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                ),
                child: Stack(
                  children: [
                    // Working Hours Background
                    _buildWorkingHoursBackground(),

                    // Time Grid Lines
                    _buildTimeGridLines(),

                    // Booking Blocks
                    ..._buildBookingBlocks(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursBackground() {
    final workingHours = resource['workingHours'] as Map<String, dynamic>?;
    if (workingHours == null) return const SizedBox.shrink();

    final startHour = workingHours['start'] as int? ?? 8;
    final endHour = workingHours['end'] as int? ?? 18;
    final breaks = workingHours['breaks'] as List<dynamic>? ?? [];

    return Positioned.fill(
      child: CustomPaint(
        painter: WorkingHoursPainter(
          startTime: startTime,
          endTime: endTime,
          workingStartHour: startHour,
          workingEndHour: endHour,
          breaks: breaks.cast<Map<String, dynamic>>(),
          timeSlotWidth: timeSlotWidth,
          workingColor: AppTheme.lightTheme.colorScheme.surface,
          nonWorkingColor: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildTimeGridLines() {
    return Positioned.fill(
      child: CustomPaint(
        painter: TimeGridPainter(
          startTime: startTime,
          endTime: endTime,
          timeSlotWidth: timeSlotWidth,
          gridColor: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  List<Widget> _buildBookingBlocks() {
    return bookings.map((booking) {
      final bookingStart = DateTime.parse(booking['startTime'] as String);
      final bookingEnd = DateTime.parse(booking['endTime'] as String);

      final startOffset = bookingStart.difference(startTime).inMinutes / 60.0;
      final duration = bookingEnd.difference(bookingStart).inMinutes / 60.0;

      final left = startOffset * timeSlotWidth;
      final width = duration * timeSlotWidth;

      return Positioned(
        left: left,
        top: 1.h,
        width: width,
        height: 10.h,
        child: GestureDetector(
          onTap: () => onBookingTap(booking),
          onLongPress: () => onBookingLongPress(booking),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1),
            decoration: BoxDecoration(
              color: _getBookingColor(booking['status'] as String),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _getBookingBorderColor(booking['status'] as String),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(1.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    booking['customerName'] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getBookingTextColor(booking['status'] as String),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    booking['serviceType'] as String,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getBookingTextColor(booking['status'] as String)
                          .withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${_formatTime(bookingStart)} - ${_formatTime(bookingEnd)}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getBookingTextColor(booking['status'] as String)
                          .withValues(alpha: 0.7),
                      fontSize: 10.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  String _getResourceIcon() {
    switch (resource['type'] as String) {
      case 'Elevador':
        return 'elevator';
      case 'Bahía':
        return 'garage';
      case 'Técnico':
        return 'person';
      default:
        return 'build';
    }
  }

  Color _getResourceColor() {
    switch (resource['type'] as String) {
      case 'Elevador':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'Bahía':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'Técnico':
        return AppTheme.lightTheme.colorScheme.secondary;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  bool _isResourceAvailable() {
    final availability = resource['availability'] as Map<String, dynamic>?;
    return availability?['isAvailable'] as bool? ?? true;
  }

  Color _getBookingColor(String status) {
    switch (status.toLowerCase()) {
      case 'programada':
        return AppTheme.lightTheme.colorScheme.primaryContainer;
      case 'en_progreso':
        return AppTheme.lightTheme.colorScheme.tertiaryContainer;
      case 'completada':
        return AppTheme.lightTheme.colorScheme.secondaryContainer;
      case 'cancelada':
        return AppTheme.lightTheme.colorScheme.errorContainer;
      default:
        return AppTheme.lightTheme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _getBookingBorderColor(String status) {
    switch (status.toLowerCase()) {
      case 'programada':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'en_progreso':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'completada':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'cancelada':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.outline;
    }
  }

  Color _getBookingTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'programada':
        return AppTheme.lightTheme.colorScheme.onPrimaryContainer;
      case 'en_progreso':
        return AppTheme.lightTheme.colorScheme.onTertiaryContainer;
      case 'completada':
        return AppTheme.lightTheme.colorScheme.onSecondaryContainer;
      case 'cancelada':
        return AppTheme.lightTheme.colorScheme.onErrorContainer;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class WorkingHoursPainter extends CustomPainter {
  final DateTime startTime;
  final DateTime endTime;
  final int workingStartHour;
  final int workingEndHour;
  final List<Map<String, dynamic>> breaks;
  final double timeSlotWidth;
  final Color workingColor;
  final Color nonWorkingColor;

  WorkingHoursPainter({
    required this.startTime,
    required this.endTime,
    required this.workingStartHour,
    required this.workingEndHour,
    required this.breaks,
    required this.timeSlotWidth,
    required this.workingColor,
    required this.nonWorkingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Paint non-working hours
    paint.color = nonWorkingColor;

    // Before working hours
    if (startTime.hour < workingStartHour) {
      final nonWorkingWidth =
          (workingStartHour - startTime.hour) * timeSlotWidth;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, nonWorkingWidth, size.height),
        paint,
      );
    }

    // After working hours
    if (endTime.hour > workingEndHour) {
      final startX = (workingEndHour - startTime.hour) * timeSlotWidth;
      final nonWorkingWidth = (endTime.hour - workingEndHour) * timeSlotWidth;
      canvas.drawRect(
        Rect.fromLTWH(startX, 0, nonWorkingWidth, size.height),
        paint,
      );
    }

    // Paint break times
    for (final breakTime in breaks) {
      final breakStart = breakTime['start'] as int;
      final breakEnd = breakTime['end'] as int;

      if (breakStart >= startTime.hour && breakEnd <= endTime.hour) {
        final startX = (breakStart - startTime.hour) * timeSlotWidth;
        final width = (breakEnd - breakStart) * timeSlotWidth;

        canvas.drawRect(
          Rect.fromLTWH(startX, 0, width, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TimeGridPainter extends CustomPainter {
  final DateTime startTime;
  final DateTime endTime;
  final double timeSlotWidth;
  final Color gridColor;

  TimeGridPainter({
    required this.startTime,
    required this.endTime,
    required this.timeSlotWidth,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    final totalHours = endTime.difference(startTime).inHours;

    for (int i = 0; i <= totalHours; i++) {
      final x = i * timeSlotWidth;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
