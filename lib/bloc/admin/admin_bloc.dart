import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'admin_event.dart';

part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final LabelDB _labelDB;
  final ProjectDB _projectDB;

  static int inboxID = 1;

  AdminBloc(this._labelDB, this._projectDB)
      : super(AdminInitialState(
          labels: [],
          projects: [],
          colorPalette: ColorPalette("Grey", Colors.grey.value),
        )) {
    on<AdminRemoveProjectEvent>(_removeProject);
    on<AdminUpdateProjectEvent>(_updateProject);
    on<AdminLoadProjectsEvent>(_loadProjects);
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
    emit(state.copyWith(labels: labels));
  }

  Future<void> _onUpdateColorSelection(
      AdminUpdateColorSelectionEvent event, Emitter<AdminState> emit) async {
    emit(state.copyWith(colorPalette: event.colorPalette));
  }

  FutureOr<void> _updateLabel(
      AdminUpdateLabelEvent event, Emitter<AdminState> emit) async {
    try {
      await _labelDB.upsertLabel(event.label);
      final labels = await _labelDB.getLabelsWithCount();
      emit(state.copyWith(labels: labels));
    } catch (e) {
      emit(state);
    }
  }

  FutureOr<void> _removeLabel(
      AdminRemoveLabelEvent event, Emitter<AdminState> emit) async {
    final hasRemoved = await _labelDB.deleteLabel(event.labelID);
    if (hasRemoved) {
      final labels = await _labelDB.getLabelsWithCount();
      emit(state.copyWith(labels: labels));
    }
  }

  FutureOr<void> _updateProject(
      AdminUpdateProjectEvent event, Emitter<AdminState> emit) async {
    if (event.project.id == inboxID) return;
    try {
      await _projectDB.upsertProject(event.project);
      add(AdminLoadProjectsEvent());
    } catch (e) {
      logger.error(e);
    }
  }

  FutureOr<void> _removeProject(
      AdminRemoveProjectEvent event, Emitter<AdminState> emit) async {
    if (event.projectID == inboxID) return;
    try {
      final hasMoved = await _projectDB.moveTasksToInbox(event.projectID);
      if (!hasMoved) return;
      final hasRemoved = await _projectDB.deleteProject(event.projectID);
      if (!hasRemoved) return;
      add(AdminLoadProjectsEvent());
    } catch (e) {
      logger.error(e);
    }
  }

  FutureOr<void> _loadProjects(
      AdminLoadProjectsEvent event, Emitter<AdminState> emit) async {
    final projects = await _projectDB.getProjectsWithCount();
    emit(state.copyWith(projects: projects));
  }
}
