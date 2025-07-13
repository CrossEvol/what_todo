import 'package:drift/drift.dart';
import 'package:flutter_app/db/app_db.dart';
import 'package:flutter_app/models/reminder.dart';

class ReminderDB {
  static final ReminderDB _reminderDb = ReminderDB._internal(AppDatabase());

  AppDatabase _db;

  //private internal constructor to make it singleton
  ReminderDB._internal(this._db);

  static ReminderDB get() {
    return _reminderDb;
  }

  Future<int> insertReminder(Reminder reminder) async {
    return await _db.into(_db.reminder).insert(ReminderCompanion.insert(
          type: reminder.type,
          remindTime: Value(reminder.remindTime),
          enable: Value(reminder.enable),
          taskId: Value(reminder.taskId),
        ));
  }

  Future<bool> updateReminder(Reminder reminder) async {
    return await _db.update(_db.reminder).replace(ReminderCompanion(
          id: Value(reminder.id!),
          type: Value(reminder.type),
          remindTime: Value(reminder.remindTime),
          enable: Value(reminder.enable),
          taskId: Value(reminder.taskId),
        ));
  }

  Future<List<Reminder>> getReminders() async {
    var result = await _db.select(_db.reminder).get();
    return result.map((item) => Reminder.fromMap(item.toJson())).toList();
  }

  Future<Reminder?> getReminderById(int id) async {
    var result = await (_db.select(_db.reminder)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    return result != null ? Reminder.fromMap(result.toJson()) : null;
  }

  Future<int> deleteReminder(int id) async {
    return await (_db.delete(_db.reminder)..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  Future<List<Reminder>> getRemindersForTask(int taskId) async {
    var result = await (_db.select(_db.reminder)
          ..where((tbl) => tbl.taskId.equals(taskId)))
        .get();
    return result.map((item) => Reminder.fromMap(item.toJson())).toList();
  }
}
