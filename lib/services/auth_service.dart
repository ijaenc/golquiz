import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  const AuthService(this._supabase);

  final SupabaseService _supabase;

  bool get isConfigured => _supabase.isConfigured;
  User? get currentUser => _supabase.client?.auth.currentUser;
  Stream<AuthState>? get authStateChanges =>
      _supabase.client?.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    final client = _requireClient();
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) {
    final client = _requireClient();
    return client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username, 'display_name': displayName},
    );
  }

  Future<void> signOut() async {
    await _requireClient().auth.signOut();
  }

  SupabaseClient _requireClient() {
    final client = _supabase.client;
    if (client == null) {
      throw StateError('Supabase no está configurado.');
    }
    return client;
  }
}
