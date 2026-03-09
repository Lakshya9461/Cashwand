import 'package:expense_tracker/domain/entities/profile_entity.dart';
import 'package:expense_tracker/domain/repositories/i_profile_repository.dart';

/// Stub profile repository for web platform.
class WebProfileRepository implements IProfileRepository {
  final List<ProfileEntity> _profiles = [
    ProfileEntity(id: 'default', name: 'Personal', isDefault: true),
  ];

  @override
  Future<List<ProfileEntity>> getAll() async => _profiles;

  @override
  Future<ProfileEntity?> getById(String id) async {
    try {
      return _profiles.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> insert(ProfileEntity profile) async {
    _profiles.add(profile);
  }

  @override
  Future<void> update(ProfileEntity profile) async {
    final idx = _profiles.indexWhere((p) => p.id == profile.id);
    if (idx != -1) {
      _profiles[idx] = profile;
    }
  }

  @override
  Future<void> delete(String id) async {
    _profiles.removeWhere((p) => p.id == id);
  }
}
