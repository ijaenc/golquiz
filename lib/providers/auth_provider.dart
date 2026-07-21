import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';
import '../services/profile_service.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(
    this._storage,
    this._authService,
    this._profileService,
    this._supabaseService,
  );

  final LocalStorageService _storage;
  final AuthService _authService;
  final ProfileService _profileService;
  final SupabaseService _supabaseService;

  bool _isAuthenticated = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  bool _isDemo = false;
  String? _error;
  String? _message;
  AppUser _user = AppUser.demo();

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  bool get isDemo => _isDemo;
  bool get isSupabaseConfigured => _authService.isConfigured;
  String? get error => _error;
  String? get message => _message ?? _supabaseService.message;
  AppUser get user => _user;

  Future<void> initialize() async {
    try {
      final remoteUser = _authService.currentUser;
      if (remoteUser != null) {
        _user = await _profileService.fetchProfile(
          remoteUser.id,
          email: remoteUser.email,
        );
        await _storage.saveUser(_user);
        _isAuthenticated = true;
        _isDemo = false;
      } else if (_storage.hasDemoSession) {
        _user = _storage.loadUser();
        _isAuthenticated = true;
        _isDemo = true;
      }
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    return _runAuthAction(() async {
      final response = await _authService.signIn(
        email: email.trim(),
        password: password,
      );
      final remoteUser = response.user;
      if (remoteUser == null) throw StateError('No se recibió el usuario.');
      _user = await _profileService.fetchProfile(
        remoteUser.id,
        email: remoteUser.email,
      );
      await _storage.saveUser(_user);
      await _storage.saveDemoSession(false);
      _isAuthenticated = true;
      _isDemo = false;
    });
  }

  Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    return _runAuthAction(() async {
      final response = await _authService.register(
        email: email.trim(),
        password: password,
        username: username.trim(),
        displayName: displayName.trim(),
      );
      final remoteUser = response.user;
      if (remoteUser == null) throw StateError('No se pudo crear el usuario.');
      if (response.session == null) {
        _message = 'Cuenta creada. Revisa tu correo para confirmar el acceso.';
        return;
      }
      await _profileService.ensureProfile(
        userId: remoteUser.id,
        username: username.trim(),
        displayName: displayName.trim(),
      );
      _user = await _profileService.fetchProfile(
        remoteUser.id,
        email: remoteUser.email,
      );
      await _storage.saveUser(_user);
      _isAuthenticated = true;
      _isDemo = false;
    });
  }

  Future<void> signInAsDemo() async {
    _setLoading(true);
    _user = _storage.loadUser();
    _isAuthenticated = true;
    _isDemo = true;
    await _storage.saveDemoSession(true);
    await _storage.saveUser(_user);
    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      if (!_isDemo && _authService.isConfigured) await _authService.signOut();
      _isAuthenticated = false;
      _isDemo = false;
      _error = null;
      _message = null;
      await _storage.saveDemoSession(false);
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    await _storage.saveUser(user);
    notifyListeners();
  }

  Future<void> refreshRemoteProfile() async {
    if (_isDemo || !_profileService.isConfigured) return;
    _user = await _profileService.fetchProfile(_user.id, email: _user.email);
    await _storage.saveUser(_user);
    notifyListeners();
  }

  Future<void> resetUser() async {
    await _storage.resetUserData();
    _user = AppUser.demo();
    await _storage.saveUser(_user);
    notifyListeners();
  }

  Future<bool> _runAuthAction(Future<void> Function() action) async {
    _setLoading(true);
    _error = null;
    _message = null;
    try {
      await action();
      return true;
    } catch (error) {
      _error = _friendlyError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearFeedback() {
    _error = null;
    _message = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login')) {
        return 'Correo o contraseña incorrectos.';
      }
      if (message.contains('email not confirmed')) {
        return 'Confirma tu correo antes de ingresar.';
      }
      if (message.contains('already registered')) {
        return 'Ese correo ya está registrado.';
      }
      if (message.contains('password')) {
        return 'La contraseña no cumple los requisitos de seguridad.';
      }
      return error.message;
    }
    return error.toString().replaceFirst('Bad state: ', '');
  }
}
