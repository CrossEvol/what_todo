import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/constants/color_constant.dart';

part 'label_event.dart';

part 'label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  final LabelDB _labelDB;

  LabelBloc(this._labelDB)
      : super(LabelInitial(labels: [], labelsWithCount: [])) {
    on<LoadLabelsEvent>(_onLoadLabels);
    on<CreateLabelEvent>(_onCreateLabel);
    on<LabelRemoveEvent>(_onRemoveLabel);
    on<LabelUpdateEvent>(_onUpdateLabel);
    on<UpdateColorSelectionEvent>(_onUpdateColorSelection);
    on<RefreshLabelsEvent>(_onRefreshLabels);
  }

  Future<void> _onLoadLabels(
      LoadLabelsEvent event, Emitter<LabelState> emit) async {
    emit(LabelLoading(labels: [], labelsWithCount: []));
    try {
      final labels = await _labelDB.getLabels();
      final labelsWithCount = await _labelDB.getLabelsWithCount();
      emit(LabelsLoaded(labels: labels, labelsWithCount: labelsWithCount));
    } catch (e) {
      emit(LabelError(
          labels: state.labels,
          labelsWithCount: [],
          message: 'Failed to load labels'));
    }
  }

  Future<void> _onCreateLabel(
      CreateLabelEvent event, Emitter<LabelState> emit) async {
    try {
      final isExist = await _labelDB.isLabelExists(event.label);
      if (!isExist) {
        await _labelDB.insertLabel(event.label);
        emit(LabelCreateSuccess(
            labels: state.labels, labelsWithCount: state.labelsWithCount));
      } else {
        emit(LabelExistenceChecked(
            exists: isExist,
            labels: state.labels,
            labelsWithCount: state.labelsWithCount));
      }
    } catch (e) {
      emit(LabelError(
        message: 'Failed to check label existence',
        labels: state.labels,
        labelsWithCount: state.labelsWithCount,
      ));
    }
  }

  Future<void> _onUpdateLabel(
      LabelUpdateEvent event, Emitter<LabelState> emit) async {
    try {
      await _labelDB.updateLabel(event.label);
      add(LoadLabelsEvent());
    } catch (e) {
      emit(state);
    }
  }

  Future<void> _onRemoveLabel(
      LabelRemoveEvent event, Emitter<LabelState> emit) async {
    final hasRemoved = await _labelDB.deleteLabel(event.labelID);
    if (hasRemoved) {
      add(LoadLabelsEvent());
    }
  }

  void _onUpdateColorSelection(
      UpdateColorSelectionEvent event, Emitter<LabelState> emit) {
    emit(ColorSelectionUpdated(
      colorPalette: event.colorPalette,
      labels: state.labels,
      labelsWithCount: state.labelsWithCount,
    ));
  }

  Future<void> _onRefreshLabels(
      RefreshLabelsEvent event, Emitter<LabelState> emit) async {
    add(LoadLabelsEvent());
  }
}
