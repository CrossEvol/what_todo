import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/fake-database.mocks.dart';

void main() {
  late MockLabelDB labelDB;
  late MockProjectDB projectDB;
  late AdminBloc adminBloc;

  setUp(() {
    labelDB = MockLabelDB();
    projectDB = MockProjectDB();
    adminBloc = AdminBloc(labelDB, projectDB);
  });

  tearDown(() {
    adminBloc.close();
  });

  group('AdminBloc', () {
    final testLabel = Label.create("Test Label", Colors.blue.value, "Blue");
    final testLabelWithCount = LabelWithCount(
      id: 1,
      name: "Test Label",
      colorCode: Colors.blue.value,
      colorName: "Blue",
      count: 5,
    );

    final testProject = Project.create("Test Project", Colors.red.value, "Red");
    final testProjectWithCount = ProjectWithCount(
      id: 1,
      name: "Test Project",
      colorCode: Colors.red.value,
      colorName: "Red",
      count: 3,
    );

    test('initial state is AdminInitialState', () {
      expect(adminBloc.state, isA<AdminInitialState>());
      expect(adminBloc.state.labels, isEmpty);
      expect(adminBloc.state.projects, isEmpty);
    });

    blocTest<AdminBloc, AdminState>(
      'emits updated labels when AdminLoadLabelsEvent is added',
      build: () {
        when(labelDB.getLabelsWithCount())
            .thenAnswer((_) async => [testLabelWithCount]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(AdminLoadLabelsEvent()),
      expect: () => [
        isA<AdminState>().having(
            (state) => state.labels, 'labels', [testLabelWithCount]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'emits updated projects when AdminLoadProjectsEvent is added',
      build: () {
        when(projectDB.getProjectsWithCount())
            .thenAnswer((_) async => [testProjectWithCount]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(AdminLoadProjectsEvent()),
      expect: () => [
        isA<AdminState>().having(
            (state) => state.projects, 'projects', [testProjectWithCount]),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'updates color selection when AdminUpdateColorSelectionEvent is added',
      build: () => adminBloc,
      act: (bloc) => bloc.add(AdminUpdateColorSelectionEvent(
          colorPalette: ColorPalette("Red", Colors.red.value))),
      expect: () => [
        isA<AdminState>().having((state) => state.colorPalette.colorName,
            'colorPalette name', "Red"),
      ],
    );

    blocTest<AdminBloc, AdminState>(
      'updates label when AdminUpdateLabelEvent is added',
      build: () {
        when(labelDB.updateLabel(testLabel)).thenAnswer((_) async => null);
        when(labelDB.getLabelsWithCount())
            .thenAnswer((_) async => [testLabelWithCount]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(AdminUpdateLabelEvent(label: testLabel)),
      expect: () => [
        isA<AdminState>().having(
            (state) => state.labels, 'labels', [testLabelWithCount]),
      ],
      verify: (_) {
        verify(labelDB.updateLabel(testLabel)).called(1);
        verify(labelDB.getLabelsWithCount()).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'removes label when AdminRemoveLabelEvent is added',
      build: () {
        when(labelDB.deleteLabel(1)).thenAnswer((_) async => true);
        when(labelDB.getLabelsWithCount())
            .thenAnswer((_) async => []);
        return adminBloc;
      },
      act: (bloc) => bloc.add(const AdminRemoveLabelEvent(labelID: 1)),
      expect: () => [
        isA<AdminState>().having((state) => state.labels, 'labels', isEmpty),
      ],
      verify: (_) {
        verify(labelDB.deleteLabel(1)).called(1);
        verify(labelDB.getLabelsWithCount()).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'updates project when AdminUpdateProjectEvent is added',
      build: () {
        when(projectDB.upsertProject(testProject))
            .thenAnswer((_) async => null);
        when(projectDB.getProjectsWithCount())
            .thenAnswer((_) async => [testProjectWithCount]);
        return adminBloc;
      },
      act: (bloc) => bloc.add(AdminUpdateProjectEvent(project: testProject)),
      expect: () => [
        isA<AdminState>().having(
            (state) => state.projects, 'projects', [testProjectWithCount]),
      ],
      verify: (_) {
        verify(projectDB.upsertProject(testProject)).called(1);
        verify(projectDB.getProjectsWithCount()).called(1);
      },
    );

    blocTest<AdminBloc, AdminState>(
      'removes project when AdminRemoveProjectEvent is added',
      build: () {
        when(projectDB.moveTasksToInbox(2))
            .thenAnswer((_) async => true);
        when(projectDB.deleteProject(2))
            .thenAnswer((_) async => true);
        when(projectDB.getProjectsWithCount())
            .thenAnswer((_) async => []);
        return adminBloc;
      },
      act: (bloc) => bloc.add(const AdminRemoveProjectEvent(projectID: 2)),
      expect: () => [
        isA<AdminState>().having(
          (state) => state.projects,
          'projects',
          [],
        ),
      ],
      verify: (_) {
        verify(projectDB.moveTasksToInbox(2)).called(1);
        verify(projectDB.deleteProject(2)).called(1);
        verify(projectDB.getProjectsWithCount()).called(1);
      },
    );
  });
}
