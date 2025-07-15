import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/dao/reminder_db.dart';
import 'package:flutter_app/models/reminder.dart';

part 'reminder_event.dart';

part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  final ReminderDB _reminderDB;

  ReminderBloc({ReminderDB? reminderDB})
      : _reminderDB = reminderDB ?? ReminderDB.get(),
        super(const ReminderInitial()) {
    on<LoadAllReminders>(_onLoadAllReminders);
    on<LoadRemindersForTask>(_onLoadRemindersForTask);
    on<RemindersInitialEvent>(_onInitializeReminders);
    on<AddReminderEvent>(_onAddReminder);
    on<RemoveReminderEvent>(_onRemoveReminder);
    on<UpdateReminderEvent>(_onUpdateReminder);
  }

  void _onLoadRemindersForTask(
      LoadRemindersForTask event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading(remindersByTask: state.remindersByTask));
    try {
      final reminders = await _reminderDB.getRemindersForTask(event.taskId);
      final newRemindersByTask =
          Map<int, List<Reminder>>.from(state.remindersByTask);
      newRemindersByTask[event.taskId] = reminders;
      emit(ReminderLoaded(remindersByTask: newRemindersByTask));
    } catch (e) {
      emit(ReminderError(e.toString(), remindersByTask: state.remindersByTask));
    }
  }

  Future<void> _onLoadAllReminders(
      LoadAllReminders event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading(remindersByTask: state.remindersByTask));
    try {
      final allReminders = await _reminderDB.getAllReminders();
      final newRemindersByTask =
          Map<int, List<Reminder>>.from(state.remindersByTask);

      // Group reminders by taskId
      for (var reminder in allReminders) {
        if (reminder.taskId != null) {
          if (!newRemindersByTask.containsKey(reminder.taskId)) {
            newRemindersByTask[reminder.taskId!] = [];
          }
          // Avoid duplicates
          if (!newRemindersByTask[reminder.taskId!]!
              .any((r) => r.id == reminder.id)) {
            newRemindersByTask[reminder.taskId!]!.add(reminder);
          }
        }
      }
      emit(ReminderLoaded(remindersByTask: newRemindersByTask));
    } catch (e) {
      emit(ReminderError(e.toString(), remindersByTask: state.remindersByTask));
    }
  }

  FutureOr<void> _onInitializeReminders(
      RemindersInitialEvent event, Emitter<ReminderState> emit) async {
    emit(const ReminderInitial());
  }

  Future<void> _onAddReminder(
      AddReminderEvent event, Emitter<ReminderState> emit) async {
    try {
      final newId = await _reminderDB.insertReminder(event.reminder);
      final newReminder = Reminder.update(
        id: newId,
        type: event.reminder.type,
        remindTime: event.reminder.remindTime,
        enable: event.reminder.enable,
        taskId: event.reminder.taskId,
      );

      final newRemindersByTask =
          Map<int, List<Reminder>>.from(state.remindersByTask);
      final taskReminders =
          List<Reminder>.from(newRemindersByTask[event.reminder.taskId] ?? []);
      taskReminders.add(newReminder);
      newRemindersByTask[event.reminder.taskId!] = taskReminders;
      emit(ReminderLoaded(remindersByTask: newRemindersByTask));
    } catch (e) {
      emit(ReminderError(e.toString(), remindersByTask: state.remindersByTask));
    }
  }

  Future<void> _onRemoveReminder(
      RemoveReminderEvent event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading(remindersByTask: state.remindersByTask));
    try {
      await _reminderDB.deleteReminder(event.reminderId);

      final newRemindersByTask =
          Map<int, List<Reminder>>.from(state.remindersByTask);
      // Find the task ID for the reminder to be removed
      int? taskIdToRemoveFrom;
      newRemindersByTask.forEach((taskId, reminders) {
        if (reminders.any((r) => r.id == event.reminderId)) {
          taskIdToRemoveFrom = taskId;
          return; // Found it, stop iterating
        }
      });

      if (taskIdToRemoveFrom != null) {
        final taskReminders =
            List<Reminder>.from(newRemindersByTask[taskIdToRemoveFrom!] ?? []);
        taskReminders.removeWhere((r) => r.id == event.reminderId);
        newRemindersByTask[taskIdToRemoveFrom!] = taskReminders;
      }

      emit(ReminderLoaded(remindersByTask: newRemindersByTask));
    } catch (e) {
      emit(ReminderError(e.toString(), remindersByTask: state.remindersByTask));
    }
  }

  Future<void> _onUpdateReminder(
      UpdateReminderEvent event, Emitter<ReminderState> emit) async {
    emit(ReminderLoading(remindersByTask: state.remindersByTask));
    try {
      await _reminderDB.updateReminder(event.updatedReminder);

      final newRemindersByTask =
          Map<int, List<Reminder>>.from(state.remindersByTask);
      final taskId = event.updatedReminder.taskId!; // TaskId should not be null for an existing reminder
      final taskReminders =
          List<Reminder>.from(newRemindersByTask[taskId] ?? []);

      // Find the index of the reminder to update
      final indexToUpdate =
          taskReminders.indexWhere((r) => r.id == event.updatedReminder.id);

      if (indexToUpdate != -1) {
        // Replace the old reminder with the updated one
        taskReminders[indexToUpdate] = event.updatedReminder;
        newRemindersByTask[taskId] = taskReminders;
      } else {
        // This case might happen if the state is not fully synced,
        // but for robustness, we could potentially add it if not found.
        // For now, we assume it exists.
      }

      emit(ReminderLoaded(remindersByTask: newRemindersByTask));
    } catch (e) {
      emit(ReminderError(e.toString(), remindersByTask: state.remindersByTask));
    }
  }
}
