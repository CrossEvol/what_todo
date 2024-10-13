import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/pages/settings/setting.dart';

class SettingsDB {
  static final SettingsDB _settingsDb = SettingsDB._internal(AppDatabase());

  AppDatabase _db;

  // Private internal constructor to make it singleton
  SettingsDB._internal(this._db);

  static SettingsDB get() {
    return _settingsDb;
  }

  Future<Setting?> findByName(String settingKey) async {
    final query = _db.select(_db.setting)
      ..where((tbl) => tbl.key.equals(settingKey));
    final result = await query.getSingleOrNull();
    if (result == null) {
      return null;
    }
    return Setting.fromMap(result.toJson());
  }

  Future<bool> updateSetting(Setting setting) async {
    final companion = SettingCompanion(
      id: Value(setting.id ?? 0),
      key: Value(setting.key),
      value: Value(setting.value),
      updatedAt: Value(setting.updatedAt),
      type: Value(setting.type),
    );
    final result = await (_db.update(_db.setting)
          ..where((tbl) => tbl.key.equals(setting.key)))
        .write(companion);
    return result > 0;
  }

  Future<bool> createSetting(Setting setting) async {
    final companion = SettingCompanion.insert(
      key: setting.key,
      value: Value(setting.value),
      updatedAt: setting.updatedAt,
      type: setting.type,
    );
    final result = await _db.into(_db.setting).insert(companion);
    return result > 0;
  }
}
