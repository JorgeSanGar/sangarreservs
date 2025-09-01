import '../models/tire_timing_model.dart';
import '../services/supabase_service.dart';

class TireTimingService {
  static final TireTimingService _instance = TireTimingService._internal();
  static TireTimingService get instance => _instance;
  TireTimingService._internal();

  final _client = SupabaseService.instance.client;

  /// Get all tire timing recommendations
  Future<List<TireTiming>> getTireTimingRecommendations() async {
    try {
      final response = await _client
          .from('tire_timing_recommendations')
          .select('*')
          .order('vehicle_type', ascending: true);

      return response
          .map<TireTiming>((json) => TireTiming.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch tire timing recommendations: $error');
    }
  }

  /// Get specific tire timing recommendation by vehicle type
  Future<TireTiming?> getTireTimingRecommendation(String vehicleType) async {
    try {
      final response = await _client
          .from('tire_timing_recommendations')
          .select('*')
          .eq('vehicle_type', vehicleType)
          .maybeSingle();

      if (response == null) return null;

      return TireTiming.fromJson(response);
    } catch (error) {
      throw Exception(
          'Failed to fetch tire timing recommendation for $vehicleType: $error');
    }
  }

  /// Get recommended timing for specific vehicle type and wheel count
  Future<double?> getRecommendedTiming({
    required String vehicleType,
    required int wheelCount,
    bool withBalancing = false,
  }) async {
    try {
      final result =
          await _client.rpc('get_tire_timing_recommendation', params: {
        'p_vehicle_type': vehicleType,
        'p_wheel_count': wheelCount,
        'p_with_balancing': withBalancing,
      });

      return result != null ? (result as num).toDouble() : null;
    } catch (error) {
      throw Exception('Failed to get recommended timing: $error');
    }
  }

  /// Update service with tire timing recommendations
  Future<Map<String, dynamic>> updateServiceWithTireRecommendations({
    required String serviceId,
    required String vehicleType,
    required int wheelCount,
    bool withBalancing = false,
    bool useRecommendedTiming = true,
  }) async {
    try {
      final response = await _client
          .from('services')
          .update({
            'vehicle_type': vehicleType,
            'wheel_count': wheelCount,
            'with_balancing': withBalancing,
            'use_recommended_timing': useRecommendedTiming,
          })
          .eq('id', serviceId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception(
          'Failed to update service with tire recommendations: $error');
    }
  }

  /// Create or update tire service with automatic timing
  Future<Map<String, dynamic>> createTireService({
    required String name,
    required String category,
    required double price,
    String? description,
    required String vehicleType,
    required int wheelCount,
    bool withBalancing = false,
    bool useRecommendedTiming = true,
    int bufferBeforeMin = 5,
    int bufferAfterMin = 10,
  }) async {
    try {
      // Get organization ID (this should be passed from context in a real implementation)
      // For now, we'll assume it's available from user context
      final response = await _client
          .from('services')
          .insert({
            'name': name,
            'category': category,
            'price': price,
            'description': description,
            'vehicle_type': vehicleType,
            'wheel_count': wheelCount,
            'with_balancing': withBalancing,
            'use_recommended_timing': useRecommendedTiming,
            'buffer_before_min': bufferBeforeMin,
            'buffer_after_min': bufferAfterMin,
            // The duration_min will be automatically set by the trigger
            'duration_min': 30, // Fallback value
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create tire service: $error');
    }
  }

  /// Get vehicle types with display names
  Map<String, String> getVehicleTypesWithDisplayNames() {
    return {
      'turismo': 'Turismo',
      'suv_4x4': 'SUV/4x4',
      'todoterreno_puro': 'Todoterreno Puro',
      'camion': 'Camión',
      'furgoneta_SRW': 'Furgoneta SRW',
      'furgoneta_DRW': 'Furgoneta DRW',
    };
  }

  /// Get available vehicle types
  List<String> getAvailableVehicleTypes() {
    return [
      'turismo',
      'suv_4x4',
      'todoterreno_puro',
      'camion',
      'furgoneta_SRW',
      'furgoneta_DRW',
    ];
  }

  /// Get max wheel count for vehicle type
  int getMaxWheelCountForVehicleType(String vehicleType) {
    switch (vehicleType) {
      case 'turismo':
      case 'suv_4x4':
      case 'todoterreno_puro':
      case 'camion':
      case 'furgoneta_SRW':
        return 4;
      case 'furgoneta_DRW':
        return 6;
      default:
        return 4;
    }
  }

  /// Check if vehicle type supports balancing
  bool supportsBalancing(String vehicleType) {
    switch (vehicleType) {
      case 'camion':
      case 'furgoneta_SRW':
      case 'furgoneta_DRW':
        return true;
      default:
        return false;
    }
  }
}
