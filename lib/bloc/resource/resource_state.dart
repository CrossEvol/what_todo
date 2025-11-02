part of 'resource_bloc.dart';

sealed class ResourceState extends Equatable {
  const ResourceState();

  @override
  List<Object> get props => [];
}

final class ResourceInitial extends ResourceState {}

final class ResourceLoading extends ResourceState {}

final class ResourceLoaded extends ResourceState {
  final List<ResourceModel> resources;

  const ResourceLoaded(this.resources);

  @override
  List<Object> get props => [resources];
}

final class ResourceError extends ResourceState {
  final String message;

  const ResourceError(this.message);

  @override
  List<Object> get props => [message];
}

final class ResourceAddSuccess extends ResourceState {
  final String message;

  const ResourceAddSuccess(this.message);

  @override
  List<Object> get props => [message];
}

final class ResourceRemoveSuccess extends ResourceState {
  final String message;

  const ResourceRemoveSuccess(this.message);

  @override
  List<Object> get props => [message];
}
