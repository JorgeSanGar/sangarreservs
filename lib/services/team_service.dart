import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class TeamService {
  static final SupabaseClient _client = SupabaseService.instance.client;

  /// Fetches all team members for the current organization
  static Future<List<Map<String, dynamic>>> getTeamMembers() async {
    try {
      final response = await _client.from('org_members').select('''
            *,
            users!inner (
              id,
              email,
              raw_user_meta_data
            )
          ''').order('joined_at', ascending: false);

      return response;
    } catch (error) {
      throw Exception('Failed to fetch team members: $error');
    }
  }

  /// Fetches a specific team member by user ID
  static Future<Map<String, dynamic>?> getTeamMember(String userId) async {
    try {
      final response = await _client.from('org_members').select('''
            *,
            users!inner (
              id,
              email,
              raw_user_meta_data
            )
          ''').eq('user_id', userId).maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch team member: $error');
    }
  }

  /// Updates a team member's role
  static Future<Map<String, dynamic>> updateMemberRole(
      String userId, String newRole) async {
    try {
      final response = await _client
          .from('org_members')
          .update({'role': newRole})
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update member role: $error');
    }
  }

  /// Removes a team member from the organization
  static Future<void> removeMember(String userId) async {
    try {
      await _client.from('org_members').delete().eq('user_id', userId);
    } catch (error) {
      throw Exception('Failed to remove member: $error');
    }
  }

  /// Gets team member count for the organization
  static Future<int> getTeamMemberCount() async {
    try {
      final response = await _client.from('org_members').select('id').count();

      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to get team member count: $error');
    }
  }

  /// Gets team members by role
  static Future<List<Map<String, dynamic>>> getTeamMembersByRole(
      String role) async {
    try {
      final response = await _client.from('org_members').select('''
            *,
            users!inner (
              id,
              email,
              raw_user_meta_data
            )
          ''').eq('role', role).order('joined_at', ascending: false);

      return response;
    } catch (error) {
      throw Exception('Failed to fetch team members by role: $error');
    }
  }

  /// Gets active team members (users who have recent activity)
  static Future<List<Map<String, dynamic>>> getActiveTeamMembers() async {
    try {
      // Get members who have been active in the last 30 days
      final thirtyDaysAgo =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      final response = await _client
          .from('org_members')
          .select('''
            *,
            users!inner (
              id,
              email,
              raw_user_meta_data,
              updated_at
            )
          ''')
          .gte('users.updated_at', thirtyDaysAgo)
          .order('users.updated_at', ascending: false);

      return response;
    } catch (error) {
      throw Exception('Failed to fetch active team members: $error');
    }
  }

  /// Invites a new team member
  static Future<Map<String, dynamic>> inviteTeamMember(
      String email, String role) async {
    try {
      final response = await _client
          .from('invite_codes')
          .insert({
            'email': email,
            'role': role,
            'created_by': _client.auth.currentUser?.id,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to invite team member: $error');
    }
  }

  /// Gets pending invitations
  static Future<List<Map<String, dynamic>>> getPendingInvitations() async {
    try {
      final response = await _client
          .from('invite_codes')
          .select('*')
          .isFilter('used_by', null)
          .order('created_at', ascending: false);

      return response;
    } catch (error) {
      throw Exception('Failed to fetch pending invitations: $error');
    }
  }
}
