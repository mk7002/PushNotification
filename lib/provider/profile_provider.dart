import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pushapp/model/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  static const String _profilesKey = 'saved_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  List<Profile> _profiles = [];
  Profile? _activeProfile;

  List<Profile> get profiles => _profiles;
  Profile? get activeProfile => _activeProfile;

  List<Profile> get androidProfiles =>
      _profiles.where((p) => p.platform == 'android').toList();

  List<Profile> get iosProfiles =>
      _profiles.where((p) => p.platform == 'ios').toList();

  Future<void> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profilesKey);
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      _profiles = decoded.map((e) => Profile.fromJson(e)).toList();
    }

    // Ensure default WebEngage profiles always exist
    _ensureDefaultProfiles();

    final activeId = prefs.getString(_activeProfileKey);
    if (activeId != null && _profiles.isNotEmpty) {
      _activeProfile = _profiles.where((p) => p.id == activeId).firstOrNull;
    }

    notifyListeners();
  }

  void _ensureDefaultProfiles() {
    final hasAndroidDefault =
        _profiles.any((p) => p.id == 'webengage_android');
    final hasIosDefault = _profiles.any((p) => p.id == 'webengage_ios');

    bool added = false;
    if (!hasAndroidDefault) {
      _profiles.insert(0, Profile.defaultAndroid());
      added = true;
    }
    if (!hasIosDefault) {
      _profiles.insert(
        _profiles.indexWhere((p) => p.platform == 'ios') == -1
            ? _profiles.length
            : 0,
        Profile.defaultIos(),
      );
      added = true;
    }

    if (added) {
      _saveProfiles();
    }
  }

  Future<Profile> createProfile(String name, String platform) async {
    final profile = Profile(
      id: '${platform}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      platform: platform,
      createdAt: DateTime.now(),
    );

    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
    return profile;
  }

  Future<void> deleteProfile(Profile profile) async {
    // Prevent deleting default profiles
    if (profile.isDefault) return;

    _profiles.removeWhere((p) => p.id == profile.id);

    // Also clear this profile's stored data
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = prefs
        .getKeys()
        .where((key) => key.startsWith('profile_${profile.id}'))
        .toList();
    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    if (_activeProfile?.id == profile.id) {
      _activeProfile = null;
      await prefs.remove(_activeProfileKey);
    }

    await _saveProfiles();
    notifyListeners();
  }

  Future<void> setActiveProfile(Profile profile) async {
    _activeProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profile.id);
    notifyListeners();
  }

  Future<void> renameProfile(Profile profile, String newName) async {
    // Prevent renaming default profiles
    if (profile.isDefault) return;

    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _profiles[index] = Profile(
        id: profile.id,
        name: newName,
        platform: profile.platform,
        createdAt: profile.createdAt,
      );
      if (_activeProfile?.id == profile.id) {
        _activeProfile = _profiles[index];
      }
      await _saveProfiles();
      notifyListeners();
    }
  }

  Future<void> _saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_profiles.map((p) => p.toJson()).toList());
    await prefs.setString(_profilesKey, jsonString);
  }

  /// Get the storage key prefix for a given profile
  static String getProfilePrefix(String profileId) => 'profile_$profileId';

  /// Find a profile by its ID
  Profile? getProfileById(String id) {
    return _profiles.where((p) => p.id == id).firstOrNull;
  }

  /// Activate a profile by its ID. Returns true if found and activated.
  Future<bool> activateProfileById(String id) async {
    if (_profiles.isEmpty) {
      await loadProfiles();
    }
    final profile = getProfileById(id);
    if (profile != null) {
      await setActiveProfile(profile);
      return true;
    }
    return false;
  }
}
