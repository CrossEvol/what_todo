part of 'reminder_bloc.dart';

abstract class ReminderState extends Equatable {
  final Map<int, List<Reminder>> remindersByTask;

  const ReminderState({this.remindersByTask = const {}});

  @override
  List<Object> get props => [remindersByTask];
}

class ReminderInitial extends ReminderState {
  const ReminderInitial() : super(remindersByTask: const {});
}

class ReminderLoading extends ReminderState {
  const ReminderLoading({required Map<int, List<Reminder>> remindersByTask})
      : super(remindersByTask: remindersByTask);
}

class ReminderLoaded extends ReminderState {
  const ReminderLoaded({required Map<int, List<Reminder>> remindersByTask})
      : super(remindersByTask: remindersByTask);
}

class ReminderError extends ReminderState {
  final String message;

  const ReminderError(this.message,
      {required Map<int, List<Reminder>> remindersByTask})
      : super(remindersByTask: remindersByTask);

  @override
  List<Object> get props => [message, remindersByTask];
}
