import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mocks/fake-database.mocks.dart';

void main() {
  late MockTaskDB taskDB;
  late HomeBloc homeBloc;

  setUp(() {
    taskDB = MockTaskDB();
    homeBloc = HomeBloc(taskDB);
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, isA<HomeInitial>());
    });

    blocTest<HomeBloc, HomeState>(
      'emits new state with updated title when UpdateTitleEvent is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const UpdateTitleEvent('New Title')),
      expect: () => [
        const HomeState(title: 'New Title'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with updated filter and screen when ApplyFilterEvent is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(ApplyFilterEvent('Today', Filter.byToday())),
      expect: () => [
        predicate<HomeState>((state) =>
            state.title == 'Today' &&
            state.filter?.filterStatus == FilterStatus.BY_TODAY &&
            state.screen == SCREEN.HOME),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with updated screen when UpdateScreenEvent is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const UpdateScreenEvent(SCREEN.ADD_TASK)),
      expect: () => [
        const HomeState(screen: SCREEN.ADD_TASK),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with today count when LoadTodayCountEvent is added',
      build: () {
        when(taskDB.countToday()).thenAnswer((_) async => 5);
        return homeBloc;
      },
      act: (bloc) => bloc.add(LoadTodayCountEvent()),
      expect: () => [
        const HomeState(todayCount: 5),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'maintains previous state values when updating individual properties',
      build: () => homeBloc,
      seed: () => HomeState(
        title: 'Initial Title',
        filter: Filter.byToday(),
        screen: SCREEN.HOME,
        todayCount: 3,
      ),
      act: (bloc) => bloc.add(const UpdateTitleEvent('New Title')),
      expect: () => [
        predicate<HomeState>((state) =>
            state.title == 'New Title' &&
            state.filter?.filterStatus == FilterStatus.BY_TODAY &&
            state.screen == SCREEN.HOME &&
            state.todayCount == 3),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'handles errors gracefully when loading today count fails',
      build: () {
        when(taskDB.countToday()).thenThrow(Exception('Database error'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(LoadTodayCountEvent()),
      expect: () => [], // Should not emit new state on error
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with project filter when applying project filter',
      build: () => homeBloc,
      act: (bloc) => bloc.add(ApplyFilterEvent('Project 1', Filter.byProject(1))),
      expect: () => [
        predicate<HomeState>((state) =>
            state.title == 'Project 1' &&
            state.filter?.filterStatus == FilterStatus.BY_PROJECT &&
            state.filter?.projectId == 1 &&
            state.screen == SCREEN.HOME),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with label filter when applying label filter',
      build: () => homeBloc,
      act: (bloc) => bloc.add(ApplyFilterEvent('Work', Filter.byLabel('Work'))),
      expect: () => [
        predicate<HomeState>((state) =>
            state.title == 'Work' &&
            state.filter?.filterStatus == FilterStatus.BY_LABEL &&
            state.filter?.labelName == 'Work' &&
            state.screen == SCREEN.HOME),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits new state with status filter when applying status filter',
      build: () => homeBloc,
      act: (bloc) => bloc.add(ApplyFilterEvent(
          'Completed', Filter.byStatus(TaskStatus.COMPLETE))),
      expect: () => [
        predicate<HomeState>((state) =>
            state.title == 'Completed' &&
            state.filter?.filterStatus == FilterStatus.BY_STATUS &&
            state.filter?.status == TaskStatus.COMPLETE &&
            state.screen == SCREEN.HOME),
      ],
    );
  });
}
