import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime selectedDate;
  final bool isWeekView;
  final VoidCallback onToggleView;
  final VoidCallback onDatePicker;
  final VoidCallback onFilter;

  const CalendarHeaderWidget({
    super.key,
    required this.selectedDate,
    required this.isWeekView,
    required this.onToggleView,
    required this.onDatePicker,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Month/Week Toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  context,
                  'Semana',
                  isWeekView,
                  () => onToggleView(),
                ),
                _buildToggleButton(
                  context,
                  'Mes',
                  !isWeekView,
                  () => onToggleView(),
                ),
              ],
            ),
          ),

          SizedBox(width: 3.w),

          // Date Display
          Expanded(
            child: GestureDetector(
              onTap: onDatePicker,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDateDisplay(),
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color:
                            AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 3.w),

          // Filter Button
          GestureDetector(
            onTap: onFilter,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'filter_list',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onPrimary
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDateDisplay() {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];

    if (isWeekView) {
      final startOfWeek =
          selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      if (startOfWeek.month == endOfWeek.month) {
        return '${startOfWeek.day}-${endOfWeek.day} ${months[startOfWeek.month - 1]} ${startOfWeek.year}';
      } else {
        return '${startOfWeek.day} ${months[startOfWeek.month - 1]} - ${endOfWeek.day} ${months[endOfWeek.month - 1]} ${endOfWeek.year}';
      }
    } else {
      return '${months[selectedDate.month - 1]} ${selectedDate.year}';
    }
  }
}
