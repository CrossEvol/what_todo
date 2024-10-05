part of 'label_bloc.dart';

abstract class LabelEvent extends Equatable {
  const LabelEvent();

  @override
  List<Object> get props => [];
}

class LoadLabelsEvent extends LabelEvent {}

class CreateLabelEvent extends LabelEvent {
  final Label label;

  const CreateLabelEvent(this.label);

  @override
  List<Object> get props => [label];
}

class UpdateColorSelectionEvent extends LabelEvent {
  final ColorPalette colorPalette;

  const UpdateColorSelectionEvent(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class RefreshLabelsEvent extends LabelEvent {}
