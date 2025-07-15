import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_app/models/reminder_type.dart';

class Reminder {
  static final tblReminder = "reminder";
  static final dbId = "id";
  static final dbType = "type";
  static final dbRemindTime = "remindTime";
  static final dbEnable = "enable";
  static final dbTaskId = "taskId";
  static final dbUpdateTime = "updateTime";

  int? id;
  late ReminderType type;
  DateTime? remindTime;
  late bool enable;
  int? taskId;
  DateTime? updateTime = DateTime.now();

  Reminder.create(this.type, this.remindTime, this.enable, this.taskId,
      {this.updateTime});

  Reminder.update({
    required this.id,
    ReminderType? type,
    DateTime? remindTime,
    bool? enable,
    int? taskId,
    DateTime? updateTime,
  }) {
    if (type != null) {
      this.type = type;
    }
    if (remindTime != null) {
      this.remindTime = remindTime;
    }
    if (enable != null) {
      this.enable = enable;
    }
    if (taskId != null) {
      this.taskId = taskId;
    }
    if (updateTime != null) {
      this.updateTime = updateTime;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reminder && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Reminder.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId],
            type: EnumToString.fromString(ReminderType.values, map[dbType]),
            remindTime: map[dbRemindTime] != null
                ? DateTime.parse(map[dbRemindTime])
                : null,
            enable: map[dbEnable],
            taskId: map[dbTaskId],
            updateTime: map[dbUpdateTime] != null
                ? DateTime.parse(map[dbUpdateTime])
                : null);

  Map<String, dynamic> toMap() {
    return {
      Reminder.dbId: id,
      Reminder.dbType: type.index, // Storing enum as int index
      Reminder.dbRemindTime: remindTime?.millisecondsSinceEpoch,
      Reminder.dbEnable: enable ? 1 : 0, // Storing boolean as 0 or 1
      Reminder.dbTaskId: taskId,
      Reminder.dbUpdateTime: updateTime?.millisecondsSinceEpoch,
    };
  }
}
