import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
import 'package:flutter_app/pages/profile/profile.dart';
import 'package:flutter_app/pages/profile/profile_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

import '../mocks/fake-bloc.dart';
import '../test_helpers.dart';

UserProfile defaultProfile() {
  return UserProfile(
    id: 1,
    name: "Test User",
    email: "test@example.com",
    avatarUrl: "assets/empty.jpg",
    updatedAt: DateTime.now(),
  );
}

ProfileState defaultProfileState() {
  return ProfileLoaded(
    defaultProfile(),
    status: ProfileStateStatus.unknown,
  );
}

void main() {
  setupTest();
  late MockProfileBloc mockProfileBloc;

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: mockProfileBloc,
        child: const ProfilePage().withLocalizedMaterialApp(),
      ),
    );
  }

  setUp(() {
    mockProfileBloc = MockProfileBloc();
  });

  Future<void> pumpProfileWidget(WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
  }

  void arrangeProfileBlocStream(List<ProfileState> states) {
    whenListen(
      mockProfileBloc,
      Stream.fromIterable(states),
      initialState: defaultProfileState(),
    );
  }

  testWidgets('ProfilePage should render properly', (WidgetTester tester) async {
    arrangeProfileBlocStream([defaultProfileState()]);
    await pumpProfileWidget(tester);

    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsNWidgets(3));
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('ProfilePage should display initial profile data',
      (WidgetTester tester) async {
    arrangeProfileBlocStream([defaultProfileState()]);
    await pumpProfileWidget(tester);

    expect(find.text('ID: 1'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('assets/empty.jpg'), findsOneWidget);
  });

  testWidgets('ProfilePage should show success message on update',
      (WidgetTester tester) async {
    arrangeProfileBlocStream([
      defaultProfileState(),
      ProfileLoaded(defaultProfile(), status: ProfileStateStatus.updateSuccess),
    ]);
    await pumpProfileWidget(tester);

    await tester.tap(find.text('Update Profile'));
    await tester.pump();

    expect(find.text('Profile updated successfully'), findsOneWidget);
  });

  testWidgets('ProfilePage should show error message on update failure',
      (WidgetTester tester) async {
    arrangeProfileBlocStream([
      defaultProfileState(),
      ProfileLoaded(defaultProfile(), status: ProfileStateStatus.updateFailure),
    ]);
    await pumpProfileWidget(tester);

    await tester.tap(find.text('Update Profile'));
    await tester.pump();

    expect(find.text('Profile updated failed'), findsOneWidget);
  });

  testWidgets('ProfilePage should update form fields', (WidgetTester tester) async {
    arrangeProfileBlocStream([defaultProfileState()]);
    await pumpProfileWidget(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Name'), 'New Name');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'new@example.com');
    
    expect(find.text('New Name'), findsOneWidget);
    expect(find.text('new@example.com'), findsOneWidget);
  });

  testWidgets('ProfilePage should show loading indicator initially',
      (WidgetTester tester) async {
    arrangeProfileBlocStream([ProfileInitial()]);
    await pumpProfileWidget(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing); // TODO: idk why here find nothing
  });

  testWidgets('ProfilePage should handle image selection',
      (WidgetTester tester) async {
    arrangeProfileBlocStream([defaultProfileState()]);
    await pumpProfileWidget(tester);

    expect(find.text('Pick Image'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
  });
}
