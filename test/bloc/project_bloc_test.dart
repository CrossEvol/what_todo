import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/fake-database.mocks.dart';

void main() {
  late final testProject;
  late final inboxProject;
  late MockProjectDB mockProjectDB;
  late ProjectBloc projectBloc;

  setUp(() {
    mockProjectDB = MockProjectDB();
    projectBloc = ProjectBloc(mockProjectDB);
  });

  tearDown(() {
    projectBloc.close();
  });

  group('ProjectBloc', () {
    testProject = Project(
      id: 2,
      name: 'Test Project',
      colorValue: Colors.blue.value,
      colorName: 'Blue',
    );

    inboxProject = Project.inbox();

    List<Project> testProjects = [
      testProject,
      Project(
        id: 3,
        name: 'Test Project 2',
        colorValue: Colors.red.value,
        colorName: 'Red',
      ),
    ];

    test('initial state is ProjectInitial', () {
      expect(projectBloc.state, isA<ProjectInitialState>());
    });

    blocTest<ProjectBloc, ProjectState>(
      'emits [ProjectLoading, ProjectsLoaded] when LoadProjectsEvent is added',
      build: () {
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => testProjects);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const LoadProjectsEvent()),
      expect: () => [
        isA<ProjectLoadingState>(),
        isA<ProjectsLoadedState>().having(
          (state) => state.projects,
          'projects',
          equals(testProjects),
        ),
      ],
      verify: (_) {
        verify(mockProjectDB.getProjects(isInboxVisible: false)).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'emits [ProjectLoading, ProjectError] when LoadProjectsEvent fails',
      build: () {
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenThrow(Exception('Database error'));
        return projectBloc;
      },
      act: (bloc) => bloc.add(const LoadProjectsEvent()),
      expect: () => [
        isA<ProjectLoadingState>(),
        isA<ProjectError>().having(
          (state) => state.message,
          'error message',
          equals('Failed to load projects'),
        ),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'emits ColorSelectionUpdated when UpdateColorSelectionEvent is added',
      build: () => projectBloc,
      act: (bloc) => bloc.add(
        UpdateColorSelectionEvent(
          ColorPalette('Blue', Colors.blue.value),
        ),
      ),
      expect: () => [
        isA<ColorSelectionUpdated>().having(
          (state) => state.colorPalette.colorName,
          'colorName',
          equals('Blue'),
        ),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'creates project and refreshes list when CreateProjectEvent is added',
      build: () {
        when(mockProjectDB.isProjectExists(testProject))
            .thenAnswer((_) async => Future.value(false));
        when(mockProjectDB.insertProject(testProject))
            .thenAnswer((_) async => Future.value());
        return projectBloc;
      },
      act: (bloc) => bloc.add(CreateProjectEvent(testProject)),
      expect: () => [
        isA<ProjectCreateSuccess>(),
      ],
      verify: (_) {
        verify(mockProjectDB.isProjectExists(testProject)).called(1);
        verify(mockProjectDB.insertProject(testProject)).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'emits ProjectError when CreateProjectEvent fails',
      build: () {
        when(mockProjectDB.insertProject(testProject))
            .thenThrow(Exception('Database error'));
        return projectBloc;
      },
      act: (bloc) => bloc.add(CreateProjectEvent(testProject)),
      expect: () => [
        isA<ProjectError>().having(
          (state) => state.message,
          'error message',
          equals('Failed to create project'),
        ),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'emits [ProjectExistenceChecked] when CreateProjectEvent is added',
      build: () {
        when(mockProjectDB.isProjectExists(testProject))
            .thenAnswer((_) async => true);
        return projectBloc;
      },
      act: (bloc) => bloc.add(
        CreateProjectEvent(testProject),
      ),
      expect: () => [
        isA<ProjectExistenceChecked>().having(
          (state) => state.exists,
          'exists',
          equals(true),
        ),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'refreshes project list when RefreshProjectsEvent is added',
      build: () {
        when(mockProjectDB.getProjects(isInboxVisible: true))
            .thenAnswer((_) async => testProjects);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => testProjects);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const RefreshProjectsEvent()),
      expect: () => [
        isA<ProjectLoadingState>(),
        isA<ProjectsLoadedState>().having(
          (state) => state.projects,
          'projects',
          equals(testProjects),
        ),
      ],
    );

    blocTest<ProjectBloc, ProjectState>(
      'removes project and refreshes list when ProjectRemoveEvent is added',
      build: () {
        when(mockProjectDB.moveTasksToInbox(any)).thenAnswer((_) async => true);
        when(mockProjectDB.deleteProject(any)).thenAnswer((_) async => true);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const ProjectRemoveEvent(projectID: 2)),
      expect: () => [
        isA<ProjectLoadingState>(),
        isA<ProjectsLoadedState>(),
      ],
      verify: (_) {
        verify(mockProjectDB.moveTasksToInbox(2)).called(1);
        verify(mockProjectDB.deleteProject(2)).called(1);
        verify(mockProjectDB.getProjects(isInboxVisible: false)).called(1);
        verify(mockProjectDB.getProjectsWithCount()).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'can not remove project when it is inbox with ID:1',
      build: () {
        when(mockProjectDB.moveTasksToInbox(1)).thenAnswer((_) async => true);
        when(mockProjectDB.deleteProject(1)).thenAnswer((_) async => true);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const ProjectRemoveEvent(projectID: 1)),
      expect: () => [],
      verify: (_) {
        verifyNever(mockProjectDB.moveTasksToInbox(1));
        verifyNever(mockProjectDB.deleteProject(1));
        verifyNever(mockProjectDB.getProjects(isInboxVisible: false));
        verifyNever(mockProjectDB.getProjectsWithCount());
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'does not trigger LoadProjectsEvent when ProjectRemoveEvent is added and project is not removed cause of failure of moving tasks to inbox',
      build: () {
        when(mockProjectDB.moveTasksToInbox(any))
            .thenAnswer((_) async => false);
        when(mockProjectDB.deleteProject(any)).thenAnswer((_) async => true);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const ProjectRemoveEvent(projectID: 2)),
      expect: () => [],
      verify: (_) {
        verify(mockProjectDB.moveTasksToInbox(2)).called(1);
        verifyNever(mockProjectDB.deleteProject(2));
        verifyNever(mockProjectDB.getProjects(isInboxVisible: false));
        verifyNever(mockProjectDB.getProjectsWithCount());
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'does not trigger LoadProjectsEvent when ProjectRemoveEvent is added and project is not removed cause of failure of remove project',
      build: () {
        when(mockProjectDB.moveTasksToInbox(any)).thenAnswer((_) async => true);
        when(mockProjectDB.deleteProject(any)).thenAnswer((_) async => false);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(const ProjectRemoveEvent(projectID: 2)),
      expect: () => [],
      verify: (_) {
        verify(mockProjectDB.moveTasksToInbox(2)).called(1);
        verify(mockProjectDB.deleteProject(2)).called(1);
        verifyNever(mockProjectDB.getProjects(isInboxVisible: false));
        verifyNever(mockProjectDB.getProjectsWithCount());
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'updates project and refreshes list when ProjectUpdateEvent is added',
      build: () {
        when(mockProjectDB.upsertProject(testProject))
            .thenAnswer((_) async => true);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(ProjectUpdateEvent(project: testProject)),
      expect: () => [
        isA<ProjectLoadingState>(),
        isA<ProjectsLoadedState>(),
      ],
      verify: (_) {
        verify(mockProjectDB.upsertProject(testProject)).called(1);
        verify(mockProjectDB.getProjects(isInboxVisible: false)).called(1);
        verify(mockProjectDB.getProjectsWithCount()).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'can not update project when it is inbox with ID:1',
      build: () {
        when(mockProjectDB.upsertProject(inboxProject))
            .thenAnswer((_) async => true);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => []);
        when(mockProjectDB.getProjectsWithCount()).thenAnswer((_) async => []);
        return projectBloc;
      },
      act: (bloc) => bloc.add(ProjectUpdateEvent(project: inboxProject)),
      expect: () => [],
      verify: (_) {
        verifyNever(mockProjectDB.upsertProject(inboxProject));
        verifyNever(mockProjectDB.getProjects(isInboxVisible: false));
        verifyNever(mockProjectDB.getProjectsWithCount());
      },
    );
  });
}
