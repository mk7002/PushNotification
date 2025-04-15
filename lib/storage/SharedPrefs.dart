import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _expiryKey = "expiry_time";
  static const String _configDataKey = "config_data";
  static const String _androidTemplatePayloads = "android_template_payloads";
  static final SharedPrefs _instance = SharedPrefs._internal();
  static SharedPreferences? _preferences;

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

  // Store DateTime (expiry time) as millisecondsSinceEpoch
  Future<bool> setExpiry(DateTime expiry) async {
    return _preferences!.setInt(_expiryKey, expiry.millisecondsSinceEpoch);
  }

  // Retrieve DateTime (expiry time) from millisecondsSinceEpoch
  DateTime? getExpiry() {
    int? expiryMillis = _preferences!.getInt(_expiryKey);
    if (expiryMillis != null) {
      return DateTime.fromMillisecondsSinceEpoch(expiryMillis);
    }
    return null; // Return null if no expiry time is found
  }

  Future<bool> setConfigData(Map<String, dynamic> configData) async {
    String jsonString = jsonEncode(configData); // Convert Map to JSON string
    return _preferences!.setString(_configDataKey, jsonString);
  }

  // Retrieve Map<String, dynamic> from a JSON string
  Map<String, dynamic>? getConfigData() {
    String? jsonString = _preferences!.getString(_configDataKey);
    if (jsonString != null) {
      return jsonDecode(jsonString); // Convert JSON string back to Map
    }
    return null; // Return null if no data is found
  }

  List<Map<String, dynamic>>? updateOrGetAndroidTemplatePayloads({
    List<Map<String, dynamic>>? payloads,
  }) {
    if (payloads != null) {
      final jsonString = jsonEncode(payloads);
      _preferences?.setString(_androidTemplatePayloads, jsonString);
      return null;
    }

    final storedString = _preferences?.getString(_androidTemplatePayloads);
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
