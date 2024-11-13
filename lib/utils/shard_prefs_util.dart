import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

late final SharedPreferences prefs;

Future<void> setupSharedPreference() async {
  prefs = await SharedPreferences.getInstance();
}

extension ShardPrefsExtension on SharedPreferences {
  // TODO:
  // it is used for the mobile that can not set correct locale at the first time
  // though it can run perfectly in the desktop
  Future<void> setLocale(Language language) async {
    switch (language) {
      case Language.english:
        await this.setString(ShardPrefKeys.Locale, 'en');
        break;
      case Language.japanese:
        await this.setString(ShardPrefKeys.Locale, 'ja');
        break;
      case Language.chinese:
        await this.setString(ShardPrefKeys.Locale, 'zh');
        break;
    }
  }

  String getLocale() {
    return this.getString(ShardPrefKeys.Locale) ?? 'ja';
  }
}
