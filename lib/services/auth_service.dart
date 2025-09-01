import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  AuthService._internal();

  final _client = SupabaseService.instance.client;

  /// Get current user session
  Session? get currentSession => _client.auth.currentSession;

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentSession != null;

  /// Sign in with email and password
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return await _getUserProfileWithOrg(response.user!.id);
      }
      return null;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  /// Sign up with email and password
  Future<UserModel?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String role = 'worker',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        // Create user profile
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
        );

        return await _getUserProfileWithOrg(response.user!.id);
      }
      return null;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Get user profile with organization information
  Future<UserModel?> _getUserProfileWithOrg(String userId) async {
    try {
      final response = await _client
          .from('org_members')
          .select('*, users!inner(email, raw_user_meta_data), orgs!inner(name)')
          .eq('user_id', userId)
          .single();

      return UserModel.fromSupabaseUserData(response);
    } catch (error) {
      // If user is not in any organization, get basic user data
      try {
        final userResponse =
            await _client.from('users').select('*').eq('id', userId).single();

        return UserModel.fromJson({
          ...userResponse,
          'role': 'worker', // Default role
        });
      } catch (userError) {
        throw Exception('Failed to fetch user profile: $userError');
      }
    }
  }

  /// Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
  }) async {
    try {
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'raw_user_meta_data': {
          'full_name': fullName,
        },
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      throw Exception('Failed to create user profile: $error');
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await _client
          .from('users')
          .update({
            'email': user.email,
            'raw_user_meta_data': {
              'full_name': user.fullName,
            },
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id)
          .select()
          .single();

      return UserModel.fromJson({
        ...response,
        'role': user.role,
        'org_id': user.orgId,
        'org_name': user.orgName,
      });
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  /// Get current user profile with organization
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      return await _getUserProfileWithOrg(user.id);
    } catch (error) {
      return null;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
