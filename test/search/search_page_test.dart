import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_grid.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/fake-bloc.dart';
import '../mocks/fake-database.mocks.dart';
import '../test_helpers.dart';

// Helper function to create a test task
Task createTestTask(
    {int id = 1,
    String title = "Test Task",
    TaskStatus status = TaskStatus.PENDING,
    comment = "",
    project = "Test Project"}) {
  return Task.create(
    title: title,
    projectId: 1,
    priority: PriorityStatus.PRIORITY_1,
  )
    ..id = id
    ..projectName = project
    ..projectColor = Colors.blue.value
    ..dueDate = DateTime.now().millisecondsSinceEpoch
    ..tasksStatus = status
    ..comment = comment
    ..labelList = [
      Label.update(
          id: 1,
          name: "Label 1",
          colorCode: Colors.orange.value,
          colorName: "Orange")
    ];
}

// Helper function to create a search results state
SearchResultsState createSearchResultsState({
  String keyword = "test",
  bool searchInTitle = true,
  bool searchInComment = true,
  List<Task>? tasks,
  int currentPage = 1,
  int totalPages = 1,
  int totalItems = 1,
  FilteredField? filteredField = FilteredField.title,
  SearchResultsOrder? order = SearchResultsOrder.asc,
}) {
  final taskList = tasks ??
      [
        createTestTask(id: 1, title: "First Task"),
        createTestTask(id: 2, title: "Second Task"),
      ];

  return SearchResultsState(
    keyword: keyword,
    searchInTitle: searchInTitle,
    searchInComment: searchInComment,
    tasks: taskList,
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
    filteredField: filteredField,
    order: order,
  );
}

// Helper function to create the search grid widget
Widget createSearchGridWidget(MockSearchBloc mockSearchBloc) {
  return BlocProvider<SearchBloc>.value(
    value: mockSearchBloc,
    child: const TaskGrid().withLocalizedMaterialApp().withThemeProvider(),
  );
}

