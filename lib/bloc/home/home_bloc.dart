import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';

import '../../pages/tasks/task_db.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadTodayCountEvent>(_loadTodayCount);
    on<UpdateTitleEvent>(_onUpdateTitle);
    on<ApplyFilterEvent>(_onApplyFilter);
    on<UpdateScreenEvent>(_onUpdateScreen);
  }

  void _onUpdateTitle(UpdateTitleEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(title: event.title));
  }

  void _onApplyFilter(ApplyFilterEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(
      title: event.title,
      filter: event.filter,
      screen: SCREEN.HOME,
    ));
  }

  void _onUpdateScreen(UpdateScreenEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(screen: event.screen));
  }

  FutureOr<void> _loadTodayCount(
      LoadTodayCountEvent event, Emitter<HomeState> emit) async {
    final count = await TaskDB.get().countToday();
    emit(state.copyWith(todayCount: count));
  }
}
