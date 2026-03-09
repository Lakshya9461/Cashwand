import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/domain/entities/profile_entity.dart';
import 'package:expense_tracker/domain/repositories/i_profile_repository.dart';

/// Manages profile state and active profile selection.
///
/// When the active profile changes, listeners are notified so dependent
/// providers (TransactionProvider, etc.) can reload their data.
class ProfileProvider extends ChangeNotifier {
  final IProfileRepository _repository;
  static const String _activeProfileKey = 'active_profile_id';

  List<ProfileEntity> _profiles = [];
  String _activeProfileId = 'default';
  bool _isLoading = true;

  List<ProfileEntity> get profiles => List.unmodifiable(_profiles);
  String get activeProfileId => _activeProfileId;
  bool get isLoading => _isLoading;

  ProfileEntity? get activeProfile {
    try {
      return _profiles.firstWhere((p) => p.id == _activeProfileId);
    } catch (_) {
      return _profiles.isNotEmpty ? _profiles.first : null;
    }
  }

  ProfileProvider(this._repository);

  /// Loads profiles and restores last selected profile.
  Future<void> loadProfiles() async {
    _isLoading = true;
    notifyListeners();

    _profiles = await _repository.getAll();

    // If no profiles exist (first launch), create a default one
    if (_profiles.isEmpty) {
      final defaultProfile = ProfileEntity(
        id: 'default',
        name: 'Personal',
        isDefault: true,
      );
      await _repository.insert(defaultProfile);
      _profiles = [defaultProfile];
    }

    // Restore last active profile from prefs
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_activeProfileKey);
    if (savedId != null && _profiles.any((p) => p.id == savedId)) {
      _activeProfileId = savedId;
    } else {
      _activeProfileId = _profiles.first.id;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Switches the active profile and persists the choice.
  Future<void> switchProfile(String profileId) async {
    if (profileId == _activeProfileId) return;
    if (!_profiles.any((p) => p.id == profileId)) return;

    _activeProfileId = profileId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeProfileKey, profileId);
    notifyListeners();
  }

  /// Creates a new profile and returns its id.
  Future<String> createProfile(String name) async {
    final id = const Uuid().v4();
    final profile = ProfileEntity(id: id, name: name.trim(), isDefault: false);
    await _repository.insert(profile);
    _profiles = await _repository.getAll();
    notifyListeners();
    return id;
  }

  /// Renames an existing profile.
  Future<void> renameProfile(String profileId, String newName) async {
    final profile = _profiles.firstWhere((p) => p.id == profileId);
    final updated = profile.copyWith(name: newName.trim());
    await _repository.update(updated);
    _profiles = await _repository.getAll();
    notifyListeners();
  }

  /// Deletes a profile. Cannot delete the last profile.
  /// If the active profile is deleted, auto-switches to the first available.
  Future<bool> deleteProfile(String profileId) async {
    if (_profiles.length <= 1) return false;

    await _repository.delete(profileId);
    _profiles = await _repository.getAll();

    // If deleted profile was active, switch to first available
    if (_activeProfileId == profileId) {
      _activeProfileId = _profiles.first.id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProfileKey, _activeProfileId);
    }

    notifyListeners();
    return true;
  }
}
