import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const androidPrefix = 'android';
  static const iosPrefix = 'ios';
  static const String _access_token = "access_token";
  static const String _expiryKey = "expiry_time";
  static const String _configDataKey = "config_data";
  static const String _templatePayloads = "template_payloads";
  static final SharedPrefs _instance = SharedPrefs._internal();
  static SharedPreferences? _preferences;

  /// The currently active profile ID. When set, all reads/writes are scoped to this profile.
  static String? activeProfileId;

  // Private constructor
  SharedPrefs._internal();

  // Factory constructor to return the same instance
  factory SharedPrefs() {
    return _instance;
  }

  // Initialize SharedPreferences (called once)
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  // Set a string value
  Future<bool> setString(String key, String value) async {
    return _preferences!.setString(key, value);
  }

  // Get a string value
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  // Set an int value
  Future<bool> setInt(String key, int value) async {
    return _preferences!.setInt(key, value);
  }

  // Get an int value
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  // Set a bool value
  Future<bool> setBool(String key, bool value) async {
    return _preferences!.setBool(key, value);
  }

  // Get a bool value
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  // Remove a key
  Future<bool> remove(String key) async {
    return _preferences!.remove(key);
  }

  // Clear all stored data
  Future<bool> clear() async {
    return _preferences!.clear();
  }

  Future<DateTime?> tokenExpiry(
      {DateTime? expiry, bool isAndroid = true}) async {
    final key = _getKey(isAndroid, _expiryKey);

    if (expiry != null) {
      await _preferences!.setInt(key, expiry.millisecondsSinceEpoch);
      return expiry;
    }

    final expiryMillis = _preferences!.getInt(key);
    return expiryMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(expiryMillis)
        : null;
  }

  Future<String?> accessToken({String? data, bool isAndroid = true}) async {
    final key = _getKey(isAndroid, _access_token);

    if (data != null) {
      await _preferences!.setString(key, data);
      return data;
    }

    final data0 = _preferences!.getString(key);
    return data0;
  }

  String _getKey(bool isAndroid, String suffix) {
    final platformPrefix = isAndroid ? androidPrefix : iosPrefix;
    if (activeProfileId != null) {
      return "profile_${activeProfileId!}.$platformPrefix.$suffix";
    }
    return "$platformPrefix.$suffix";
  }

  Future<Map<String, dynamic>?> configData({
    Map<String, dynamic>? data,
    bool isAndroid = true,
  }) async {
    final key = _getKey(isAndroid, _configDataKey);

    if (data != null) {
      final jsonString = jsonEncode(data);
      await _preferences!.setString(key, jsonString);
      return data;
    }

    final jsonString = _preferences!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return null;
  }

  List<Map<String, dynamic>>? templatePayloads(
      {List<Map<String, dynamic>>? payloads, bool isAndroid = true}) {
    final key = _getKey(isAndroid, _templatePayloads);
    if (payloads != null) {
      final jsonString = jsonEncode(payloads);
      _preferences?.setString(key, jsonString);
      return null;
    }

    final storedString = _preferences?.getString(key);
    if (storedString != null) {
      final decoded = jsonDecode(storedString);
      if (decoded is List) {
        var list = List<Map<String, dynamic>>.from(decoded);
        return list.isEmpty ? null : list;
      }
    }

    return null;
  }
}
