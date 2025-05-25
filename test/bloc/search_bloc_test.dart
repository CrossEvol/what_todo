import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_app/dao/search_db.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_app/pages/labels/label.dart';

import '../mocks/fake-database.mocks.dart';

// Helper function to create a test task
Task createTestTask({
  int id = 1,
  String title = "Test Task",
  TaskStatus status = TaskStatus.PENDING,
}) {
  return Task.create(
    title: title,
    projectId: 1,
    priority: PriorityStatus.PRIORITY_1,
  )
    ..id = id
    ..projectName = "Test Project"
    ..projectColor = Colors.blue.value
    ..dueDate = DateTime.now().millisecondsSinceEpoch
    ..tasksStatus = status
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

void main() {
  late MockSearchDB mockSearchDB;
  late SearchBloc searchBloc;

  setUp(() {
    mockSearchDB = MockSearchDB();
    searchBloc = SearchBloc(mockSearchDB);
  });

  tearDown(() {
    searchBloc.close();
  });

  group('SearchBloc', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] when SearchTasksEvent is added',
      build: () {
        // Setup mock response for search
        final mockTasks = [
          createTestTask(id: 1, title: "First Test Task"),
          createTestTask(id: 2, title: "Second Test Task"),
        ];

        when(mockSearchDB.searchTasks(
          keyword: 'Test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: mockTasks,
              currentPage: 1,
              totalPages: 1,
              totalItems: 2,
            ));

        return SearchBloc(mockSearchDB);
      },
      act: (bloc) => bloc.add(const SearchTasksEvent(
        keyword: 'Test',
        searchInTitle: true,
        searchInComment: true,
        filteredField: FilteredField.title,
        order: SearchResultsOrder.asc,
        page: 1,
      )),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.searchTasks(
          keyword: 'Test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.tasks.length, 2);
        expect(state.keyword, 'Test');
        expect(state.currentPage, 1);
        expect(state.totalPages, 1);
        expect(state.totalItems, 2);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated tasks when MarkTaskAsDoneEvent is added',
      build: () {
        final task = createTestTask(id: 1, title: "Test Task");

        // Setup mock responses
        when(mockSearchDB.markTaskAsDone(1)).thenAnswer((_) async => true);

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: [
                createTestTask(
                    id: 1, title: "Test Task", status: TaskStatus.COMPLETE),
              ],
              currentPage: 1,
              totalPages: 1,
              totalItems: 1,
            ));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: [task]));
        return bloc;
      },
      act: (bloc) => bloc.add(MarkTaskAsDoneEvent(createTestTask(id: 1))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.markTaskAsDone(1)).called(1);
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.tasks.first.tasksStatus, TaskStatus.COMPLETE);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated tasks when DeleteTaskEvent is added',
      build: () {
        final tasks = [
          createTestTask(id: 1, title: "Task 1"),
          createTestTask(id: 2, title: "Task 2"),
        ];

        // Setup mock responses
        when(mockSearchDB.deleteTask(1)).thenAnswer((_) async => true);

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: [createTestTask(id: 2, title: "Task 2")],
              currentPage: 1,
              totalPages: 1,
              totalItems: 1,
            ));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: tasks));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteTaskEvent(createTestTask(id: 1))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.deleteTask(1)).called(1);
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.tasks.length, 1);
        expect(state.tasks.first.id, 2);
      },
    );
    blocTest<SearchBloc, SearchState>(
      'emits [SearchInitial] when ResetSearchEvent is added',
      build: () {
        // Start with a non-initial state
        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState());
        return bloc;
      },
      act: (bloc) => bloc.add(ResetSearchEvent()),
      expect: () => [
        isA<SearchInitial>(),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated sort field when UpdateSortFieldEvent is added',
      build: () {
        // Setup mock response for search with updated sort field
        final mockTasks = [
          createTestTask(id: 2, title: 'Second Task'),
          createTestTask(id: 1, title: 'First Task'),
        ];

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.id,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: mockTasks,
              currentPage: 1,
              totalPages: 1,
              totalItems: 2,
            ));

        // Start with existing search results
        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState());
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateSortFieldEvent(FilteredField.id)),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.id,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.filteredField, FilteredField.id);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated sort order when UpdateSortOrderEvent is added',
      build: () {
        // Setup mock response for search with updated sort order
        final mockTasks = [
          createTestTask(id: 2, title: 'Second Task'),
          createTestTask(id: 1, title: 'First Task'),
        ];

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.desc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: mockTasks,
              currentPage: 1,
              totalPages: 1,
              totalItems: 2,
            ));

        // Start with existing search results
        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState());
        return bloc;
      },
      act: (bloc) => bloc.add(const UpdateSortOrderEvent(SearchResultsOrder.desc)),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.desc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.order, SearchResultsOrder.desc);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated page when NavigateToPageEvent is added',
      build: () {
        // Setup mock response for search with updated page
        final mockTasks = [
          createTestTask(id: 3, title: 'Third Task'),
          createTestTask(id: 4, title: 'Fourth Task'),
        ];

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 2,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: mockTasks,
              currentPage: 2,
              totalPages: 2,
              totalItems: 4,
            ));

        // Start with existing search results on page 1
        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState());
        return bloc;
      },
      act: (bloc) => bloc.add(const NavigateToPageEvent(2)),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 2,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.currentPage, 2);
        expect(state.tasks.length, 2);
        expect(state.tasks[0].title, 'Third Task');
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoadingState, SearchResultsState] with updated tasks when MarkTaskAsUndoneEvent is added',
      build: () {
        final task = createTestTask(id: 1, title: "Test Task", status: TaskStatus.COMPLETE);

        // Setup mock responses
        when(mockSearchDB.markTaskAsUndone(1)).thenAnswer((_) async => true);

        when(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenAnswer((_) async => SearchResult(
              tasks: [
                createTestTask(
                    id: 1, title: "Test Task", status: TaskStatus.PENDING),
              ],
              currentPage: 1,
              totalPages: 1,
              totalItems: 1,
            ));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: [task]));
        return bloc;
      },
      act: (bloc) => bloc.add(MarkTaskAsUndoneEvent(createTestTask(id: 1, status: TaskStatus.COMPLETE))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchResultsState>(),
      ],
      verify: (bloc) {
        verify(mockSearchDB.markTaskAsUndone(1)).called(1);
        verify(mockSearchDB.searchTasks(
          keyword: 'test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).called(1);

        final state = bloc.state as SearchResultsState;
        expect(state.tasks.first.tasksStatus, TaskStatus.PENDING);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchErrorState] when SearchTasksEvent fails',
      build: () {
        when(mockSearchDB.searchTasks(
          keyword: 'Test',
          searchInTitle: true,
          searchInComment: true,
          filteredField: FilteredField.title,
          order: SearchResultsOrder.asc,
          page: 1,
          itemsPerPage: 10,
        )).thenThrow(Exception('Database error'));

        return SearchBloc(mockSearchDB);
      },
      act: (bloc) => bloc.add(const SearchTasksEvent(
        keyword: 'Test',
        searchInTitle: true,
        searchInComment: true,
        filteredField: FilteredField.title,
        order: SearchResultsOrder.asc,
        page: 1,
      )),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchErrorState>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SearchErrorState;
        expect(state.error, contains('Failed to search tasks'));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchErrorState] when MarkTaskAsDoneEvent fails',
      build: () {
        final task = createTestTask(id: 1);
        
        when(mockSearchDB.markTaskAsDone(1)).thenThrow(Exception('Database error'));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: [task]));
        return bloc;
      },
      act: (bloc) => bloc.add(MarkTaskAsDoneEvent(createTestTask(id: 1))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchErrorState>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SearchErrorState;
        expect(state.error, contains('Failed to mark task as done'));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchErrorState] when MarkTaskAsUndoneEvent fails',
      build: () {
        final task = createTestTask(id: 1, status: TaskStatus.COMPLETE);
        
        when(mockSearchDB.markTaskAsUndone(1)).thenThrow(Exception('Database error'));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: [task]));
        return bloc;
      },
      act: (bloc) => bloc.add(MarkTaskAsUndoneEvent(createTestTask(id: 1, status: TaskStatus.COMPLETE))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchErrorState>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SearchErrorState;
        expect(state.error, contains('Failed to mark task as undone'));
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchErrorState] when DeleteTaskEvent fails',
      build: () {
        final task = createTestTask(id: 1);
        
        when(mockSearchDB.deleteTask(1)).thenThrow(Exception('Database error'));

        final bloc = SearchBloc(mockSearchDB);
        bloc.emit(createSearchResultsState(tasks: [task]));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteTaskEvent(createTestTask(id: 1))),
      expect: () => [
        isA<SearchLoadingState>(),
        isA<SearchErrorState>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SearchErrorState;
        expect(state.error, contains('Failed to delete task'));
      },
    );
  });
}
