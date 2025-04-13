// Mocks generated by Mockito 5.4.4 from annotations
// in flutter_app/test/task/add_task_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:flutter_app/pages/labels/label.dart' as _i6;
import 'package:flutter_app/pages/labels/label_db.dart' as _i5;
import 'package:flutter_app/pages/projects/project.dart' as _i2;
import 'package:flutter_app/pages/projects/project_db.dart' as _i3;
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

/// A class which mocks [ProjectDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockProjectDB extends _i1.Mock implements _i3.ProjectDB {
  MockProjectDB() {
    _i1.throwOnMissingStub(this);
  }

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
      ) as _i4.Future<List<_i2.ProjectWithCount>>);

  @override
  _i4.Future<dynamic> upsertProject(_i2.Project? project) =>
      (super.noSuchMethod(
        Invocation.method(
          #upsertProject,
          [project],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<bool> moveTasksToInbox(int? projectID) => (super.noSuchMethod(
        Invocation.method(
          #moveTasksToInbox,
          [projectID],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<bool> deleteProject(int? projectID) => (super.noSuchMethod(
        Invocation.method(
          #deleteProject,
          [projectID],
        ),
        returnValue: _i4.Future<bool>.value(false),
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

/// A class which mocks [LabelDB].
///
/// See the documentation for Mockito's code generation for more information.
class MockLabelDB extends _i1.Mock implements _i5.LabelDB {
  MockLabelDB() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<bool> isLabelExists(_i6.Label? label) => (super.noSuchMethod(
        Invocation.method(
          #isLabelExits,
          [label],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);

  @override
  _i4.Future<dynamic> insertLabel(_i6.Label? label) => (super.noSuchMethod(
        Invocation.method(
          #upsertLabel,
          [label],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<List<_i6.Label>> getLabels() => (super.noSuchMethod(
        Invocation.method(
          #getLabels,
          [],
        ),
        returnValue: _i4.Future<List<_i6.Label>>.value(<_i6.Label>[]),
      ) as _i4.Future<List<_i6.Label>>);

  @override
  _i4.Future<List<_i6.LabelWithCount>> getLabelsWithCount() =>
      (super.noSuchMethod(
        Invocation.method(
          #getLabelsWithCount,
          [],
        ),
        returnValue:
            _i4.Future<List<_i6.LabelWithCount>>.value(<_i6.LabelWithCount>[]),
      ) as _i4.Future<List<_i6.LabelWithCount>>);

  @override
  _i4.Future<List<_i6.Label>> getLabelsByNames(List<String>? labelNames) =>
      (super.noSuchMethod(
        Invocation.method(
          #getLabelsByNames,
          [labelNames],
        ),
        returnValue: _i4.Future<List<_i6.Label>>.value(<_i6.Label>[]),
      ) as _i4.Future<List<_i6.Label>>);

  @override
  _i4.Future<bool> deleteLabel(int? labelId) => (super.noSuchMethod(
        Invocation.method(
          #deleteLabel,
          [labelId],
        ),
        returnValue: _i4.Future<bool>.value(false),
      ) as _i4.Future<bool>);
}
