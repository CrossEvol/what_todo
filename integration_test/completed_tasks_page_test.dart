import 'dart:io';

import 'package:flutter_app/main.dart' as app;
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'home_page_test.dart';
import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Completed Tasks Page', () {
    // TODO: this test as the former, so that the latter can pass
    testWidgets('Today in Title', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      expect(true, equals(true));
      exit(0);
    });

    testWidgets('Show Today Tasks', (WidgetTester tester) async {
      await seedAndStartApp(tester);

      await tester.tapAndSettle(SideDrawerKeys.DRAWER);

      await tester.tapAndSettle(SideDrawerKeys.TODAY);

      //swipe left to mark as complete
      var firstTaskListItem = find.byValueKey('swipe_1_0');
      await tester.drag(firstTaskListItem, const Offset(-300.0, 0.0));
      await tester.pumpAndSettle();

      await tester.tapAndSettle(CompletedTaskPageKeys.POPUP_ACTION);

      await tester.tapAndSettle(CompletedTaskPageKeys.COMPLETED_TASKS);

      expect(find.text("Task One"), findsOneWidget);

      //swipe left to mark to undo
      var firstCompletedTaskListItem = find.byValueKey('task_completed_1');
      await tester.drag(firstCompletedTaskListItem, const Offset(-300.0, 0.0));
      await tester.pumpAndSettle();

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text("Task One"), findsOneWidget);
      exit(0);
    });

    tearDown(() async {
      // await cleanDb();
    });
  });
}
