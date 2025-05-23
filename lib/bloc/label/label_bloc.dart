
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/constants/color_constant.dart';

part 'label_event.dart';

part 'label_state.dart';

class LabelBloc extends Bloc<LabelEvent, LabelState> {
  final LabelDB _labelDB;

  LabelBloc(this._labelDB) : super(LabelInitial(labels: [])) {
    on<LoadLabelsEvent>(_onLoadLabels);
    on<CreateLabelEvent>(_onCreateLabel);
    on<UpdateColorSelectionEvent>(_onUpdateColorSelection);
    on<RefreshLabelsEvent>(_onRefreshLabels);
  }

  Future<void> _onLoadLabels(
      LoadLabelsEvent event, Emitter<LabelState> emit) async {
    emit(LabelLoading(labels: []));
    try {
      final labels = await _labelDB.getLabels();
      emit(LabelsLoaded(labels: labels));
    } catch (e) {
      emit(LabelError(labels: state.labels, message: 'Failed to load labels'));
    }
  }

  Future<void> _onCreateLabel(
      CreateLabelEvent event, Emitter<LabelState> emit) async {
    try {
      final isExist = await _labelDB.isLabelExists(event.label);
      if (!isExist) {
        await _labelDB.insertLabel(event.label);
        emit(LabelCreateSuccess(labels: state.labels));
      } else {
        emit(LabelExistenceChecked(exists: isExist, labels: state.labels));
      }
    } catch (e) {
      emit(LabelError(
          message: 'Failed to check label existence', labels: state.labels));
    }
  }

  void _onUpdateColorSelection(
      UpdateColorSelectionEvent event, Emitter<LabelState> emit) {
    emit(ColorSelectionUpdated(
        colorPalette: event.colorPalette, labels: state.labels));
  }

  Future<void> _onRefreshLabels(
      RefreshLabelsEvent event, Emitter<LabelState> emit) async {
    // await _onLoadLabels(LoadLabelsEvent(), emit);
    add(LoadLabelsEvent());
  }
}
