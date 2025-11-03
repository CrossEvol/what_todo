/// Data model for task-label relationships used in batch operations
class TaskLabelRelation {
  final int taskId;
  final int labelId;
  
  TaskLabelRelation({
    required this.taskId,
    required this.labelId,
  });

  @override
  String toString() {
    return 'TaskLabelRelation{taskId: $taskId, labelId: $labelId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskLabelRelation &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          labelId == other.labelId;

  @override
  int get hashCode => taskId.hashCode ^ labelId.hashCode;
}