import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';

part 'admin_event.dart';

part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final LabelDB _labelDB;

  AdminBloc(this._labelDB)
      : super(AdminInitialState(
            labels: [],
            colorPalette: ColorPalette("Grey", Colors.grey.value))) {
    on<AdminRemoveLabelEvent>(_removeLabel);
    on<AdminUpdateLabelEvent>(_updateLabel);
    on<AdminLoadLabelsEvent>(_loadLabels);
    on<AdminUpdateColorSelectionEvent>(_onUpdateColorSelection);
    on<AdminEvent>((event, emit) {
      // TODO: implement event handler
    });
  }

  Future<void> _loadLabels(
      AdminLoadLabelsEvent event, Emitter<AdminState> emit) async {
    final labels = await _labelDB.getLabelsWithCount();
    emit(AdminLabelsLoadedState(
        labels: labels, colorPalette: state.colorPalette));
  }

  Future<void> _onUpdateColorSelection(
      AdminUpdateColorSelectionEvent event, Emitter<AdminState> emit) async {
    emit(AdminLabelsLoadedState(
        labels: state.labels, colorPalette: event.colorPalette));
  }

  FutureOr<void> _updateLabel(
      AdminUpdateLabelEvent event, Emitter<AdminState> emit) async {
    try {
      await _labelDB.updateLabels(event.label);
      final labels = await _labelDB.getLabelsWithCount();
      emit(AdminLabelsLoadedState(
          labels: labels, colorPalette: ColorPalette.none()));
    } catch (e) {
      emit(state);
    }
  }

  FutureOr<void> _removeLabel(
      AdminRemoveLabelEvent event, Emitter<AdminState> emit) async {
    final hasRemoved = await _labelDB.deleteLabel(event.labelID);
    if (hasRemoved) {
      final labels = await _labelDB.getLabelsWithCount();
      emit(AdminLabelsLoadedState(
          labels: labels, colorPalette: ColorPalette.none()));
    }
  }
}
