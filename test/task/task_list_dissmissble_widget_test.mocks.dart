// Mocks generated by Mockito 5.4.4 from annotations
// in flutter_app/test/task/task_list_dissmissble_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:flutter_app/pages/tasks/models/task.dart' as _i4;
import 'package:flutter_app/pages/tasks/task_db.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [TaskDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskDB extends _i1.Mock implements _i2.TaskDB {
  MockTaskDB() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.Task>> getTasks({
    int? startDate = 0,
    int? endDate = 0,
    _i4.TaskStatus? taskStatus,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTasks,
          [],
          {
            #startDate: startDate,
            #endDate: endDate,
            #taskStatus: taskStatus,
          },
        ),
        returnValue: _i3.Future<List<_i4.Task>>.value(<_i4.Task>[]),
      ) as _i3.Future<List<_i4.Task>>);

  @override
  _i3.Future<List<_i4.Task>> getTasksByProject(
    int? projectId, {
    _i4.TaskStatus? status,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTasksByProject,
          [projectId],
          {#status: status},
        ),
        returnValue: _i3.Future<List<_i4.Task>>.value(<_i4.Task>[]),
      ) as _i3.Future<List<_i4.Task>>);

  @override
  _i3.Future<List<_i4.Task>> getTasksByLabel(
    String? labelName, {
    _i4.TaskStatus? status,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTasksByLabel,
          [labelName],
          {#status: status},
        ),
        returnValue: _i3.Future<List<_i4.Task>>.value(<_i4.Task>[]),
      ) as _i3.Future<List<_i4.Task>>);

  @override
  _i3.Future<dynamic> deleteTask(int? taskID) => (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [taskID],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);

  @override
  _i3.Future<dynamic> updateTaskStatus(
    int? taskID,
    _i4.TaskStatus? status,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTaskStatus,
          [
            taskID,
            status,
          ],
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);

  @override
  _i3.Future<dynamic> updateTask(
    _i4.Task? task, {
    List<int>? labelIDs,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [task],
          {#labelIDs: labelIDs},
        ),
        returnValue: _i3.Future<dynamic>.value(),
      ) as _i3.Future<dynamic>);
}
