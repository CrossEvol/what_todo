class TaskLabels {
  static final tblTaskLabel = "taskLabel";
  static final dbId = "id";
  static final dbTaskId = "taskId";
  static final dbLabelId = "labelId";

  int? id;
  int? taskId;
  int? labelId;

  TaskLabels.create(this.taskId, this.labelId);

  TaskLabels.update({this.id, this.taskId, this.labelId});

  TaskLabels.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId], taskId: map[dbTaskId], labelId: map[dbLabelId]);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // Add non-null values.
    if (id != null) map[TaskLabels.dbId] = id;
    if (taskId != null) map[TaskLabels.dbTaskId] = taskId;
    if (labelId != null) map[TaskLabels.dbLabelId] = labelId;

    return map;
  }
}
