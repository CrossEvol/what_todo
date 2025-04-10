import 'package:flutter_app/models/priority.dart';
import 'package:flutter_app/pages/labels/label.dart';

class Task {
  static final tblTask = "Task"; // Changed from "Tasks" to "Task"
  static final dbId = "id";
  static final dbTitle = "title";
  static final dbComment = "comment";
  static final dbDueDate = "dueDate";
  static final dbPriority = "priority";
  static final dbStatus = "status";
  static final dbProjectID = "projectId";
  static final dbOrder = "order";

  String title;
  String comment;
  String? projectName;
  int? id;
  int? projectColor;
  int dueDate;
  int projectId;
  int order = 0;
  PriorityStatus priority;
  TaskStatus? tasksStatus;
  List<Label> labelList = [];

  @override
  String toString() {
    // Note: Adjusted toString to handle List<Label> appropriately if needed,
    // for now just showing label names might be sufficient or adjust as required.
    var labelNames = labelList.map((l) => l.name).join(', ');
    return 'Task{title: $title, comment: $comment, projectName: $projectName, id: $id, projectColor: $projectColor, dueDate: $dueDate, projectId: $projectId, priority: $priority, tasksStatus: $tasksStatus, labelList: [$labelNames]}';
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
    this.order = 0,
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
          order: map[dbOrder],
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
          order: map[dbOrder],
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
      Task.dbOrder: order,
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
    required this.order,
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
  final int order;

  const ExportTask({
    required this.id,
    required this.title,
    required this.comment,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.projectName,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'comment': this.comment,
      'dueDate': this.dueDate.toLocal().toString(),
      'priority': this.priority,
      'status': this.status,
      'projectName': this.projectName,
      'order': this.order,
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
      order: map['order'] as int,
    );
  }
}
