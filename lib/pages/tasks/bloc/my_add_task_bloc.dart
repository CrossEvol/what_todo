import 'dart:async';

import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/pages/tasks/task_db.dart';
import 'package:rxdart/rxdart.dart';

@deprecated
class MyAddTaskBloc implements CustomBlocBase {
  final TaskDB _taskDB;
  final ProjectDB _projectDB;
  final LabelDB _labelDB;
  PriorityStatus lastPrioritySelection = PriorityStatus.PRIORITY_4;

  MyAddTaskBloc(this._taskDB, this._projectDB, this._labelDB) {
    _loadProjects();
    _loadLabels();
    updateDueDate(DateTime.now().millisecondsSinceEpoch);
    _projectSelected.add(Project.inbox());
    _prioritySelected.add(lastPrioritySelection);
  }

  BehaviorSubject<List<Project>> _projectsController =
      BehaviorSubject<List<Project>>();

  Stream<List<Project>> get projects => _projectsController.stream;

  BehaviorSubject<List<Label>> _labelsController =
      BehaviorSubject<List<Label>>();

  Stream<List<Label>> get labels => _labelsController.stream;

  BehaviorSubject<Project> _projectSelected = BehaviorSubject<Project>();

  Stream<Project> get selectedProject => _projectSelected.stream;

  BehaviorSubject<String> _labelSelected = BehaviorSubject<String>();

  Stream<String> get labelSelection => _labelSelected.stream;

  List<Label> _selectedLabelList = [];

  List<Label> get selectedLabels => _selectedLabelList;

  BehaviorSubject<PriorityStatus> _prioritySelected =
      BehaviorSubject<PriorityStatus>();

  Stream<PriorityStatus> get prioritySelection => _prioritySelected.stream;

  BehaviorSubject<int> _dueDateSelected = BehaviorSubject<int>();

  Stream<int> get dueDateSelected => _dueDateSelected.stream;

  String updateTitle = "";

  @override
  void dispose() {
    _projectsController.close();
    _labelsController.close();
    _projectSelected.close();
    _labelSelected.close();
    _prioritySelected.close();
    _dueDateSelected.close();
  }

  void _loadProjects() {
    _projectDB.getProjects(isInboxVisible: true).then((projects) {
      _projectsController.add(List.unmodifiable(projects));
    });
  }

  void _loadLabels() {
    _labelDB.getLabels().then((labels) {
      _labelsController.add(List.unmodifiable(labels));
    });
  }

  void projectSelected(Project project) {
    _projectSelected.add(project);
  }

  void labelAddOrRemove(Label label) {
    if (_selectedLabelList.contains(label)) {
      _selectedLabelList.remove(label);
    } else {
      _selectedLabelList.add(label);
    }
    _buildLabelsString();
  }

  void _buildLabelsString() {
    String labelJoinString =
        _selectedLabelList.map((label) => "@${label.name}").toList().join("  ");
    String displayLabels =
        labelJoinString.length == 0 ? "No Labels" : labelJoinString;
    _labelSelected.add(displayLabels);
  }

  void updatePriority(PriorityStatus priority) {
    _prioritySelected.add(priority);
    lastPrioritySelection = priority;
  }

  Stream createTask() {
    return ZipStream.zip3(selectedProject, dueDateSelected, prioritySelection,
        (Project project, int dueDateSelected, PriorityStatus status) {
      List<int> labelIds =
          _selectedLabelList.map((label) => label.id!).toList();

      var task = Task.create(
        title: updateTitle,
        dueDate: dueDateSelected,
        priority: status,
        projectId: project.id!,
      );

      _taskDB.updateTask(task, labelIDs: labelIds).then((task) {
        Notification.onDone();
      });
    });
  }

  void updateDueDate(int millisecondsSinceEpoch) {
    _dueDateSelected.add(millisecondsSinceEpoch);
  }
}
