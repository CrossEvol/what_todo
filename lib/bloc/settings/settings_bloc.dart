import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/setting_type.dart';
import 'package:flutter_app/pages/settings/setting.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(SettingsState(
          useCountBadges: false,
          enableImportExport: false,
          status: ResultStatus.none,
          updatedKey: '',
        )) {
    on<LoadSettingsEvent>(_loadSettings);
    on<ToggleUseCountBadgesEvent>(_toggleUseCountBadges);
    on<ToggleEnableImportExport>(_toggleEnableExportImport);
    on<SettingsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  FutureOr<void> _toggleUseCountBadges(
      ToggleUseCountBadgesEvent event, Emitter<SettingsState> emit) async {
    final settingsDB = SettingsDB.get();
    final setting = await settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
    if (setting == null) return;
    settingsDB.updateSetting(Setting.update(
        id: setting.id,
        key: setting.key,
        value: '${!bool.parse(setting.value)}',
        updatedAt: DateTime.now(),
        type: setting.type));
    emit(state.copyWith(
      useCountBadges: !state.useCountBadges,
      updatedKey: SettingKeys.USE_COUNT_BADGES,
      status: ResultStatus.success,
    ));
  }

  FutureOr<void> _toggleEnableExportImport(
      ToggleEnableImportExport event, Emitter<SettingsState> emit) async {
    final settingsDB = SettingsDB.get();
    final setting =
        await settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
    if (setting == null) return;
    settingsDB.updateSetting(Setting.update(
        id: setting.id,
        key: setting.key,
        value: '${!bool.parse(setting.value)}',
        updatedAt: DateTime.now(),
        type: setting.type));
    emit(state.copyWith(
      enableImportExport: !state.enableImportExport,
      updatedKey: SettingKeys.ENABLE_IMPORT_EXPORT,
      status: ResultStatus.success,
    ));
  }

  FutureOr<void> _loadSettings(
      LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    final settingsDB = SettingsDB.get();

    bool useCountBadges = await _getUseCountBadges(settingsDB);
    emit(state.copyWith(useCountBadges: useCountBadges));

    bool enableImportExport = await _getEnableImportExport(settingsDB);
    emit(state.copyWith(enableImportExport: enableImportExport));
  }

  Future<bool> _getUseCountBadges(SettingsDB settingsDB) async {
    bool useCountBadges = false;
    final setting = await settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
    if (setting == null) {
      var created = await settingsDB.createSetting(Setting.create(
          key: SettingKeys.USE_COUNT_BADGES,
          value: 'true',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
        if (newSetting == null) {
          logger.warn('Insert ${SettingKeys.USE_COUNT_BADGES} failed.');
          return useCountBadges;
        }
        useCountBadges = bool.parse(newSetting.value);
      }
    } else {
      useCountBadges = bool.parse(setting.value);
    }
    return useCountBadges;
  }

  Future<bool> _getEnableImportExport(SettingsDB settingsDB) async {
    bool enableImportExport = false;
    final setting =
        await settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
    if (setting == null) {
      var created = await settingsDB.createSetting(Setting.create(
          key: SettingKeys.ENABLE_IMPORT_EXPORT,
          value: 'true',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
        if (newSetting == null) {
          logger.warn('Insert ${SettingKeys.ENABLE_IMPORT_EXPORT} failed.');
          return enableImportExport;
        }
        enableImportExport = bool.parse(newSetting.value);
      }
    } else {
      enableImportExport = bool.parse(setting.value);
    }
    return enableImportExport;
  }
}
