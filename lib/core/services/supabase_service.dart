import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/supabase_constants.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();
  
  late final SupabaseClient client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      anonKey: SupabaseConstants.supabaseAnonKey,
    );
    client = Supabase.instance.client;
  }
}
