// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    {
      expect(find.text('Today'), findsNWidgets(2));
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Next 7 Days'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    }

    // Verify the AppBar has the leading icon and trailing icon
    {
      // expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.adaptive.more), findsOneWidget);
    }

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    {
      expect(find.text('Add Task'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Labels'), findsOneWidget);
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    }

    await tester.enterText(find.byType(TextFormField), 'test');
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    {
      expect(find.text('Add Task'), findsNothing);
    }

    //
    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();
    //
    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);
  });
}
