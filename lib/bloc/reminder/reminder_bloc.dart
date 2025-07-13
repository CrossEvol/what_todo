import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc() : super(ReminderInitial()) {
    on<ReminderEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
