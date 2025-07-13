import 'package:flutter_app/models/reminder_type.dart';

class Reminder {
  static final tblReminder = "reminder";
  static final dbId = "id";
  static final dbType = "type";
  static final dbRemindTime = "remindTime";
  static final dbEnable = "enable";
  static final dbTaskId = "taskId";

  int? id;
  late ReminderType type;
  DateTime? remindTime;
  late bool enable;
  int? taskId;

  Reminder.create(this.type, this.remindTime, this.enable, this.taskId);

  Reminder.update({
    required this.id,
    ReminderType? type,
    DateTime? remindTime,
    bool? enable,
    int? taskId,
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
  }

  bool operator ==(o) => o is Reminder && o.id == id;

  Reminder.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbId],
            type: ReminderType.values[map[dbType]], // Assuming type is stored as int index
            remindTime: map[dbRemindTime] != null ? DateTime.fromMillisecondsSinceEpoch(map[dbRemindTime]) : null,
            enable: map[dbEnable] == 1, // Assuming boolean is stored as 0 or 1
            taskId: map[dbTaskId]);

  Map<String, dynamic> toMap() {
    return {
      Reminder.dbId: id,
      Reminder.dbType: type.index, // Storing enum as int index
      Reminder.dbRemindTime: remindTime?.millisecondsSinceEpoch,
      Reminder.dbEnable: enable ? 1 : 0, // Storing boolean as 0 or 1
      Reminder.dbTaskId: taskId,
    };
  }
}
