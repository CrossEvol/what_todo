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
    emit(ReminderInitial());
  }
}
