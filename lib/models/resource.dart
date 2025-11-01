class Resource {
  static final tblResource = "resource";
  static final dbId = "id";
  static final dbPath = "path";
  static final dbTaskId = "taskId";
  static final dbCreateTime = "createTime";

  int? id;
  late String path;
  int? taskId;
  DateTime? createTime;

  Resource.create(this.path, this.taskId, {this.createTime});

  Resource.update({
    required this.id,
    String? path,
    int? taskId,
    DateTime? createTime,
  }) {
    if (path != null) {
      this.path = path;
    }
    if (taskId != null) {
      this.taskId = taskId;
    }
    if (createTime != null) {
      this.createTime = createTime;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Resource && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Resource.fromMap(Map<String, dynamic> map)
      : this.update(
          id: map[dbId],
          path: map[dbPath],
          taskId: map[dbTaskId],
          createTime: map[dbCreateTime] != null
              ? DateTime.parse(map[dbCreateTime])
              : null,
        );

  Map<String, dynamic> toMap() {
    return {
      Resource.dbId: id,
      Resource.dbPath: path,
      Resource.dbTaskId: taskId,
      Resource.dbCreateTime: createTime?.millisecondsSinceEpoch,
    };
  }
}