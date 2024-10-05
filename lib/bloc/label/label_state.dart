part of 'label_bloc.dart';

sealed class LabelState extends Equatable {
  const LabelState();
}

final class LabelInitial extends LabelState {
  @override
  List<Object> get props => [];
}
