part of 'label_bloc.dart';

abstract class LabelState extends Equatable {
  final List<Label> labels = const [];

  const LabelState();

  @override
  List<Object> get props => [labels];
}

class LabelInitial extends LabelState {}

class LabelLoading extends LabelState {}

class LabelsLoaded extends LabelState {
  final List<Label> labels;

  const LabelsLoaded(this.labels);

  @override
  List<Object> get props => [labels];
}

class LabelExistenceChecked extends LabelState {
  final bool exists;

  const LabelExistenceChecked(this.exists);

  @override
  List<Object> get props => [exists];
}

class ColorSelectionUpdated extends LabelState {
  final ColorPalette colorPalette;

  const ColorSelectionUpdated(this.colorPalette);

  @override
  List<Object> get props => [colorPalette];
}

class LabelError extends LabelState {
  final String message;

  const LabelError(this.message);

  @override
  List<Object> get props => [message];
}
