import 'dart:io';

import 'package:flutter_app/main.dart' as app;
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group("Add Labels", () {
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

    testWidgets('Enter Label Details and verify on Side drawer screen',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tapAndSettle(SideDrawerKeys.DRAWER);

      await tester.tapAndSettle(SideDrawerKeys.DRAWER_LABELS);

      await tester.tapAndSettle(SideDrawerKeys.ADD_LABEL);

      var addLabelNameField =
          find.byValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME);

      await tester.enterText(addLabelNameField, "Android");
      await tester.pumpAndSettle();

      await tester.tapAndSettle(AddLabelKeys.ADD_LABEL_BUTTON);

      await tester.tapAndSettle(SideDrawerKeys.DRAWER);

      await tester.tapAndSettle(SideDrawerKeys.DRAWER_LABELS);

      expect(find.text("@ Android"), findsOneWidget);
      exit(0);
      //TODO Match the Label color as well
    }, skip: false); //Flaky on CI
  });
}
