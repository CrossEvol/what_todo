import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/profile/profile.dart';

class DriftSchemaDB {
  static final DriftSchemaDB _DriftSchemaDb =
      DriftSchemaDB._internal(AppDatabase());

  AppDatabase _db;

  // Private internal constructor to make it singleton
  DriftSchemaDB._internal(this._db);

  static DriftSchemaDB get() {
    return _DriftSchemaDb;
  }

  Future<UserProfile?> findByID(int profileId) async {
    final query = _db.select(_db.profile)
      ..where((tbl) => tbl.id.equals(profileId));
    final result = await query.getSingleOrNull();
    if (result == null) {
      return null;
    }
    final map = result.toJson();
    return UserProfile.fromMap({
      ...map,
      'updatedAt': DateTime.fromMillisecondsSinceEpoch(map['updatedAt'])
    });
  }

  Future<bool> exists() async {
    var result = await (_db.select(_db.driftSchema)).get();
    return result.isNotEmpty;
  }

  Future<bool> createSchema(int version) async {
    final schemaCompanion = DriftSchemaCompanion(version: Value(version));
    var i = await (_db.into(_db.driftSchema).insert(schemaCompanion));
    return i > 0;
  }

  Future<int> getMaximalVersion() async {
    var result = await (_db.select(_db.driftSchema)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.version)]))
        .getSingleOrNull();
    return result == null ? 0 : result.version;
  }

  Future<bool> shouldMigrate(int version) async {
    var previous = await (_db.select(_db.driftSchema)
          ..where((tbl) => tbl.version.equals(version)))
        .getSingleOrNull();
    var next = await (_db.select(_db.driftSchema)
          ..where((tbl) => tbl.version.equals(version + 1)))
        .getSingleOrNull();
    return previous != null && next == null;
  }
}
