// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration_test/test_helper.dart';

void main() {
  testWidgets('IntegrationTest for the complete App',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    if (Platform.isWindows) {
      expect(find.text('Today'), findsNWidgets(2));
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Next 7 Days'), findsOneWidget);
      expect(find.byValueKey(HomePageKeys.ADD_NEW_TASK_BUTTON), findsOneWidget);
    }

    // Verify the AppBar has the leading icon and trailing icon
    if (Platform.isAndroid) {
      expect(find.byIcon(Icons.menu), findsOneWidget);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      expect(find.text('Today'), findsNWidgets(2));
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Next 7 Days'), findsOneWidget);
    }

    expect(find.byIcon(Icons.adaptive.more), findsOneWidget);

    await tester.tap(find.byValueKey(HomePageKeys.ADD_NEW_TASK_BUTTON));
    await tester.pump();

    {
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.byValueKey(AddTaskKeys.ADD_TASK), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    }

    await tester.enterText(find.byType(TextFormField), 'test');
    await tester.pump();
    await tester.tap(find.byValueKey(AddTaskKeys.ADD_TASK));
    await tester.pump();

    {
      expect(find.text('Add Task'), findsNothing);
    }
  });
}
