import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._storage);

  final LocalStorageService _storage;
  bool _isAuthenticated = false;
  bool _isInitialized = false;
  AppUser _user = AppUser.demo();

  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  AppUser get user => _user;

  Future<void> initialize() async {
    _user = _storage.loadUser();
    _isAuthenticated = _storage.hasDemoSession;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> signInAsDemo() async {
    _user = _storage.loadUser();
    _isAuthenticated = true;
    await _storage.saveDemoSession(true);
    await _storage.saveUser(_user);
    notifyListeners();
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    await _storage.saveDemoSession(false);
    notifyListeners();
  }

  Future<void> updateUser(AppUser user) async {
    _user = user;
    await _storage.saveUser(user);
    notifyListeners();
  }

  Future<void> resetUser() async {
    await _storage.resetUserData();
    _user = AppUser.demo();
    await _storage.saveUser(_user);
    notifyListeners();
  }
}