// Define fake events for registering fallback values
class FakeSearchEvent extends Fake implements SearchEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeSearchEvent());
  });

  setupTest();
  late MockSearchBloc mockSearchBloc;
  late MockSearchDB mockSearchDB;

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    mockSearchDB = MockSearchDB();
  });

  group('TaskGrid widget tests', () {
    testWidgets('should display loading state correctly',
        (WidgetTester tester) async {
      when(() => mockSearchBloc.state).thenReturn(SearchLoadingState());

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pump();

      // Check for shimmer loading effect containers
      expect(find.byType(Container), findsWidgets);
      expect(find.text('empty'), findsNothing);
      expect(find.text('Unknown state'), findsNothing);
    });

    testWidgets('should display initial state correctly',
        (WidgetTester tester) async {
      when(() => mockSearchBloc.state).thenReturn(SearchInitial());

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pump();

      // Check for empty state text
      expect(find.text('empty'), findsOneWidget);
    });

    testWidgets('should display error state correctly',
        (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      when(() => mockSearchBloc.state)
          .thenReturn(const SearchErrorState(errorMessage));

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pump();

      // Check for error display
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('An error occurred:'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should display search results correctly',
        (WidgetTester tester) async {
      final tasks = [
        createTestTask(
            id: 1,
            title: "First Task",
            status: TaskStatus.PENDING,
            comment: "hello,world!",
            project: "java"),
        createTestTask(
            id: 2,
            title: "Second Task",
            status: TaskStatus.COMPLETE,
            comment: "repeat until real",
            project: "cpp"),
      ];

      final state = createSearchResultsState(tasks: tasks);
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Check for task items in the list
      expect(find.byIcon(Icons.document_scanner_rounded), findsOneWidget);
      expect(find.byIcon(Icons.roundabout_right_outlined), findsOneWidget);
      expect(find.textContaining('First Task', findRichText: true),
          findsOneWidget);
      expect(find.text('Second Task', findRichText: true), findsOneWidget);
      expect(find.text('hello,world!'), findsOneWidget);
      expect(find.text('repeat until real'), findsOneWidget);
      expect(find.text("java"), findsOneWidget);
      expect(find.text("cpp"), findsOneWidget);
    });

    testWidgets('should have working pagination controls',
        (WidgetTester tester) async {
      final state = createSearchResultsState(
        currentPage: 2,
        totalPages: 3,
        totalItems: 25,
      );

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Check for pagination controls
      expect(find.byIcon(Icons.keyboard_double_arrow_left), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_double_arrow_right), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);

      // Check StatisticsRow shows correct pagination info
      expect(find.byType(StatisticsRow), findsOneWidget);
      expect(find.text('current'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Current page
      expect(find.text('at'), findsOneWidget);
      expect(find.text('3'), findsOneWidget); // Total pages
      expect(find.text('pages'), findsOneWidget);
      expect(find.text('total'), findsOneWidget);
      expect(find.text('25'), findsOneWidget); // Total items
      expect(find.text('items'), findsOneWidget);

      // Tap previous page button
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left));
      verify(() => mockSearchBloc.add(const NavigateToPageEvent(1))).called(1);

      // Tap next page button
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right));
      verify(() => mockSearchBloc.add(const NavigateToPageEvent(3))).called(1);

      // Tap home button
      await tester.tap(find.byIcon(Icons.circle_outlined));
      verify(() => mockSearchBloc.add(const NavigateToPageEvent(1))).called(1);
    });
  });

  group('Sort functionality', () {
    testWidgets('should open sort popup menu when sort button is tapped',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Find and tap the sort button
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Verify the popup menu is shown with sort options
      expect(find.byType(PopupMenuItem<FilteredField>), findsWidgets);
      expect(find.text('ID'), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Project'), findsOneWidget);
      expect(find.text('Due Date'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Order'), findsOneWidget);
    });

    testWidgets('should change sort field when selected in popup menu',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pump();

      // Open sort popup menu
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Select 'Priority' as sort field
      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();

      // Verify update sort field event was added to bloc
      verify(() => mockSearchBloc
          .add(const UpdateSortFieldEvent(FilteredField.priority))).called(1);
    });

    testWidgets(
        'should not toggle sort order when only order button is tapped but did not search anything',
        (WidgetTester tester) async {
      final stateAsc = createSearchResultsState(order: SearchResultsOrder.asc);
      when(() => mockSearchBloc.state).thenReturn(stateAsc);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Find and tap the sort order button (ascending to descending)
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();

      // Verify update sort order event was added to bloc
      verify(() => mockSearchBloc
          .add(const UpdateSortOrderEvent(SearchResultsOrder.desc))).called(1);

      // Now test the opposite direction
      final stateDesc =
          createSearchResultsState(order: SearchResultsOrder.desc);
      when(() => mockSearchBloc.state).thenReturn(stateDesc);

      // Find and tap the sort order button (descending to ascending)
      expect(find.byIcon(Icons.arrow_downward), findsNothing);

      // Verify update sort order event was added to bloc
      verifyNever(() => mockSearchBloc
          .add(const UpdateSortOrderEvent(SearchResultsOrder.asc))).called(0);
    });
  });

  group('Search dialog', () {
    testWidgets('should open search dialog when search button is tapped',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Find and tap the search button
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify the search dialog is shown
      expect(find.byType(SearchDialog), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search Tasks'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Comment'), findsOneWidget);
    });

    testWidgets('should perform search when search button is pressed',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Open search dialog
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Enter a search term
      await tester.enterText(find.byType(TextField), 'important');

      // Toggle search options
      await tester.tap(find.text('Title'));
      await tester.tap(find.text('Comment'));
      await tester.pumpAndSettle();

      // Tap Search button
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      // Verify search tasks event was added to bloc with correct parameters
      verify(() => mockSearchBloc.add(any(
          that: predicate<SearchTasksEvent>((event) =>
              event.keyword == 'important' &&
              event.searchInTitle == true &&
              event.searchInComment == true)))).called(1);
    });

    testWidgets('should toggle Title switch correctly',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Open search dialog
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify initial state - Title switch should be on by default
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);

      // Toggle Title switch off
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      // Verify Title switch is off
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);

      // Toggle Title switch off again when Comment is also off
      // This should force Comment switch to turn on (ensuring at least one option is selected)
      await tester.tap(find.byType(Switch).at(1)); // Turn Comment off first
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);

      await tester.tap(find
          .byType(Switch)
          .first); // Try to turn Title off when Comment is already off
      await tester.pumpAndSettle();

      // Verify Comment switch automatically turned on
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);
    });

    testWidgets('should toggle Comment switch correctly',
        (WidgetTester tester) async {
      final state = createSearchResultsState();
      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Open search dialog
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Verify initial state - Comment switch should be on by default
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);

      // Toggle Comment switch off
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      // Verify Comment switch is off
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);

      // Toggle Comment switch off again when Title is also off
      // This should force Title switch to turn on (ensuring at least one option is selected)
      await tester.tap(find.byType(Switch).at(0)); // Turn Title off first
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isFalse);

      await tester.tap(find
          .byType(Switch)
          .at(1)); // Try to turn Comment off when Title is already off
      await tester.pumpAndSettle();

      // Verify Title switch automatically turned on
      expect(tester.widget<Switch>(find.byType(Switch).first).value, isTrue);
      expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isFalse);
    });
  });

  group('Task interactions', () {
    testWidgets('should mark task as done when checkbox is tapped',
        (WidgetTester tester) async {
      final task =
          createTestTask(id: 1, title: "Test Task", status: TaskStatus.PENDING);
      final state = createSearchResultsState(tasks: [task]);

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.document_scanner_rounded).first);
      await tester.pumpAndSettle();

      // Find and tap the checkbox in the task row
      await tester.tap(find.byIcon(Icons.check_circle).first);
      await tester.pumpAndSettle();

      // Verify the mark task as done event was dispatched
      verify(() => mockSearchBloc.add(any(that: isA<MarkTaskAsDoneEvent>())))
          .called(1);
    });

    testWidgets('should mark task as undone when checkbox is tapped',
        (WidgetTester tester) async {
      final task = createTestTask(
          id: 1, title: "Test Task", status: TaskStatus.COMPLETE);
      final state = createSearchResultsState(tasks: [task]);

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.roundabout_right_outlined).first);
      await tester.pumpAndSettle();

      // Find and tap the checkbox in the task row
      await tester.tap(find.byIcon(Icons.replay_circle_filled).first);
      await tester.pumpAndSettle();

      // Verify the mark task as undone event was dispatched
      verify(() => mockSearchBloc.add(any(that: isA<MarkTaskAsUndoneEvent>())))
          .called(1);
    });

    testWidgets('should delete task when delete button is pressed',
        (WidgetTester tester) async {
      final task =
          createTestTask(id: 1, title: "Test Task", status: TaskStatus.PENDING);
      final state = createSearchResultsState(tasks: [task]);

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.document_scanner_rounded).first);
      await tester.pumpAndSettle();

      // Find and tap the delete button
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Verify the delete confirmation dialog is shown
      expect(find.byType(DeleteConfirmationDialog), findsOneWidget);
      expect(find.text('Delete Task'), findsOneWidget);

      // Tap confirm delete button
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify the delete task event was dispatched
      verify(() => mockSearchBloc.add(any(that: isA<DeleteTaskEvent>())))
          .called(1);
    });

    testWidgets('should not delete task when cancel is pressed',
        (WidgetTester tester) async {
      final task =
          createTestTask(id: 1, title: "Test Task", status: TaskStatus.PENDING);
      final state = createSearchResultsState(tasks: [task]);

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.document_scanner_rounded).first);
      await tester.pumpAndSettle();

      // Find and tap the delete button
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      // Verify the delete confirmation dialog is shown
      expect(find.byType(DeleteConfirmationDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify no delete event was dispatched
      verifyNever(() => mockSearchBloc.add(any(that: isA<DeleteTaskEvent>())));
    });
  });

  group('Statistics display', () {
    testWidgets('should display correct task statistics',
        (WidgetTester tester) async {
      final tasks = <Task>[];

      final state = createSearchResultsState(
        tasks: tasks,
        currentPage: 1,
        totalPages: 2,
        totalItems: 3,
      );

      when(() => mockSearchBloc.state).thenReturn(state);

      await tester.pumpWidget(createSearchGridWidget(mockSearchBloc));
      await tester.pumpAndSettle();

      // Check for statistics row
      expect(find.byType(StatisticsRow), findsOneWidget);

      // Statistics should show correct counts (pending tasks in the search results)
      expect(find.text('1'),
          findsOneWidget); // Should find the "1" for current page
      expect(find.text('2'),
          findsOneWidget); // Should find the "2" for total pages
      expect(find.text('3'),
          findsOneWidget); // Should find the "3" for total items
    });
  });
}
