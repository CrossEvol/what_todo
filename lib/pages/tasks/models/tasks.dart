import 'package:flutter_app/models/priority.dart';

class Tasks {
  static final tblTask = "Tasks";
  static final dbId = "id";
  static final dbTitle = "title";
  static final dbComment = "comment";
  static final dbDueDate = "dueDate";
  static final dbPriority = "priority";
  static final dbStatus = "status";
  static final dbProjectID = "projectId";

  String title;
  String comment;
  String? projectName;
  int? id;
  int? projectColor;
  int dueDate;
  int projectId;
  PriorityStatus priority;
  TaskStatus? tasksStatus;
  List<String> labelList = [];

  @override
  String toString() {
    return 'Tasks{title: $title, comment: $comment, projectName: $projectName, id: $id, projectColor: $projectColor, dueDate: $dueDate, projectId: $projectId, priority: $priority, tasksStatus: $tasksStatus, labelList: $labelList}';
  }

  Tasks.create({
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.priority = PriorityStatus.PRIORITY_4,
  }) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }
    this.tasksStatus = TaskStatus.PENDING;
  }

  bool operator ==(o) => o is Tasks && o.id == id;

  Tasks.update({
    required this.id,
    required this.title,
    required this.projectId,
    this.comment = "",
    this.dueDate = -1,
    this.priority = PriorityStatus.PRIORITY_4,
    this.tasksStatus = TaskStatus.PENDING,
  }) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Tasks.fromMap(Map<String, dynamic> map)
      : this.update(
          id: map[dbId],
          title: map[dbTitle],
          projectId: map[dbProjectID],
          comment: map[dbComment],
          dueDate: map[dbDueDate],
          priority: PriorityStatus.values[map[dbPriority]],
          tasksStatus: TaskStatus.values[map[dbStatus]],
        );

  Map<String, dynamic> toMap() {
    return {
      Tasks.dbId: id,
      Tasks.dbTitle: title,
      Tasks.dbComment: comment,
      Tasks.dbDueDate: dueDate,
      Tasks.dbPriority: priority.index,
      // convert enum to value index
      Tasks.dbStatus: tasksStatus?.index,
      // convert enum to value index (nullable)
      Tasks.dbProjectID: projectId,
    };
  }
}

enum TaskStatus {
  PENDING,
  COMPLETE,
}
