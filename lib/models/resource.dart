/// ResourceModel represents an image resource attached to a task
/// This model follows the design specification for task resource management
class ResourceModel {
  static final tblResource = "resource";
  static final dbId = "id";
  static final dbPath = "path";
  static final dbTaskId = "taskId";
  static final dbCreateTime = "createTime";

  final int id;
  final String path;
  final int? taskId;
  final DateTime? createTime;
  String? taskTitle; // 用于导入时的临时存储
  String? content; // 用于存储 base64 编码的图片内容

  ResourceModel({
    required this.id,
    required this.path,
    this.taskId,
    this.createTime,
    this.taskTitle,
  });

  /// Create a new ResourceModel from database map
  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'] as int,
      path: map['path'] as String,
      taskId: map['taskId'] as int?,
      createTime: map['createTime'] != null 
          ? DateTime.parse(map['createTime'] as String)
          : null,
    )
      ..content = map['content'] as String?
      ..taskTitle = map['task_title'] as String?;
  }

  /// Convert ResourceModel to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'taskId': taskId,
      'createTime': createTime?.toIso8601String(),
      'content': content,
      'task_title': taskTitle,
    };
  }

  /// Create a copy of this ResourceModel with updated values
  ResourceModel copyWith({
    int? id,
    String? path,
    int? taskId,
    DateTime? createTime,
    String? taskTitle,
    String? content,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      path: path ?? this.path,
      taskId: taskId ?? this.taskId,
      createTime: createTime ?? this.createTime,
      taskTitle: taskTitle ?? this.taskTitle,
    )..content = content ?? this.content;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path &&
          taskId == other.taskId;

  @override
  int get hashCode => Object.hash(id, path, taskId);

  @override
  String toString() {
    return 'ResourceModel(id: $id, path: $path, taskId: $taskId, createTime: $createTime)';
  }
}

