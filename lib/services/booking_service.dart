import '../models/booking_model.dart';
import '../services/supabase_service.dart';

class BookingService {
  static final BookingService _instance = BookingService._internal();
  static BookingService get instance => _instance;
  BookingService._internal();

  final _client = SupabaseService.instance.client;

  /// Get all bookings for today's agenda
  Future<List<BookingModel>> getTodaysBookings() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('bookings')
          .select('*')
          .gte('scheduled_at', startOfDay.toIso8601String())
          .lt('scheduled_at', endOfDay.toIso8601String())
          .order('scheduled_at', ascending: true);

      return response
          .map<BookingModel>((json) => BookingModel.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch today\'s bookings: $error');
    }
  }

  /// Get bookings for a specific date range
  Future<List<BookingModel>> getBookingsInRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .gte('scheduled_at', startDate.toIso8601String())
          .lte('scheduled_at', endDate.toIso8601String())
          .order('scheduled_at', ascending: true);

      return response
          .map<BookingModel>((json) => BookingModel.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch bookings in range: $error');
    }
  }

  /// Create a new booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _client
          .from('bookings')
          .insert(booking.toJson())
          .select()
          .single();

      return BookingModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create booking: $error');
    }
  }

  /// Update a booking
  Future<BookingModel> updateBooking(BookingModel booking) async {
    try {
      final response = await _client
          .from('bookings')
          .update(booking.toJson())
          .eq('id', booking.id)
          .select()
          .single();

      return BookingModel.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update booking: $error');
    }
  }

  /// Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _client.from('bookings').delete().eq('id', bookingId);
    } catch (error) {
      throw Exception('Failed to delete booking: $error');
    }
  }

  /// Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Count today's bookings by status
      final totalResponse = await _client
          .from('bookings')
          .select('id')
          .gte('scheduled_at', startOfDay.toIso8601String())
          .lt('scheduled_at', endOfDay.toIso8601String())
          .count();

      final completedResponse = await _client
          .from('bookings')
          .select('id')
          .eq('status', 'completed')
          .gte('scheduled_at', startOfDay.toIso8601String())
          .lt('scheduled_at', endOfDay.toIso8601String())
          .count();

      final scheduledResponse = await _client
          .from('bookings')
          .select('id')
          .eq('status', 'scheduled')
          .gte('scheduled_at', startOfDay.toIso8601String())
          .lt('scheduled_at', endOfDay.toIso8601String())
          .count();

      final inProgressResponse = await _client
          .from('bookings')
          .select('id')
          .eq('status', 'in_progress')
          .gte('scheduled_at', startOfDay.toIso8601String())
          .lt('scheduled_at', endOfDay.toIso8601String())
          .count();

      return {
        'total_bookings': totalResponse.count,
        'completed': completedResponse.count,
        'scheduled': scheduledResponse.count,
        'in_progress': inProgressResponse.count,
        'completion_rate': totalResponse.count > 0
            ? ((completedResponse.count / totalResponse.count) * 100).round()
            : 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch booking statistics: $error');
    }
  }

  /// Get upcoming bookings (next 7 days)
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final now = DateTime.now();
      final nextWeek = now.add(const Duration(days: 7));

      final response = await _client
          .from('bookings')
          .select('*')
          .gte('scheduled_at', now.toIso8601String())
          .lte('scheduled_at', nextWeek.toIso8601String())
          .order('scheduled_at', ascending: true)
          .limit(10);

      return response
          .map<BookingModel>((json) => BookingModel.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch upcoming bookings: $error');
    }
  }
}
