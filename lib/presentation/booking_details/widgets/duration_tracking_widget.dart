import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class DurationTrackingWidget extends StatefulWidget {
  final String bookingStatus;
  final DateTime? serviceStartTime;
  final Duration? pausedDuration;
  final bool isPaused;
  final Function(Duration duration)? onDurationUpdate;

  const DurationTrackingWidget({
    super.key,
    required this.bookingStatus,
    this.serviceStartTime,
    this.pausedDuration,
    this.isPaused = false,
    this.onDurationUpdate,
  });

  @override
  State<DurationTrackingWidget> createState() => _DurationTrackingWidgetState();
}

class _DurationTrackingWidgetState extends State<DurationTrackingWidget> {
  Timer? _timer;
  Duration _currentDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeDuration();
    _startTimer();
  }

  @override
  void didUpdateWidget(DurationTrackingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused ||
        oldWidget.bookingStatus != widget.bookingStatus) {
      _handleTimerState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeDuration() {
    if (widget.serviceStartTime != null) {
      final elapsed = DateTime.now().difference(widget.serviceStartTime!);
      _currentDuration = elapsed - (widget.pausedDuration ?? Duration.zero);
    }
  }

  void _startTimer() {
    if (widget.bookingStatus.toLowerCase() == 'en_progreso' ||
        widget.bookingStatus.toLowerCase() == 'in_progress') {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!widget.isPaused) {
          setState(() {
            _currentDuration = _currentDuration + const Duration(seconds: 1);
          });
          widget.onDurationUpdate?.call(_currentDuration);
        }
      });
    }
  }

  void _handleTimerState() {
    _timer?.cancel();
    if (widget.bookingStatus.toLowerCase() == 'en_progreso' ||
        widget.bookingStatus.toLowerCase() == 'in_progress') {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.bookingStatus.toLowerCase() != 'en_progreso' &&
        widget.bookingStatus.toLowerCase() != 'in_progress') {
      return const SizedBox.shrink();
    }

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
                    color: widget.isPaused
                        ? AppTheme.warningLight.withValues(alpha: 0.1)
                        : AppTheme.successLight.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: widget.isPaused ? 'pause' : 'timer',
                    color: widget.isPaused
                        ? AppTheme.warningLight
                        : AppTheme.successLight,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Seguimiento de Duración',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.isPaused
                            ? 'Servicio Pausado'
                            : 'Servicio en Progreso',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: widget.isPaused
                              ? AppTheme.warningLight
                              : AppTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isPaused
                      ? AppTheme.warningLight.withValues(alpha: 0.3)
                      : AppTheme.successLight.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Tiempo Transcurrido',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    _formatDuration(_currentDuration),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      color: widget.isPaused
                          ? AppTheme.warningLight
                          : AppTheme.successLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName:
                            widget.isPaused ? 'pause_circle' : 'play_circle',
                        color: widget.isPaused
                            ? AppTheme.warningLight
                            : AppTheme.successLight,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        widget.isPaused ? 'Pausado' : 'Activo',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.isPaused
                              ? AppTheme.warningLight
                              : AppTheme.successLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            _buildDurationStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Inicio',
            widget.serviceStartTime != null
                ? '${widget.serviceStartTime!.hour.toString().padLeft(2, '0')}:${widget.serviceStartTime!.minute.toString().padLeft(2, '0')}'
                : '--:--',
            Icons.play_arrow_rounded,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatItem(
            context,
            'Pausas',
            widget.pausedDuration != null
                ? _formatDuration(widget.pausedDuration!)
                : '00:00',
            Icons.pause_rounded,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildStatItem(
            context,
            'Estimado',
            '45 min',
            Icons.schedule_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: _getIconName(icon),
            color: colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.play_arrow_rounded) return 'play_arrow';
    if (icon == Icons.pause_rounded) return 'pause';
    if (icon == Icons.schedule_rounded) return 'schedule';
    return 'info';
  }
}