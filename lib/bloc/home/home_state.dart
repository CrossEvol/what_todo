part of 'home_bloc.dart';

class HomeState extends Equatable {
  final String title;
  final Filter? filter;
  final SCREEN screen;

  const HomeState({
    this.title = '',
    this.filter,
    this.screen = SCREEN.HOME,
  });

  HomeState copyWith({
    String? title,
    Filter? filter,
    SCREEN? screen,
  }) {
    return HomeState(
      title: title ?? this.title,
      filter: filter ?? this.filter,
      screen: screen ?? this.screen,
    );
  }

  @override
  List<Object?> get props => [title, filter, screen];
}

class HomeInitial extends HomeState {}
