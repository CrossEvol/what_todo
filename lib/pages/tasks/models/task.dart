import 'package:flutter_app/models/priority.dart';

class Task {
  static final tblTask = "Task"; // Changed from "Tasks" to "Task"
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
    return 'Task{title: $title, comment: $comment, projectName: $projectName, id: $id, projectColor: $projectColor, dueDate: $dueDate, projectId: $projectId, priority: $priority, tasksStatus: $tasksStatus, labelList: $labelList}';
  }

  Task.create({
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

  bool operator ==(o) => o is Task && o.id == id;

  Task.update({
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

  Task.fromMap(Map<String, dynamic> map)
      : this.update(
          id: map[dbId],
          title: map[dbTitle],
          projectId: map[dbProjectID],
          comment: map[dbComment],
          dueDate: map[dbDueDate],
          priority: PriorityStatus.values[map[dbPriority]],
          tasksStatus: TaskStatus.values[map[dbStatus]],
        );

  Task.fromImport(Map<String, dynamic> map)
      : this(
          title: map[dbTitle],
          projectId: 1,
          comment: map[dbComment],
          dueDate:
              DateTime.parse(map[dbDueDate] as String).millisecondsSinceEpoch,
          priority: PriorityStatus.values[map[dbPriority]],
          tasksStatus: TaskStatus.values[map[dbStatus]],
        );

  Map<String, dynamic> toMap() {
    return {
      Task.dbId: id,
      Task.dbTitle: title,
      Task.dbComment: comment,
      Task.dbDueDate: dueDate,
      Task.dbPriority: priority.index,
      // convert enum to value index
      Task.dbStatus: tasksStatus?.index,
      // convert enum to value index (nullable)
      Task.dbProjectID: projectId,
    };
  }

  Task({
    required this.title,
    required this.comment,
    this.id,
    required this.dueDate,
    required this.projectId,
    required this.priority,
    this.tasksStatus,
  });
}

enum TaskStatus {
  PENDING,
  COMPLETE,
}

class ExportTask {
  final int id;
  final String title;
  final String comment;
  final DateTime dueDate;
  final int priority;
  final int status;
  final String projectName;

  const ExportTask({
    required this.id,
    required this.title,
    required this.comment,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.projectName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'comment': this.comment,
      'dueDate': this.dueDate.toIso8601String(),
      'priority': this.priority,
      'status': this.status,
      'projectName': this.projectName,
    };
  }

  factory ExportTask.fromMap(Map<String, dynamic> map) {
    return ExportTask(
      id: map['id'] as int,
      title: map['title'] as String,
      comment: map['comment'] as String,
      dueDate: map['dueDate'] as DateTime,
      priority: map['priority'] as int,
      status: map['status'] as int,
      projectName: map['projectName'] as String,
    );
  }
}
