class TaskLabel {
  static final tblTaskLabel = "taskLabel";
  static final dbId = "id";
  static final dbTaskId = "taskId";
  static final dbLabelId = "labelId";

  int? id;
  int? taskId;
  int? labelId;

  TaskLabel.create(this.taskId, this.labelId);

  TaskLabel.update({this.id, this.taskId, this.labelId});

  TaskLabel.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId], taskId: map[dbTaskId], labelId: map[dbLabelId]);

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // Add non-null values.
    if (id != null) map[TaskLabel.dbId] = id;
    if (taskId != null) map[TaskLabel.dbTaskId] = taskId;
    if (labelId != null) map[TaskLabel.dbLabelId] = labelId;

    return map;
  }
}
