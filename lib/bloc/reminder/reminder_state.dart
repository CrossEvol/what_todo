part of 'reminder_bloc.dart';

sealed class ReminderState extends Equatable {
  const ReminderState();
}

final class ReminderInitial extends ReminderState {
  @override
  List<Object> get props => [];
}
