import 'package:expense_tracker/data/database/profile_dao.dart';
import 'package:expense_tracker/data/models/profile_model.dart';
import 'package:expense_tracker/domain/entities/profile_entity.dart';
import 'package:expense_tracker/domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  final ProfileDao _dao;

  ProfileRepository({ProfileDao? dao}) : _dao = dao ?? ProfileDao();

  @override
  Future<List<ProfileEntity>> getAll() async {
    final rows = await _dao.queryAll();
    return rows.map((r) => ProfileModel.fromMap(r).toEntity()).toList();
  }

  @override
  Future<ProfileEntity?> getById(String id) async {
    final row = await _dao.queryById(id);
    if (row == null) return null;
    return ProfileModel.fromMap(row).toEntity();
  }

  @override
  Future<void> insert(ProfileEntity profile) async {
    await _dao.insert(ProfileModel.fromEntity(profile).toMap());
  }

  @override
  Future<void> update(ProfileEntity profile) async {
    await _dao.update(ProfileModel.fromEntity(profile).toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _dao.delete(id);
  }
}
