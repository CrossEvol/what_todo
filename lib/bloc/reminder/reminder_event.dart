part of 'reminder_bloc.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class RemindersInitialEvent extends ReminderEvent {
  const RemindersInitialEvent();

  @override
  List<Object?> get props => [];
}

class LoadRemindersForTask extends ReminderEvent {
  final int taskId;

  const LoadRemindersForTask(this.taskId);

  @override
  List<Object?> get props => [taskId];
}
