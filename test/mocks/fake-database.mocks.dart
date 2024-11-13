// Mocks generated by Mockito 5.4.4 from annotations
// in flutter_app/test/mocks/fake-database.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter_app/pages/labels/label.dart' as _i5;
import 'package:flutter_app/pages/labels/label_db.dart' as _i3;
import 'package:flutter_app/pages/profile/profile.dart' as _i8;
import 'package:flutter_app/pages/profile/profile_db.dart' as _i7;
import 'package:flutter_app/pages/projects/project.dart' as _i2;
import 'package:flutter_app/pages/projects/project_db.dart' as _i6;
import 'package:flutter_app/pages/settings/setting.dart' as _i10;
import 'package:flutter_app/pages/settings/settings_db.dart' as _i9;
import 'package:flutter_app/pages/tasks/models/task.dart' as _i12;
import 'package:flutter_app/pages/tasks/task_db.dart' as _i11;
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

class _FakeProject_0 extends _i1.SmartFake implements _i2.Project {
  _FakeProject_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [LabelDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockLabelDB extends _i1.Mock implements _i3.LabelDB {
  @override
  _i4.Future<bool> isLabelExits(_i5.Label? label) => (super.noSuchMethod(
        Invocation.method(
          #isLabelExits,
          [label],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<dynamic> upsertLabel(_i5.Label? label) => (super.noSuchMethod(
        Invocation.method(
          #upsertLabel,
          [label],
        ),
        returnValue: _i4.Future<dynamic>.value(),
        returnValueForMissingStub: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<List<_i5.Label>> getLabels() => (super.noSuchMethod(
        Invocation.method(
          #getLabels,
          [],
        ),
        returnValue: _i4.Future<List<_i5.Label>>.value(<_i5.Label>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i5.Label>>.value(<_i5.Label>[]),
      ) as _i4.Future<List<_i5.Label>>);

  @override
  _i4.Future<List<_i5.LabelWithCount>> getLabelsWithCount() =>
      (super.noSuchMethod(
        Invocation.method(
          #getLabelsWithCount,
          [],
        ),
        returnValue:
            _i4.Future<List<_i5.LabelWithCount>>.value(<_i5.LabelWithCount>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i5.LabelWithCount>>.value(<_i5.LabelWithCount>[]),
      ) as _i4.Future<List<_i5.LabelWithCount>>);

  @override
  _i4.Future<List<_i5.Label>> getLabelsByNames(List<String>? labelNames) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLabelsByNames,
          [labelNames],
        ),
        returnValue: _i4.Future<List<_i5.Label>>.value(<_i5.Label>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i5.Label>>.value(<_i5.Label>[]),
      ) as _i4.Future<List<_i5.Label>>);

  @override
  _i4.Future<bool> deleteLabel(int? labelId) => (super.noSuchMethod(
        Invocation.method(
          #deleteLabel,
          [labelId],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}

/// A class which mocks [ProjectDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockProjectDB extends _i1.Mock implements _i6.ProjectDB {
  @override
  _i4.Future<_i2.Project> getProject({
    required int? id,
    bool? isInboxVisible = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getProject,
          [],
          {
            #id: id,
            #isInboxVisible: isInboxVisible,
          },
        ),
        returnValue: _i4.Future<_i2.Project>.value(_FakeProject_0(
          this,
          Invocation.method(
            #getProject,
            [],
            {
              #id: id,
              #isInboxVisible: isInboxVisible,
            },
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.Project>.value(_FakeProject_0(
          this,
          Invocation.method(
            #getProject,
            [],
            {
              #id: id,
              #isInboxVisible: isInboxVisible,
            },
          ),
        )),
      ) as _i4.Future<_i2.Project>);

  @override
  _i4.Future<List<_i2.Project>> getProjects({bool? isInboxVisible = true}) =>
      (super.noSuchMethod(
        Invocation.method(
          #getProjects,
          [],
          {#isInboxVisible: isInboxVisible},
        ),
        returnValue: _i4.Future<List<_i2.Project>>.value(<_i2.Project>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i2.Project>>.value(<_i2.Project>[]),
      ) as _i4.Future<List<_i2.Project>>);

  @override
  _i4.Future<List<_i2.ProjectWithCount>> getProjectsWithCount() =>
      (super.noSuchMethod(
        Invocation.method(
          #getProjectsWithCount,
          [],
        ),
        returnValue: _i4.Future<List<_i2.ProjectWithCount>>.value(
            <_i2.ProjectWithCount>[]),
        returnValueForMissingStub: _i4.Future<List<_i2.ProjectWithCount>>.value(
            <_i2.ProjectWithCount>[]),
      ) as _i4.Future<List<_i2.ProjectWithCount>>);

  @override
  _i4.Future<dynamic> upsertProject(_i2.Project? project) =>
      (super.noSuchMethod(
        Invocation.method(
          #upsertProject,
          [project],
        ),
        returnValue: _i4.Future<dynamic>.value(),
        returnValueForMissingStub: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<bool> moveTasksToInbox(int? projectID) => (super.noSuchMethod(
        Invocation.method(
          #moveTasksToInbox,
          [projectID],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> deleteProject(int? projectID) => (super.noSuchMethod(
        Invocation.method(
          #deleteProject,
          [projectID],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<void> importProjects(Set<String>? projectNames) =>
      (super.noSuchMethod(
        Invocation.method(
          #importProjects,
          [projectNames],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}

/// A class which mocks [ProfileDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockProfileDB extends _i1.Mock implements _i7.ProfileDB {
  @override
  _i4.Future<_i8.UserProfile?> findByID(int? profileId) => (super.noSuchMethod(
        Invocation.method(
          #findByID,
          [profileId],
        ),
        returnValue: _i4.Future<_i8.UserProfile?>.value(),
        returnValueForMissingStub: _i4.Future<_i8.UserProfile?>.value(),
      ) as _i4.Future<_i8.UserProfile?>);

  @override
  _i4.Future<bool> updateOne(_i8.UserProfile? profile) => (super.noSuchMethod(
        Invocation.method(
          #updateOne,
          [profile],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}

/// A class which mocks [SettingsDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockSettingsDB extends _i1.Mock implements _i9.SettingsDB {
  @override
  _i4.Future<_i10.Setting?> findByName(String? settingKey) =>
      (super.noSuchMethod(
        Invocation.method(
          #findByName,
          [settingKey],
        ),
        returnValue: _i4.Future<_i10.Setting?>.value(),
        returnValueForMissingStub: _i4.Future<_i10.Setting?>.value(),
      ) as _i4.Future<_i10.Setting?>);

  @override
  _i4.Future<bool> updateSetting(_i10.Setting? setting) => (super.noSuchMethod(
        Invocation.method(
          #updateSetting,
          [setting],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> createSetting(_i10.Setting? setting) => (super.noSuchMethod(
        Invocation.method(
          #createSetting,
          [setting],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}

/// A class which mocks [TaskDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockTaskDB extends _i1.Mock implements _i11.TaskDB {
  @override
  _i4.Future<int> countToday() => (super.noSuchMethod(
        Invocation.method(
          #countToday,
          [],
        ),
        returnValue: _i4.Future<int>.value(0),
        returnValueForMissingStub: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);

  @override
  _i4.Future<List<_i12.ExportTask>> getExports() => (super.noSuchMethod(
        Invocation.method(
          #getExports,
          [],
        ),
        returnValue:
            _i4.Future<List<_i12.ExportTask>>.value(<_i12.ExportTask>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i12.ExportTask>>.value(<_i12.ExportTask>[]),
      ) as _i4.Future<List<_i12.ExportTask>>);

  @override
  _i4.Future<List<_i12.Task>> getTasks({
    int? startDate = 0,
    int? endDate = 0,
    _i12.TaskStatus? taskStatus,
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
        returnValue: _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
      ) as _i4.Future<List<_i12.Task>>);

  @override
  _i4.Future<List<_i12.Task>> getTasksByProject(
    int? projectId, {
    _i12.TaskStatus? status,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTasksByProject,
          [projectId],
          {#status: status},
        ),
        returnValue: _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
      ) as _i4.Future<List<_i12.Task>>);

  @override
  _i4.Future<List<_i12.Task>> getTasksByLabel(
    String? labelName, {
    _i12.TaskStatus? status,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getTasksByLabel,
          [labelName],
          {#status: status},
        ),
        returnValue: _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i12.Task>>.value(<_i12.Task>[]),
      ) as _i4.Future<List<_i12.Task>>);

  @override
  _i4.Future<bool> deleteTask(int? taskID) => (super.noSuchMethod(
        Invocation.method(
          #deleteTask,
          [taskID],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> updateTaskStatus(
    int? taskID,
    _i12.TaskStatus? status,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTaskStatus,
          [
            taskID,
            status,
          ],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> updateOrder({
    required int? taskID,
    required int? order,
    required bool? findPrev,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateOrder,
          [],
          {
            #taskID: taskID,
            #order: order,
            #findPrev: findPrev,
          },
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<int> createTask(
    _i12.Task? task, {
    List<int>? labelIDs,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #createTask,
          [task],
          {#labelIDs: labelIDs},
        ),
        returnValue: _i4.Future<int>.value(0),
        returnValueForMissingStub: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);

  @override
  _i4.Future<bool> updateTask(
    _i12.Task? task, {
    List<int>? labelIDs,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTask,
          [task],
          {#labelIDs: labelIDs},
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> updateExpiredTasks(int? todayStartTime) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateExpiredTasks,
          [todayStartTime],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> updateInboxTasksToToday() => (super.noSuchMethod(
        Invocation.method(
          #updateInboxTasksToToday,
          [],
        ),
        returnValue: _i4.Future<bool>.value(false),
        returnValueForMissingStub: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<void> importTasks(List<Map<String, dynamic>>? taskMaps) =>
      (super.noSuchMethod(
        Invocation.method(
          #importTasks,
          [taskMaps],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
}
