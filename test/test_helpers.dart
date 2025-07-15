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

  Future<void> scrollThePage() async {
    // 找到可滚动的列表视图
    final scrollableFinder = find.byType(Scrollable).first;

    // 手动向下滚动一个较大的距离，确保 "Security" 部分进入视图
    // Offset(0, -800) 表示向下拖动800个逻辑像素
    await drag(scrollableFinder, const Offset(0, -800));

    // 等待滚动动画结束并且UI重建完成
    await pumpAndSettle();
  }
}

Future<void> setupTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await setupSharedPreference();
}
