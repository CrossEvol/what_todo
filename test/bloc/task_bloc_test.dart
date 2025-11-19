import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/fake-database.mocks.dart';

void main() {
  late MockTaskDB mockTaskDB;
  late MockResourceDB mockResourceDB;
  late TaskBloc taskBloc;

  setUp(() {
    mockTaskDB = MockTaskDB();
    mockResourceDB = MockResourceDB();
    taskBloc = TaskBloc(mockTaskDB, mockResourceDB);
  });

  tearDown(() {
    taskBloc.close();
  });

  group('TaskBloc', () {
    final testTask = Task.create(
      title: 'Test Task',
      projectId: 1,
      dueDate: DateTime.now().millisecondsSinceEpoch,
    ).copyWith(tasksStatus: TaskStatus.PENDING);

    final List<Task> testTasks = [testTask];

    test('initial state is TaskInitial', () {
      expect(taskBloc.state, isA<TaskInitial>());
    });

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when LoadTasksEvent is added',
      build: () {
        when(mockTaskDB.getTasks()).thenAnswer((_) async => testTasks);
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksEvent()),
      expect: () => [
        TaskLoading(),
        TaskLoaded(testTasks),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when LoadTasksByLabelEvent is added',
      build: () {
        when(mockTaskDB.getTasksByLabel('test', status: TaskStatus.COMPLETE))
            .thenAnswer((_) async => testTasks);
        return taskBloc;
      },
      act: (bloc) => bloc.add(LoadTasksByLabelEvent(
        labelName: 'test',
        status: TaskStatus.COMPLETE,
      )),
      expect: () => [
        TaskLoading(),
        TaskLoaded(testTasks),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when PostponeTasksEvent is added',
      build: () {
        when(mockTaskDB.updateExpiredTasks(any)).thenAnswer((_) async => true);
        when(mockTaskDB.getTasks(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          taskStatus: anyNamed("taskStatus"),
        )).thenAnswer((_) async => testTasks);
        return taskBloc;
      },
      act: (bloc) => bloc.add(PostponeTasksEvent()),
      expect: () => [
        TaskLoading(),
        TaskLoaded(testTasks),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoading, TaskLoaded] when PushAllToTodayEvent is added',
      build: () {
        when(mockTaskDB.updateInboxTasksToToday())
            .thenAnswer((_) async => true);
        when(mockTaskDB.getTasks(
          startDate: anyNamed('startDate'),
          endDate: anyNamed('endDate'),
          taskStatus: anyNamed("taskStatus"),
        )).thenAnswer((_) async => testTasks);
        return taskBloc;
      },
      act: (bloc) => bloc.add(PushAllToTodayEvent()),
      expect: () => [
        TaskLoading(),
        TaskLoaded(testTasks),
      ],
    );

    group('FilterTasksEvent', () {
      blocTest<TaskBloc, TaskState>(
        'emits correct states for BY_TODAY filter',
        build: () {
          when(mockTaskDB.getTasks(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
            taskStatus: anyNamed("taskStatus"),
          )).thenAnswer((_) async => testTasks);
          return taskBloc;
        },
        act: (bloc) => bloc.add(FilterTasksEvent(filter: Filter.byToday())),
        expect: () => [
          TaskLoading(),
          TaskLoaded(testTasks),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits correct states for BY_WEEK filter',
        build: () {
          when(mockTaskDB.getTasks(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
            taskStatus: TaskStatus.PENDING,
          )).thenAnswer((_) async => testTasks);
          return taskBloc;
        },
        act: (bloc) => bloc.add(FilterTasksEvent(filter: Filter.byNextWeek())),
        expect: () => [
          TaskLoading(),
          TaskLoaded(testTasks),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'emits correct states for BY_PROJECT filter',
        build: () {
          when(mockTaskDB.getTasksByProject(1, status: TaskStatus.PENDING))
              .thenAnswer((_) async => testTasks);
          return taskBloc;
        },
        act: (bloc) => bloc.add(FilterTasksEvent(filter: Filter.byProject(1))),
        expect: () => [
          TaskLoading(),
          TaskLoaded(testTasks),
        ],
      );
    });

    blocTest<TaskBloc, TaskState>(
      'emits correct states when AddTaskEvent is added',
      build: () {
        when(mockTaskDB.createTask(testTask, labelIDs: [1]))
            .thenAnswer((_) async => 1);
        return taskBloc;
      },
      seed: () => TaskLoaded(testTasks),
      act: (bloc) => bloc.add(AddTaskEvent(task: testTask, labelIds: [1])),
      expect: () => [], // No state change if successful
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskError] when AddTaskEvent fails',
      build: () {
        when(mockTaskDB.createTask(testTask, labelIDs: [1]))
            .thenThrow(Exception('Failed to create task'));
        return taskBloc;
      },
      seed: () => TaskLoaded(testTasks),
      act: (bloc) => bloc.add(AddTaskEvent(task: testTask, labelIds: [1])),
      expect: () => [
        TaskError('Exception: Failed to create task'),
      ],
    );

    blocTest<TaskBloc, TaskState>(
      'emits correct states when ReOrderTasksEvent is added',
      build: () {
        when(mockTaskDB.updateOrder(
          taskID: anyNamed('taskID'),
          order: anyNamed('order'),
          findPrev: anyNamed('findPrev'),
        )).thenAnswer((_) async => true);
        return taskBloc;
      },
      seed: () => TaskLoaded(testTasks),
      act: (bloc) => bloc.add(ReOrderTasksEvent(
        oldTask: testTask
          ..order = 1
          ..id = 1,
        newTask: testTask
          ..order = 2
          ..id = 1,
      )),
      expect: () => [TaskReOrdered()],
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskError] when ReOrderTasksEvent fails',
      build: () {
        when(mockTaskDB.updateOrder(
          taskID: anyNamed('taskID'),
          order: anyNamed('order'),
          findPrev: anyNamed('findPrev'),
        )).thenThrow(Exception('Failed to reorder'));
        return taskBloc;
      },
      seed: () => TaskLoaded(testTasks),
      act: (bloc) => bloc.add(ReOrderTasksEvent(
        oldTask: testTask
          ..order = 1
          ..id = 1,
        newTask: testTask
          ..order = 2
          ..id = 1,
      )),
      expect: () => [TaskError('Exception: Failed to reorder')],
    );
  });
}
