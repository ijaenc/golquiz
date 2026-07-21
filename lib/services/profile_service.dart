import '../models/app_user.dart';
import 'supabase_service.dart';

class ProfileService {
  const ProfileService(this._supabase);

  final SupabaseService _supabase;
  bool get isConfigured => _supabase.isConfigured;

  Future<AppUser> fetchProfile(String userId, {String? email}) async {
    final data = await _supabase.client!
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return AppUser.fromSupabase(data, email: email);
  }

  Future<void> ensureProfile({
    required String userId,
    required String username,
    required String displayName,
  }) async {
    await _supabase.client!.from('profiles').upsert({
      'id': userId,
      'username': username,
      'display_name': displayName,
    }, onConflict: 'id');
  }

  Future<void> updateDisplayName(String userId, String displayName) async {
    await _supabase.client!
        .from('profiles')
        .update({'display_name': displayName})
        .eq('id', userId);
  }
}
