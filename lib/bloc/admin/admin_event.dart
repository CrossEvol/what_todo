part of 'admin_bloc.dart';

sealed class AdminEvent extends Equatable {
  const AdminEvent();
}

class AdminLoadLabelsEvent extends AdminEvent {
  @override
  List<Object?> get props => [];
}

class AdminLoadProjectsEvent extends AdminEvent {
  @override
  List<Object?> get props => [];
}

class AdminUpdateColorSelectionEvent extends AdminEvent {
  final ColorPalette colorPalette;

  @override
  List<Object> get props => [colorPalette];

  const AdminUpdateColorSelectionEvent({
    required this.colorPalette,
  });
}

class AdminUpdateLabelEvent extends AdminEvent {
  final Label label;

  @override
  List<Object?> get props => [label];

  const AdminUpdateLabelEvent({
    required this.label,
  });
}

class AdminRemoveLabelEvent extends AdminEvent {
  final int labelID;

  @override
  List<Object?> get props => [labelID];

  const AdminRemoveLabelEvent({
    required this.labelID,
  });
}

class AdminUpdateProjectEvent extends AdminEvent {
  final Project project;

  @override
  List<Object?> get props => [project];

  const AdminUpdateProjectEvent({
    required this.project,
  });
}

class AdminRemoveProjectEvent extends AdminEvent {
  final int projectID;

  @override
  List<Object?> get props => [projectID];

  const AdminRemoveProjectEvent({
    required this.projectID,
  });
}
