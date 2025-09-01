import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  static SupabaseService get instance => _instance;

  SupabaseService._internal();

  late final SupabaseClient client;

  Future<void> initialize() async {
    const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

    if (supabaseUrl.isEmpty) {
      throw Exception(
          'SUPABASE_URL is not configured. Please check your env.json file.');
    }

    if (supabaseAnonKey.isEmpty) {
      throw Exception(
          'SUPABASE_ANON_KEY is not configured. Please check your env.json file.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    client = Supabase.instance.client;
  }
}
