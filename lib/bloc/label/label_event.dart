part of 'label_bloc.dart';

abstract class LabelEvent extends Equatable {
  const LabelEvent();

  @override
  List<Object> get props => [];
}

class LoadLabels extends LabelEvent {}

class CheckLabelExist extends LabelEvent {
  final Label label;

  const CheckLabelExist(this.label);

  @override
  List<Object> get props => [label];
}

class UpdateColorSelection extends LabelEvent {
  final ColorPalette colorPalette;

  const UpdateColorSelection(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class RefreshLabels extends LabelEvent {}
