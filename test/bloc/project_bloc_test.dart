import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mocks/fake-database.mocks.dart';

void main() {
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
    final testProject = Project(
      id: 1,
      name: 'Test Project',
      colorValue: Colors.blue.value,
      colorName: 'Blue',
    );

    final List<Project> testProjects = [
      testProject,
      Project(
        id: 2,
        name: 'Test Project 2',
        colorValue: Colors.red.value,
        colorName: 'Red',
      ),
    ];

    test('initial state is ProjectInitial', () {
      expect(projectBloc.state, isA<ProjectInitial>());
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
        isA<ProjectLoading>(),
        isA<ProjectsLoaded>().having(
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
        isA<ProjectLoading>(),
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
        when(mockProjectDB.upsertProject(testProject))
            .thenAnswer((_) async => null);
        when(mockProjectDB.getProjects(isInboxVisible: false))
            .thenAnswer((_) async => testProjects);
        return projectBloc;
      },
      act: (bloc) => bloc.add(CreateProjectEvent(testProject)),
      expect: () => [
        isA<ProjectLoading>(),
        isA<ProjectsLoaded>().having(
          (state) => state.projects,
          'projects',
          equals(testProjects),
        ),
      ],
      verify: (_) {
        verify(mockProjectDB.upsertProject(testProject)).called(1);
        verify(mockProjectDB.getProjects(isInboxVisible: false)).called(1);
      },
    );

    blocTest<ProjectBloc, ProjectState>(
      'emits ProjectError when CreateProjectEvent fails',
      build: () {
        when(mockProjectDB.upsertProject(testProject))
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
        isA<ProjectLoading>(),
        isA<ProjectsLoaded>().having(
          (state) => state.projects,
          'projects',
          equals(testProjects),
        ),
      ],
    );
  });
}
