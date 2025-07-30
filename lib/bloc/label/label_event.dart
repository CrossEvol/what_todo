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

class LabelUpdateEvent extends LabelEvent {
  final Label label;

  @override
  List<Object> get props => [label];

  const LabelUpdateEvent({
    required this.label,
  });
}

class LabelRemoveEvent extends LabelEvent {
  final int labelID;

  @override
  List<Object> get props => [labelID];

  const LabelRemoveEvent({
    required this.labelID,
  });
}

class UpdateColorSelectionEvent extends LabelEvent {
  final ColorPalette colorPalette;

  const UpdateColorSelectionEvent(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class RefreshLabelsEvent extends LabelEvent {}
