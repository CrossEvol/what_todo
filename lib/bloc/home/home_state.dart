part of 'home_bloc.dart';

class HomeState extends Equatable {
  final String title;
  final Filter? filter;
  final SCREEN screen;
  final int todayCount;
  final double? scrollPosition;

  const HomeState({
    this.title = '',
    this.filter,
    this.screen = SCREEN.HOME,
    this.todayCount = 0,
    this.scrollPosition,
  });

  HomeState copyWith({
    String? title,
    Filter? filter,
    SCREEN? screen,
    int? todayCount,
    double? scrollPosition,
  }) {
    return HomeState(
      title: title ?? this.title,
      filter: filter ?? this.filter,
      screen: screen ?? this.screen,
      todayCount: todayCount ?? this.todayCount,
      scrollPosition: scrollPosition ?? this.scrollPosition,
    );
  }

  @override
  List<Object?> get props => [
        title,
        filter,
        screen,
        todayCount,
        scrollPosition,
      ];
}

class HomeInitial extends HomeState {}
