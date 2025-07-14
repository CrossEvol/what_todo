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
    on<LoadRemindersForTask>(_onLoadRemindersForTask);
    on<RemindersInitialEvent>(_onInitializeReminders);
    on<AddReminderEvent>(_onAddReminder);
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
}
