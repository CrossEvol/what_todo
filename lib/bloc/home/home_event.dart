part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadTodayCountEvent extends HomeEvent {}

class UpdateTitleEvent extends HomeEvent {
  final String title;

  const UpdateTitleEvent(this.title);

  @override
  List<Object> get props => [title];
}

class ApplyFilterEvent extends HomeEvent {
  final String title;
  final Filter filter;

  const ApplyFilterEvent(this.title, this.filter);

  @override
  List<Object> get props => [title, filter];
}

class UpdateScreenEvent extends HomeEvent {
  final SCREEN screen;

  const UpdateScreenEvent(this.screen);

  @override
  List<Object> get props => [screen];
}

class SaveScrollPositionEvent extends HomeEvent {
  final double position;

  const SaveScrollPositionEvent(this.position);

  @override
  List<Object> get props => [position];
}

class ClearScrollPositionEvent extends HomeEvent {}
