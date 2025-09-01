import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KpiMetricCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double trend;

  const KpiMetricCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trend = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and trend row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (trend != 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTrendColor().withAlpha(26),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend > 0 ? Icons.trending_up : Icons.trending_down,
                          size: 12,
                          color: _getTrendColor(),
                        ),
                        SizedBox(width: 2),
                        Text(
                          '${trend.abs().toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getTrendColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12),

            // Value
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineMedium?.color,
              ),
            ),

            SizedBox(height: 4),

            // Title
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrendColor() {
    if (trend > 0) return Colors.green;
    if (trend < 0) return Colors.red;
    return Colors.grey;
  }
}
