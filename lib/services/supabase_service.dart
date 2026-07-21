import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  const SupabaseService._({required this.client, required this.message});

  final SupabaseClient? client;
  final String? message;

  bool get isConfigured => client != null;

  static SupabaseService? _instance;

  static Future<SupabaseService> initialize() async {
    final existing = _instance;
    if (existing != null) return existing;
    return _instance = await _initializeOnce();
  }

  static Future<SupabaseService> _initializeOnce() async {
    try {
      await dotenv.load(fileName: '.env');
      final url = dotenv.env['SUPABASE_URL']?.trim() ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';
      if (url.isEmpty || anonKey.isEmpty) {
        return const SupabaseService._(
          client: null,
          message:
              'Supabase no está configurado. El modo demo sigue disponible.',
        );
      }
      final instance = await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
      return SupabaseService._(client: instance.client, message: null);
    } catch (error) {
      return SupabaseService._(
        client: null,
        message: 'No se pudo inicializar Supabase: $error',
      );
    }
  }
}
