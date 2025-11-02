part of 'resource_bloc.dart';

sealed class ResourceEvent extends Equatable {
  const ResourceEvent();

  @override
  List<Object> get props => [];
}

class LoadResourcesEvent extends ResourceEvent {
  final int taskId;

  const LoadResourcesEvent(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class AddResourceEvent extends ResourceEvent {
  final int taskId;
  final String imagePath;

  const AddResourceEvent(this.taskId, this.imagePath);

  @override
  List<Object> get props => [taskId, imagePath];
}

class RemoveResourceEvent extends ResourceEvent {
  final int resourceId;
  final String filePath;

  const RemoveResourceEvent(this.resourceId, this.filePath);

  @override
  List<Object> get props => [resourceId, filePath];
}

class ClearResourcesEvent extends ResourceEvent {
  const ClearResourcesEvent();

  @override
  List<Object> get props => [];
}
