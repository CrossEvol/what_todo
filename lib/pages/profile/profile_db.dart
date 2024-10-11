import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/profile/profile.dart';

class ProfileDB {
  static final ProfileDB _profileDb = ProfileDB._internal(AppDatabase());

  AppDatabase _db;

  // Private internal constructor to make it singleton
  ProfileDB._internal(this._db);

  static ProfileDB get() {
    return _profileDb;
  }

  Future<UserProfile?> findByID(int profileId) async {
    final query = _db.select(_db.profile)
      ..where((tbl) => tbl.id.equals(profileId));
    final result = await query.getSingleOrNull();
    return result == null ? null : UserProfile.fromMap(result.toJson());
  }

  Future<bool> updateOne(UserProfile profile) async {
    final companion = ProfileCompanion(
      id: Value(profile.id ?? 1),
      name: Value(profile.name),
      email: Value(profile.email),
      avatarUrl: Value(profile.avatarUrl),
      updatedAt: Value(profile.updatedAt.millisecond),
    );
    final result = await (_db.update(_db.profile)
          ..where((tbl) => tbl.id.equals(profile.id ?? 1)))
        .write(companion);
    return result > 0;
  }
}
