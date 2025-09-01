import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/role_service.dart';

/// Service for managing workshop configuration data with Supabase integration
class WorkshopService {
  static final WorkshopService _instance = WorkshopService._internal();
  static WorkshopService get instance => _instance;
  WorkshopService._internal();

  final _client = SupabaseService.instance.client;

  /// Get current user's organization ID
  Future<String?> getCurrentOrgId() async {
    try {
      final userRole = await RoleService.instance.getCurrentUserRole();
      return userRole?['org_id'];
    } catch (error) {
      throw Exception('Failed to get organization ID: $error');
    }
  }

  /// Get workshop resources from Supabase
  Future<List<Map<String, dynamic>>> getResources() async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response = await _client
          .from('resources')
          .select('*')
          .eq('org_id', orgId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch resources: $error');
    }
  }

  /// Create new workshop resource
  Future<Map<String, dynamic>> createResource({
    required String name,
    required String type,
    String? description,
    bool isActive = true,
  }) async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response = await _client
          .from('resources')
          .insert({
            'name': name,
            'type': type,
            'org_id': orgId,
            'is_active': isActive,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create resource: $error');
    }
  }

  /// Update workshop resource
  Future<Map<String, dynamic>> updateResource({
    required String resourceId,
    String? name,
    String? type,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (type != null) updateData['type'] = type;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await _client
          .from('resources')
          .update(updateData)
          .eq('id', resourceId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update resource: $error');
    }
  }

  /// Get workshop services from Supabase
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response = await _client
          .from('services')
          .select('*')
          .eq('org_id', orgId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch services: $error');
    }
  }

  /// Create new workshop service
  Future<Map<String, dynamic>> createService({
    required String name,
    required String category,
    required double price,
    required int durationMin,
    String? description,
    int bufferBeforeMin = 0,
    int bufferAfterMin = 0,
  }) async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response = await _client
          .from('services')
          .insert({
            'name': name,
            'category': category,
            'price': price,
            'duration_min': durationMin,
            'buffer_before_min': bufferBeforeMin,
            'buffer_after_min': bufferAfterMin,
            'org_id': orgId,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create service: $error');
    }
  }

  /// Update workshop service
  Future<Map<String, dynamic>> updateService({
    required String serviceId,
    String? name,
    String? category,
    double? price,
    int? durationMin,
    int? bufferBeforeMin,
    int? bufferAfterMin,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (price != null) updateData['price'] = price;
      if (durationMin != null) updateData['duration_min'] = durationMin;
      if (bufferBeforeMin != null)
        updateData['buffer_before_min'] = bufferBeforeMin;
      if (bufferAfterMin != null)
        updateData['buffer_after_min'] = bufferAfterMin;

      final response = await _client
          .from('services')
          .update(updateData)
          .eq('id', serviceId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update service: $error');
    }
  }

  /// Get working hours configuration
  Future<List<Map<String, dynamic>>> getWorkingHours() async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response =
          await _client.from('working_hours').select('*').eq('org_id', orgId);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch working hours: $error');
    }
  }

  /// Update working hours configuration
  Future<void> updateWorkingHours(
      List<Map<String, dynamic>> workingHours) async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      // Delete existing working hours
      await _client.from('working_hours').delete().eq('org_id', orgId);

      // Insert new working hours
      final insertData = workingHours
          .map((wh) => {
                ...wh,
                'org_id': orgId,
                'created_at': DateTime.now().toIso8601String(),
              })
          .toList();

      await _client.from('working_hours').insert(insertData);
    } catch (error) {
      throw Exception('Failed to update working hours: $error');
    }
  }

  /// Get organization team members
  Future<List<Map<String, dynamic>>> getTeamMembers() async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      final response = await _client
          .from('org_members')
          .select('*, users!inner(email, raw_user_meta_data)')
          .eq('org_id', orgId)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch team members: $error');
    }
  }

  /// Update team member role
  Future<void> updateTeamMemberRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      await _client
          .from('org_members')
          .update({'role': newRole})
          .eq('user_id', userId)
          .eq('org_id', orgId);
    } catch (error) {
      throw Exception('Failed to update team member role: $error');
    }
  }

  /// Get workshop statistics for KPI dashboard
  Future<Map<String, dynamic>> getWorkshopStats() async {
    try {
      final orgId = await getCurrentOrgId();
      if (orgId == null) throw Exception('No organization found for user');

      // Get resources count
      final resourcesCount = await _client
          .from('resources')
          .select('id')
          .eq('org_id', orgId)
          .count();

      // Get services count
      final servicesCount = await _client
          .from('services')
          .select('id')
          .eq('org_id', orgId)
          .count();

      // Get team members count
      final teamCount = await _client
          .from('org_members')
          .select('user_id')
          .eq('org_id', orgId)
          .count();

      // Get bookings count for current month
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);

      final bookingsCount = await _client
          .from('bookings')
          .select('id')
          .eq('org_id', orgId)
          .gte('created_at', monthStart.toIso8601String())
          .lte('created_at', monthEnd.toIso8601String())
          .count();

      return {
        'resources_count': resourcesCount.count,
        'services_count': servicesCount.count,
        'team_count': teamCount.count,
        'bookings_this_month': bookingsCount.count,
      };
    } catch (error) {
      throw Exception('Failed to fetch workshop stats: $error');
    }
  }

  /// Creates a new workshop with a manager account
  Future<UserModel?> createWorkshopWithManager({
    required String workshopName,
    required String managerName,
    required String managerEmail,
    required String managerPassword,
    required String phone,
    required String address,
  }) async {
    try {
      // Step 1: Create auth user account
      final authResponse = await _client.auth.signUp(
        email: managerEmail,
        password: managerPassword,
        data: {
          'full_name': managerName,
          'role': 'manager',
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      final userId = authResponse.user!.id;

      // Step 2: Create user profile in users table
      await _client.from('users').insert({
        'id': userId,
        'email': managerEmail,
        'raw_user_meta_data': {
          'full_name': managerName,
          'phone': phone,
          'address': address,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Step 3: Create organization (workshop)
      final orgResponse = await _client
          .from('orgs')
          .insert({
            'name': workshopName,
            'timezone': 'Europe/Madrid',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final orgId = orgResponse['id'] as String;

      // Step 4: Add user as manager in org_members
      await _client.from('org_members').insert({
        'user_id': userId,
        'org_id': orgId,
        'role': 'manager',
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Step 5: Set up default workshop configuration
      await _setupDefaultWorkshopConfiguration(orgId);

      // Step 6: Return user model with organization info
      return UserModel(
        id: userId,
        email: managerEmail,
        fullName: managerName,
        role: 'manager',
        orgId: orgId,
        orgName: workshopName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (error) {
      throw Exception('Failed to create workshop: $error');
    }
  }

  /// Set up default configuration for new workshop
  Future<void> _setupDefaultWorkshopConfiguration(String orgId) async {
    try {
      // Create default services
      final defaultServices = [
        {
          'org_id': orgId,
          'name': 'Cambio de Neumáticos',
          'description':
              'Servicio de cambio de neumáticos para diferentes tipos de vehículos',
          'base_duration_minutes': 45,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'org_id': orgId,
          'name': 'Balanceo de Ruedas',
          'description': 'Servicio de balanceo y alineación de ruedas',
          'base_duration_minutes': 30,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'org_id': orgId,
          'name': 'Reparación de Pinchazos',
          'description': 'Reparación de neumáticos con pinchazos menores',
          'base_duration_minutes': 20,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      await _client.from('services').insert(defaultServices);

      // Create default resources (equipment/bays)
      final defaultResources = [
        {
          'org_id': orgId,
          'name': 'Elevador 1',
          'type': 'equipment',
          'description': 'Elevador principal para cambio de neumáticos',
          'is_active': true,
          'capacity': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'org_id': orgId,
          'name': 'Elevador 2',
          'type': 'equipment',
          'description': 'Elevador secundario para servicios múltiples',
          'is_active': true,
          'capacity': 1,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      await _client.from('resources').insert(defaultResources);

      // Set default working hours (Monday to Friday, 8:00 - 18:00)
      final defaultWorkingHours = [];
      for (int dayOfWeek = 1; dayOfWeek <= 5; dayOfWeek++) {
        defaultWorkingHours.add({
          'org_id': orgId,
          'resource_id': null, // Global working hours
          'day_of_week': dayOfWeek,
          'start_time': '08:00:00',
          'end_time': '18:00:00',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await _client.from('working_hours').insert(defaultWorkingHours);
    } catch (error) {
      // Log error but don't fail the workshop creation
      print('Warning: Failed to set up default configuration: $error');
    }
  }

  /// Get workshop details by organization ID
  Future<Map<String, dynamic>?> getWorkshopDetails(String orgId) async {
    try {
      final response = await _client
          .from('orgs')
          .select(
              '*, org_members!inner(role), users!inner(email, raw_user_meta_data)')
          .eq('id', orgId)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch workshop details: $error');
    }
  }

  /// Get workshop members
  Future<List<Map<String, dynamic>>> getWorkshopMembers(String orgId) async {
    try {
      final response = await _client
          .from('org_members')
          .select('*, users!inner(email, raw_user_meta_data)')
          .eq('org_id', orgId)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch workshop members: $error');
    }
  }

  /// Add worker to workshop
  Future<UserModel?> addWorkerToWorkshop({
    required String orgId,
    required String workerEmail,
    required String workerPassword,
    required String workerName,
    String role = 'worker',
  }) async {
    try {
      // Step 1: Create auth user account
      final authResponse = await _client.auth.signUp(
        email: workerEmail,
        password: workerPassword,
        data: {
          'full_name': workerName,
          'role': role,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create worker account');
      }

      final userId = authResponse.user!.id;

      // Step 2: Create user profile
      await _client.from('users').insert({
        'id': userId,
        'email': workerEmail,
        'raw_user_meta_data': {
          'full_name': workerName,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Step 3: Add to organization
      await _client.from('org_members').insert({
        'user_id': userId,
        'org_id': orgId,
        'role': role,
        'joined_at': DateTime.now().toIso8601String(),
      });

      // Step 4: Get organization name
      final orgResponse =
          await _client.from('orgs').select('name').eq('id', orgId).single();

      return UserModel(
        id: userId,
        email: workerEmail,
        fullName: workerName,
        role: role,
        orgId: orgId,
        orgName: orgResponse['name'] as String,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (error) {
      throw Exception('Failed to add worker: $error');
    }
  }

  /// Update workshop information
  Future<void> updateWorkshopInfo({
    required String orgId,
    required String name,
    String? timezone,
  }) async {
    try {
      await _client.from('orgs').update({
        'name': name,
        if (timezone != null) 'timezone': timezone,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orgId);
    } catch (error) {
      throw Exception('Failed to update workshop info: $error');
    }
  }

  /// Remove member from workshop
  Future<void> removeMemberFromWorkshop({
    required String orgId,
    required String userId,
  }) async {
    try {
      await _client
          .from('org_members')
          .delete()
          .eq('org_id', orgId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to remove member: $error');
    }
  }

  /// Update member role
  Future<void> updateMemberRole({
    required String orgId,
    required String userId,
    required String newRole,
  }) async {
    try {
      await _client
          .from('org_members')
          .update({'role': newRole})
          .eq('org_id', orgId)
          .eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to update member role: $error');
    }
  }
}
