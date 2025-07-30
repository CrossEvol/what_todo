part of 'label_bloc.dart';

abstract class LabelState extends Equatable {
  final List<Label> labels;
  final List<LabelWithCount> labelsWithCount;

  @override
  List<Object> get props => [labels, labelsWithCount];

  const LabelState({
    required this.labels,
    required this.labelsWithCount,
  });
}

class LabelInitial extends LabelState {
  LabelInitial({required super.labels, required super.labelsWithCount});
}

class LabelLoading extends LabelState {
  LabelLoading({required super.labels, required super.labelsWithCount});
}

class LabelsLoaded extends LabelState {
  LabelsLoaded({required super.labels, required super.labelsWithCount});
}

class LabelExistenceChecked extends LabelState {
  final bool exists;

  const LabelExistenceChecked({
    required super.labels,
    required this.exists,
    required super.labelsWithCount,
  });

  @override
  List<Object> get props => [exists];
}

class ColorSelectionUpdated extends LabelState {
  final ColorPalette colorPalette;

  const ColorSelectionUpdated({
    required super.labels,
    required this.colorPalette,
    required super.labelsWithCount,
  });

  @override
  List<Object> get props => [colorPalette];
}

class LabelCreateSuccess extends LabelState {
  const LabelCreateSuccess(
      {required super.labels, required super.labelsWithCount});

  @override
  List<Object> get props => [];
}

class LabelError extends LabelState {
  final String message;

  const LabelError({
    required super.labels,
    required this.message,
    required super.labelsWithCount,
  });

  @override
  List<Object> get props => [message];
}
