import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class LocalStorageService {
  LocalStorageService(this._preferences);

  static const _sessionKey = 'demo_session';
  static const _userKey = 'demo_user';
  static const _usedQuestionsKey = 'used_questions';

  final SharedPreferences _preferences;

  static Future<LocalStorageService> create() async =>
      LocalStorageService(await SharedPreferences.getInstance());

  bool get hasDemoSession => _preferences.getBool(_sessionKey) ?? false;

  Future<void> saveDemoSession(bool value) =>
      _preferences.setBool(_sessionKey, value);

  AppUser loadUser() {
    final value = _preferences.getString(_userKey);
    if (value == null) return AppUser.demo();
    try {
      return AppUser.fromJson(jsonDecode(value) as Map<String, dynamic>);
    } on FormatException {
      return AppUser.demo();
    }
  }

  Future<void> saveUser(AppUser user) =>
      _preferences.setString(_userKey, jsonEncode(user.toJson()));

  Map<String, List<String>> loadUsedQuestionIds() {
    final value = _preferences.getString(_usedQuestionsKey);
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map(
        (key, ids) => MapEntry(key, List<String>.from(ids as List)),
      );
    } on FormatException {
      return {};
    }
  }

  Future<void> saveUsedQuestionIds(Map<String, List<String>> value) =>
      _preferences.setString(_usedQuestionsKey, jsonEncode(value));

  Future<void> resetUserData() async {
    await _preferences.remove(_userKey);
    await _preferences.remove(_usedQuestionsKey);
  }
}
