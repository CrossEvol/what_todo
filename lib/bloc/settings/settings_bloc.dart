import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
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
          environment: Environment.development,
        )) {
    on<LoadSettingsEvent>(_loadSettings);
    on<ToggleUseCountBadgesEvent>(_toggleUseCountBadges);
    on<ToggleEnableImportExport>(_toggleEnableExportImport);
    on<ToggleEnvironment>(_toggleEnvironment);
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

    var environment = await _getEnvironment(settingsDB);
    emit(state.copyWith(environment: environment));
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

  Future<Environment> _getEnvironment(SettingsDB settingsDB) async {
    String environment = '';
    final setting = await settingsDB.findByName(SettingKeys.Environment);
    if (setting == null) {
      var created = await settingsDB.createSetting(Setting.create(
          key: SettingKeys.Environment,
          value: Environment.development.name,
          updatedAt: DateTime.now(),
          type: SettingType.Text));
      if (created) {
        final newSetting = await settingsDB.findByName(SettingKeys.Environment);
        if (newSetting == null) {
          logger.warn('Insert ${SettingKeys.Environment} failed.');
          environment = Environment.development.name;
        } else {
          environment = newSetting.value;
        }
      }
    } else {
      environment = Environment.development.name;
    }
    return environment.toEnvironment();
  }

  FutureOr<void> _toggleEnvironment(
      ToggleEnvironment event, Emitter<SettingsState> emit) async {
    final settingsDB = SettingsDB.get();
    final setting = await settingsDB.findByName(SettingKeys.Environment);
    if (setting == null) return;
    settingsDB.updateSetting(
      Setting.update(
          id: setting.id,
          key: setting.key,
          value: event.environment.name,
          updatedAt: DateTime.now(),
          type: setting.type),
    );
    emit(
      state.copyWith(
        environment: event.environment,
        updatedKey: SettingKeys.Environment,
        status: ResultStatus.success,
      ),
    );
  }
}
