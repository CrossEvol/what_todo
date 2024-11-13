import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_helpers.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await setupSharedPreference();

  testWidgets('AboutUsPage Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp().withThemeProvider());

    if (Platform.isWindows) {
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('About'), findsNothing);
    }

    if (Platform.isAndroid) {
      expect(find.byIcon(Icons.info), findsNothing);
      expect(find.text('About'), findsNothing);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();
    }

    await tester.tap(find.byIcon(Icons.info));
    await tester.pump();

    expect(find.text('About'),
        findsNothing); // if want to find AboutScreen after tap the Icons.info, need to integrate with goRouter
  });

  testWidgets('AboutUsPage UnitTest', (WidgetTester tester) async {
    await tester.pumpWidget(AboutUsScreen().withLocalizedMaterialApp());

    // Wait for localizations to load
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(3));
  });
}
