import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/projects/project.dart';

part 'admin_event.dart';

part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc()
      : super(AdminInitialState(
          colorPalette: ColorPalette("Grey", Colors.grey.value),
        )) {
    on<AdminUpdateColorSelectionEvent>(_onUpdateColorSelection);
    on<AdminEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  Future<void> _onUpdateColorSelection(
      AdminUpdateColorSelectionEvent event, Emitter<AdminState> emit) async {
    emit(state.copyWith(colorPalette: event.colorPalette));
  }
}
