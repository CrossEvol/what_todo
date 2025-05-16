part of 'label_bloc.dart';

abstract class LabelState extends Equatable {
  final List<Label> labels;

  @override
  List<Object> get props => [labels];

  const LabelState({
    required this.labels,
  });

}

class LabelInitial extends LabelState {
  LabelInitial({required super.labels});

}

class LabelLoading extends LabelState {
  LabelLoading({required super.labels});
}

class LabelsLoaded extends LabelState {
  LabelsLoaded({required super.labels});
}

class LabelExistenceChecked extends LabelState {
  final bool exists;

  const LabelExistenceChecked({
    required super.labels,
    required this.exists,
  });

  @override
  List<Object> get props => [exists];
}

class ColorSelectionUpdated extends LabelState {
  final ColorPalette colorPalette;

  const ColorSelectionUpdated({
    required super.labels,
    required this.colorPalette,
  });

  @override
  List<Object> get props => [colorPalette];
}

class LabelCreateSuccess extends LabelState {
  const LabelCreateSuccess({required super.labels});

  @override
  List<Object> get props => [];
}

class LabelError extends LabelState {
  final String message;

  const LabelError({
    required super.labels,
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
