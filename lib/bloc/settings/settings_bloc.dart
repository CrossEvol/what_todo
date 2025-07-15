import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/setting_type.dart';
import 'package:flutter_app/pages/settings/setting.dart';
import 'package:flutter_app/pages/settings/settings_db.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsDB _settingsDB;
  final ILogger _logger = ILogger();

  SettingsBloc(this._settingsDB)
      : super(SettingsState(
          useCountBadges: false,
          enableImportExport: false,
          confirmDeletion: true,
          status: ResultStatus.none,
          updatedKey: '',
          environment: Environment.development,
          language: Language.english,
          labelLen: 8,
          // Default value changed to 8
          projectLen: 8,
          // Default value changed to 8
          setLocale: (Locale) {},
          enableNotifications: false,
        )) {
    on<LoadSettingsEvent>(_loadSettings);
    on<ToggleUseCountBadgesEvent>(_toggleUseCountBadges);
    on<ToggleEnableImportExport>(_toggleEnableExportImport);
    on<ToggleEnvironment>(_toggleEnvironment);
    on<ToggleLanguage>(_toggleLanguage);
    on<ToggleLabelLen>(_toggleLabelLen); // Added
    on<ToggleProjectLen>(_toggleProjectLen); // Added
    on<AddSetLocaleFunction>(_addSetLocaleFunction);
    on<ToggleConfirmDeletion>(_toggleConfirmDeletion);
    on<ToggleEnableNotificationsEvent>(_toggleEnableNotifications);
  }

  FutureOr<void> _toggleUseCountBadges(
      ToggleUseCountBadgesEvent event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
    if (setting == null) return;
    _settingsDB.updateSetting(Setting.update(
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
    final setting =
        await _settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
    if (setting == null) return;
    _settingsDB.updateSetting(Setting.update(
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

  FutureOr<void> _toggleEnableNotifications(
      ToggleEnableNotificationsEvent event, Emitter<SettingsState> emit) async {
    final setting =
        await _settingsDB.findByName(SettingKeys.ENABLE_NOTIFICATIONS);
    if (setting == null) return;
    _settingsDB.updateSetting(Setting.update(
        id: setting.id,
        key: setting.key,
        value: '${!bool.parse(setting.value)}',
        updatedAt: DateTime.now(),
        type: setting.type));
    emit(state.copyWith(
      enableNotifications: !state.enableNotifications,
      updatedKey: SettingKeys.ENABLE_NOTIFICATIONS,
      status: ResultStatus.success,
    ));
  }

  FutureOr<void> _loadSettings(
      LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    final useCountBadges = await _getUseCountBadges(_settingsDB);
    emit(state.copyWith(useCountBadges: useCountBadges));

    final enableImportExport = await _getEnableImportExport(_settingsDB);
    emit(state.copyWith(enableImportExport: enableImportExport));

    final confirmDeletion = await _getConfirmDeletion(_settingsDB);
    emit(state.copyWith(confirmDeletion: confirmDeletion));

    final environment = await _getEnvironment(_settingsDB);
    emit(state.copyWith(environment: environment));

    final language = await _getLanguage(_settingsDB);
    emit(state.copyWith(language: language));

    final labelLen = await _getLabelLen(_settingsDB); // Added
    emit(state.copyWith(labelLen: labelLen)); // Added

    final projectLen = await _getProjectLen(_settingsDB); // Added
    emit(state.copyWith(projectLen: projectLen)); // Added

    final enableNotifications = await _getEnableNotifications(_settingsDB);
    emit(state.copyWith(enableNotifications: enableNotifications));
  }

  Future<bool> _getUseCountBadges(SettingsDB settingsDB) async {
    bool useCountBadges = false;
    final setting = await _settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.USE_COUNT_BADGES,
          value: 'true',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.USE_COUNT_BADGES);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.USE_COUNT_BADGES} failed.');
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
        await _settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.ENABLE_IMPORT_EXPORT,
          value: 'true',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.ENABLE_IMPORT_EXPORT);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.ENABLE_IMPORT_EXPORT} failed.');
          return enableImportExport;
        }
        enableImportExport = bool.parse(newSetting.value);
      }
    } else {
      enableImportExport = bool.parse(setting.value);
    }
    return enableImportExport;
  }

  Future<bool> _getEnableNotifications(SettingsDB settingsDB) async {
    bool enableNotifications = false;
    final setting =
        await _settingsDB.findByName(SettingKeys.ENABLE_NOTIFICATIONS);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.ENABLE_NOTIFICATIONS,
          value: 'true',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.ENABLE_NOTIFICATIONS);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.ENABLE_NOTIFICATIONS} failed.');
          return enableNotifications;
        }
        enableNotifications = bool.parse(newSetting.value);
      }
    } else {
      enableNotifications = bool.parse(setting.value);
    }
    return enableNotifications;
  }

  Future<Environment> _getEnvironment(SettingsDB settingsDB) async {
    final setting = await _settingsDB.findByName(SettingKeys.Environment);
    if (setting == null) {
      String environment = '';
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.Environment,
          value: Environment.development.name,
          updatedAt: DateTime.now(),
          type: SettingType.Text));
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.Environment);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.Environment} failed.');
          environment = Environment.development.name;
        } else {
          environment = newSetting.value;
        }
      }
      return environment.toEnvironment();
    } else {
      return setting.value.toEnvironment();
    }
  }

  // Added method _getLabelLen
  Future<int> _getLabelLen(SettingsDB settingsDB) async {
    const defaultLen = 8; // Default value changed to 8
    final setting = await _settingsDB.findByName(SettingKeys.LABEL_LEN);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.LABEL_LEN,
          value: '$defaultLen', // Store as string
          updatedAt: DateTime.now(),
          type: SettingType.IntNumber)); // Use Int type
      if (created) {
        final newSetting = await _settingsDB.findByName(SettingKeys.LABEL_LEN);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.LABEL_LEN} failed.');
          return defaultLen;
        }
        return int.tryParse(newSetting.value) ?? defaultLen;
      }
      return defaultLen;
    } else {
      return int.tryParse(setting.value) ?? defaultLen;
    }
  }

  // Added method _getProjectLen
  Future<int> _getProjectLen(SettingsDB settingsDB) async {
    const defaultLen = 8; // Default value changed to 8
    final setting = await _settingsDB.findByName(SettingKeys.PROJECT_LEN);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.PROJECT_LEN,
          value: '$defaultLen', // Store as string
          updatedAt: DateTime.now(),
          type: SettingType.IntNumber)); // Use Int type
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.PROJECT_LEN);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.PROJECT_LEN} failed.');
          return defaultLen;
        }
        return int.tryParse(newSetting.value) ?? defaultLen;
      }
      return defaultLen;
    } else {
      return int.tryParse(setting.value) ?? defaultLen;
    }
  }

  Future<bool> _getConfirmDeletion(SettingsDB settingsDB) async {
    const defaultValue = true; // Default to true for safety
    final setting = await _settingsDB.findByName(SettingKeys.CONFIRM_DELETION);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.CONFIRM_DELETION,
          value: '$defaultValue',
          updatedAt: DateTime.now(),
          type: SettingType.Bool));
      if (created) {
        final newSetting =
            await _settingsDB.findByName(SettingKeys.CONFIRM_DELETION);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.CONFIRM_DELETION} failed.');
          return defaultValue;
        }
        return bool.parse(newSetting.value);
      }
      return defaultValue;
    } else {
      return bool.parse(setting.value);
    }
  }

  FutureOr<void> _toggleEnvironment(
      ToggleEnvironment event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.Environment);
    if (setting == null) return;
    _settingsDB.updateSetting(
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

  Future<Language> _getLanguage(SettingsDB settingsDB) async {
    final setting = await _settingsDB.findByName(SettingKeys.LANGUAGE);
    if (setting == null) {
      var created = await _settingsDB.createSetting(Setting.create(
          key: SettingKeys.LANGUAGE,
          value: Language.english.name,
          updatedAt: DateTime.now(),
          type: SettingType.Text));
      if (created) {
        final newSetting = await _settingsDB.findByName(SettingKeys.LANGUAGE);
        if (newSetting == null) {
          _logger.warn('Insert ${SettingKeys.LANGUAGE} failed.');
          return Language.english;
        }
        return newSetting.value.toLanguage();
      }
      return Language.english;
    }
    return setting.value.toLanguage();
  }

  FutureOr<void> _toggleLanguage(
      ToggleLanguage event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.LANGUAGE);
    if (setting == null) return;

    await _settingsDB.updateSetting(Setting.update(
      id: setting.id,
      key: setting.key,
      value: event.language.name,
      updatedAt: DateTime.now(),
      type: setting.type,
    ));

    _updateLocaleBasedOnLanguage(event.language);

    emit(state.copyWith(
      language: event.language,
      updatedKey: SettingKeys.LANGUAGE,
      status: ResultStatus.success,
    ));
  }

  FutureOr<void> _addSetLocaleFunction(
      AddSetLocaleFunction event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(
      setLocale: event.setLocale,
    ));
    var language = await _getLanguage(_settingsDB);
    this.add(ToggleLanguage(language: language));
  }

  void _updateLocaleBasedOnLanguage(Language language) {
    Locale newLocale;
    switch (language) {
      case Language.english:
        newLocale = const Locale('en');
        break;
      case Language.japanese:
        newLocale = const Locale('ja');
        break;
      case Language.chinese:
        newLocale = const Locale('zh');
        break;
    }
    state.setLocale(newLocale);
    prefs.setLocale(language);
  }

  // Added handler _toggleLabelLen
  FutureOr<void> _toggleLabelLen(
      ToggleLabelLen event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.LABEL_LEN);
    if (setting == null) return;
    await _settingsDB.updateSetting(Setting.update(
      id: setting.id,
      key: setting.key,
      value: '${event.len}',
      // Store as string
      updatedAt: DateTime.now(),
      type: setting.type,
    ));
    emit(state.copyWith(
      labelLen: event.len,
      updatedKey: SettingKeys.LABEL_LEN,
      status: ResultStatus.success,
    ));
  }

  // Added handler _toggleProjectLen
  FutureOr<void> _toggleProjectLen(
      ToggleProjectLen event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.PROJECT_LEN);
    if (setting == null) return;
    await _settingsDB.updateSetting(Setting.update(
      id: setting.id,
      key: setting.key,
      value: '${event.len}',
      // Store as string
      updatedAt: DateTime.now(),
      type: setting.type,
    ));
    emit(state.copyWith(
      projectLen: event.len,
      updatedKey: SettingKeys.PROJECT_LEN,
      status: ResultStatus.success,
    ));
  }

  FutureOr<void> _toggleConfirmDeletion(
      ToggleConfirmDeletion event, Emitter<SettingsState> emit) async {
    final setting = await _settingsDB.findByName(SettingKeys.CONFIRM_DELETION);
    if (setting == null) return;
    _settingsDB.updateSetting(Setting.update(
        id: setting.id,
        key: setting.key,
        value: '${!bool.parse(setting.value)}',
        updatedAt: DateTime.now(),
        type: setting.type));
    emit(state.copyWith(
      confirmDeletion: !state.confirmDeletion,
      updatedKey: SettingKeys.CONFIRM_DELETION,
      status: ResultStatus.success,
    ));
  }
}
