import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'label_event.dart';
part 'label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  LabelBloc() : super(LabelInitial()) {
    on<LabelEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
