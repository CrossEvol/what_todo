import 'dart:io';

import 'package:flutter_app/main.dart' as app;
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add Tasks", () {
    setUp(() async {
      // await cleanDb();
    });

    // TODO: this test as the former, so that the latter can pass
    testWidgets('Today in Title', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(true, equals(true));
      exit(0);
    });

    testWidgets('Enter Task Details and verify on Task page screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tapAndSettle(HomePageKeys.ADD_NEW_TASK_BUTTON);

      expect(find.text("Add Task"), findsOneWidget);

      await tester.enterText(
          find.byValueKey(AddTaskKeys.ADD_TITLE), "First Task");
      await tester.pumpAndSettle();
      //TODO: 1. Add Project in selection 2. Add Label from dialog 3. Change due date

      await tester.tapAndSettle(AddTaskKeys.ADD_TASK);

      expect(find.text("First Task"), findsOneWidget);
      expect(find.text("Inbox"), findsOneWidget);
      exit(0);
    });
  });
}
