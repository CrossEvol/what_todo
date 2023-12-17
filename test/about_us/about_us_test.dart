import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AboutUsPage Test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

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

    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('AboutUsPage UnitTest', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AboutUsScreen(),
      ),
    ));

    expect(find.text('About'), findsOneWidget);
    expect(find.text('Version'), findsOneWidget);
    expect(find.text('Author'), findsOneWidget);
    expect(find.byType(Card), findsAtLeastNWidgets(4));
  });
}
