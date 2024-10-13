part of 'home_bloc.dart';

class HomeState extends Equatable {
  final String title;
  final Filter? filter;
  final SCREEN screen;
  final int todayCount;

  const HomeState({
    this.title = '',
    this.filter,
    this.screen = SCREEN.HOME,
    this.todayCount = 0,
  });

  HomeState copyWith({
    String? title,
    Filter? filter,
    SCREEN? screen,
    int? todayCount,
  }) {
    return HomeState(
      title: title ?? this.title,
      filter: filter ?? this.filter,
      screen: screen ?? this.screen,
      todayCount: todayCount ?? this.todayCount,
    );
  }

  @override
  List<Object?> get props => [
        title,
        filter,
        screen,
        todayCount,
      ];
}

class HomeInitial extends HomeState {}
