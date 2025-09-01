import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TrendIndicatorWidget extends StatelessWidget {
  final double currentValue;
  final double previousValue;
  final String trend;
  final bool isReversed;

  const TrendIndicatorWidget({
    super.key,
    required this.currentValue,
    required this.previousValue,
    required this.trend,
    this.isReversed = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final percentageChange =
        ((currentValue - previousValue) / previousValue * 100).abs();
    final isPositive = trend == 'up';
    final actuallyGood = isReversed ? !isPositive : isPositive;

    final color = actuallyGood ? colorScheme.tertiary : colorScheme.error;
    final iconName = isPositive ? 'trending_up' : 'trending_down';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 3.w,
          ),
          SizedBox(width: 1.w),
          Text(
            '${percentageChange.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
