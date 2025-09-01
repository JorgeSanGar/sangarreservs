import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class KpiService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Gets comprehensive KPI statistics for dashboard
  static Future<Map<String, dynamic>> getKpiStatistics() async {
    try {
      // Get total bookings count
      final totalBookingsResponse = await _client
          .from('bookings')
          .select('id')
          .isFilter('deleted_at', null)
          .count();

      // Get completed bookings count
      final completedBookingsResponse = await _client
          .from('bookings')
          .select('id')
          .eq('status', 'completed')
          .isFilter('deleted_at', null)
          .count();

      // Get today's bookings
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final todayBookingsResponse = await _client
          .from('bookings')
          .select('id')
          .gte('start_time', startOfDay.toIso8601String())
          .lt('start_time', endOfDay.toIso8601String())
          .isFilter('deleted_at', null)
          .count();

      // Get revenue data (sum of service prices for completed bookings)
      final revenueResponse = await _client.from('bookings').select('''
            services!inner (
              price
            )
          ''').eq('status', 'completed').isFilter('deleted_at', null);

      double totalRevenue = 0;
      for (var booking in revenueResponse) {
        if (booking['services'] != null &&
            booking['services']['price'] != null) {
          totalRevenue += (booking['services']['price'] as num).toDouble();
        }
      }

      // Get average service duration
      final durationResponse = await _client
          .from('bookings')
          .select('actual_minutes')
          .not('actual_minutes', 'is', null)
          .isFilter('deleted_at', null);

      double avgDuration = 0;
      if (durationResponse.isNotEmpty) {
        int totalMinutes = 0;
        for (var booking in durationResponse) {
          totalMinutes += booking['actual_minutes'] as int;
        }
        avgDuration = totalMinutes / durationResponse.length;
      }

      // Get team member count
      final teamCountResponse =
          await _client.from('org_members').select('id').count();

      // Calculate completion rate
      final totalBookings = totalBookingsResponse.count ?? 0;
      final completedBookings = completedBookingsResponse.count ?? 0;
      final completionRate =
          totalBookings > 0 ? (completedBookings / totalBookings * 100) : 0.0;

      return {
        'total_bookings': totalBookings,
        'completed_bookings': completedBookings,
        'today_bookings': todayBookingsResponse.count ?? 0,
        'total_revenue': totalRevenue,
        'average_duration': avgDuration,
        'team_count': teamCountResponse.count ?? 0,
        'completion_rate': double.parse(completionRate.toStringAsFixed(2)),
      };
    } catch (error) {
      throw Exception('Failed to fetch KPI statistics: $error');
    }
  }

  /// Gets daily revenue data for charts
  static Future<List<Map<String, dynamic>>> getDailyRevenue(
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('bookings')
          .select('''
            start_time,
            services!inner (
              price
            )
          ''')
          .eq('status', 'completed')
          .gte('start_time', startDate.toIso8601String())
          .isFilter('deleted_at', null)
          .order('start_time', ascending: true);

      // Group by date and sum revenue
      Map<String, double> dailyRevenue = {};
      for (var booking in response) {
        final date = DateTime.parse(booking['start_time'])
            .toIso8601String()
            .split('T')[0];
        final price = (booking['services']['price'] as num).toDouble();
        dailyRevenue[date] = (dailyRevenue[date] ?? 0) + price;
      }

      return dailyRevenue.entries
          .map((entry) => {
                'date': entry.key,
                'revenue': entry.value,
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch daily revenue: $error');
    }
  }

  /// Gets booking completion rate over time
  static Future<List<Map<String, dynamic>>> getCompletionRateData(
      {int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final response = await _client
          .from('bookings')
          .select('start_time, status')
          .gte('start_time', startDate.toIso8601String())
          .isFilter('deleted_at', null)
          .order('start_time', ascending: true);

      // Group by date and calculate completion rate
      Map<String, Map<String, int>> dailyStats = {};
      for (var booking in response) {
        final date = DateTime.parse(booking['start_time'])
            .toIso8601String()
            .split('T')[0];
        dailyStats[date] ??= {'total': 0, 'completed': 0};
        dailyStats[date]!['total'] = dailyStats[date]!['total']! + 1;
        if (booking['status'] == 'completed') {
          dailyStats[date]!['completed'] = dailyStats[date]!['completed']! + 1;
        }
      }

      return dailyStats.entries
          .map((entry) => {
                'date': entry.key,
                'completion_rate': entry.value['total']! > 0
                    ? (entry.value['completed']! / entry.value['total']! * 100)
                    : 0.0,
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch completion rate data: $error');
    }
  }

  /// Gets service category performance
  static Future<List<Map<String, dynamic>>>
      getServiceCategoryPerformance() async {
    try {
      final response = await _client.from('services').select('''
            category,
            bookings!inner (
              status,
              actual_minutes
            )
          ''');

      // Group by category and calculate metrics
      Map<String, Map<String, dynamic>> categoryStats = {};
      for (var service in response) {
        final category = service['category'] as String;
        categoryStats[category] ??= {
          'total_bookings': 0,
          'completed_bookings': 0,
          'total_duration': 0,
        };

        final bookings = service['bookings'] as List;
        for (var booking in bookings) {
          categoryStats[category]!['total_bookings']++;
          if (booking['status'] == 'completed') {
            categoryStats[category]!['completed_bookings']++;
            if (booking['actual_minutes'] != null) {
              categoryStats[category]!['total_duration'] +=
                  booking['actual_minutes'] as int;
            }
          }
        }
      }

      return categoryStats.entries
          .map((entry) => {
                'category': entry.key,
                'total_bookings': entry.value['total_bookings'],
                'completed_bookings': entry.value['completed_bookings'],
                'completion_rate': entry.value['total_bookings'] > 0
                    ? (entry.value['completed_bookings'] /
                        entry.value['total_bookings'] *
                        100)
                    : 0.0,
                'avg_duration': entry.value['completed_bookings'] > 0
                    ? (entry.value['total_duration'] /
                        entry.value['completed_bookings'])
                    : 0.0,
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch service category performance: $error');
    }
  }

  /// Gets team member performance metrics
  static Future<List<Map<String, dynamic>>> getTeamPerformance() async {
    try {
      final response = await _client.from('org_members').select('''
            user_id,
            role,
            users!inner (
              email,
              raw_user_meta_data
            )
          ''');

      // For each team member, get their booking statistics
      List<Map<String, dynamic>> teamPerformance = [];

      for (var member in response) {
        // Note: This is a simplified approach since we don't have direct user-booking relationships
        // In a real system, you might have a technician_id or assigned_user_id in bookings
        final memberData = {
          'user_id': member['user_id'],
          'email': member['users']['email'],
          'role': member['role'],
          'name': member['users']['raw_user_meta_data']?['full_name'] ??
              member['users']['email'].split('@')[0],
          'total_bookings':
              0, // Would need additional schema to track user-specific bookings
          'completed_bookings': 0,
          'avg_rating': 0.0, // Would need rating system
        };

        teamPerformance.add(memberData);
      }

      return teamPerformance;
    } catch (error) {
      throw Exception('Failed to fetch team performance: $error');
    }
  }

  /// Gets resource utilization metrics
  static Future<List<Map<String, dynamic>>> getResourceUtilization() async {
    try {
      final response = await _client.from('booking_resources').select('''
            resource_id,
            resources!inner (
              name
            ),
            bookings!inner (
              start_time,
              end_time,
              status
            )
          ''');

      // Calculate utilization per resource
      Map<String, Map<String, dynamic>> resourceStats = {};

      for (var bookingResource in response) {
        final resourceId = bookingResource['resource_id'];
        final resourceName = bookingResource['resources']['name'];

        resourceStats[resourceId] ??= {
          'name': resourceName,
          'total_hours': 0,
          'booked_hours': 0,
        };

        final booking = bookingResource['bookings'];
        if (booking['status'] != 'cancelled' &&
            booking['start_time'] != null &&
            booking['end_time'] != null) {
          final startTime = DateTime.parse(booking['start_time']);
          final endTime = DateTime.parse(booking['end_time']);
          final duration = endTime.difference(startTime).inHours;
          resourceStats[resourceId]!['booked_hours'] += duration;
        }
      }

      return resourceStats.entries
          .map((entry) => {
                'resource_id': entry.key,
                'name': entry.value['name'],
                'utilization_rate': entry.value['total_hours'] > 0
                    ? (entry.value['booked_hours'] /
                        entry.value['total_hours'] *
                        100)
                    : 0.0,
                'booked_hours': entry.value['booked_hours'],
              })
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch resource utilization: $error');
    }
  }
}
