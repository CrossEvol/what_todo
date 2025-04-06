import 'package:flutter/material.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension TestWrapMaterialApp on Widget {
  Widget withLocalizedMaterialApp() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ja'),
        Locale('zh'),
      ],
      home: Scaffold(
        body: this,
      ),
    );
  }

  Widget wrapMaterialApp() {
    return MaterialApp(
      home: this,
    );
  }

  Widget wrapWithScaffold() {
    return MaterialApp(
      home: Scaffold(
        body: this,
      ),
    );
  }

  Widget withThemeProvider() {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: this,
    );
  }
}

extension TestContainer on Container {
  Color getBorderLeftColor() {
    final boxDecoration = this.decoration as BoxDecoration;
    final border = boxDecoration.border as Border;
    return border.left.color;
  }
}

extension TestWidgetFinder<T> on WidgetTester {
  T findWidgetByKey<T extends Widget>(String key) {
    var findKey = find.byKey(ValueKey(key));
    return this.firstWidget(findKey) as T;
  }
}

Future<void> setupTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await setupSharedPreference();
}
