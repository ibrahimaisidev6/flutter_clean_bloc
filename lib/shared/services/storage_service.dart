import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Service for managing application storage (secure and non-secure)
class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late SharedPreferences _preferences;

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods (for sensitive data like tokens)

  Future<void> saveSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAllSecure() async {
    await _secureStorage.deleteAll();
  }

  // Regular Storage Methods (for non-sensitive data)

  Future<void> save(String key, dynamic value) async {
    if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    } else {
      // For complex objects, store as JSON string
      await _preferences.setString(key, jsonEncode(value));
    }
  }

  T? get<T>(String key, {T? defaultValue}) {
    final value = _preferences.get(key);
    return value as T? ?? defaultValue;
  }

  String? getString(String key, {String? defaultValue}) {
    return _preferences.getString(key) ?? defaultValue;
  }

  int? getInt(String key, {int? defaultValue}) {
    return _preferences.getInt(key) ?? defaultValue;
  }

  double? getDouble(String key, {double? defaultValue}) {
    return _preferences.getDouble(key) ?? defaultValue;
  }

  bool? getBool(String key, {bool? defaultValue}) {
    return _preferences.getBool(key) ?? defaultValue;
  }

  List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _preferences.getStringList(key) ?? defaultValue;
  }

  Map<String, dynamic>? getMap(String key) {
    final jsonString = _preferences.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clear() async {
    await _preferences.clear();
  }

  bool containsKey(String key) {
    return _preferences.containsKey(key);
  }

  // Auth-specific methods

  Future<void> saveAuthToken(String token) async {
    await saveSecure(AppConstants.tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return await getSecure(AppConstants.tokenKey);
  }

  Future<void> clearAuthToken() async {
    await deleteSecure(AppConstants.tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await save(AppConstants.userKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    return getMap(AppConstants.userKey);
  }

  Future<void> clearUserData() async {
    await remove(AppConstants.userKey);
  }

  Future<void> logout() async {
    await clearAuthToken();
    await clearUserData();
  }

  // Onboarding

  Future<void> setOnboardingCompleted() async {
    await save(AppConstants.onboardingKey, true);
  }

  bool isOnboardingCompleted() {
    return getBool(AppConstants.onboardingKey, defaultValue: false) ?? false;
  }
}