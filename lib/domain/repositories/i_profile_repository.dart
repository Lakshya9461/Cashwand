import 'package:expense_tracker/domain/entities/profile_entity.dart';

/// Contract for profile data operations.
abstract class IProfileRepository {
  Future<List<ProfileEntity>> getAll();
  Future<ProfileEntity?> getById(String id);
  Future<void> insert(ProfileEntity profile);
  Future<void> update(ProfileEntity profile);
  Future<void> delete(String id);
}
