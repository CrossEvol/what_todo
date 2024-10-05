import 'dart:async';

import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/constants/color_constant.dart';

@deprecated
class MyProjectBloc implements CustomBlocBase {
  StreamController<List<Project>> _projectsController =
      StreamController<List<Project>>.broadcast();

  Stream<List<Project>> get projects => _projectsController.stream;

  StreamController<ColorPalette> _colorController =
      StreamController<ColorPalette>.broadcast();

  Stream<ColorPalette> get colorSelection => _colorController.stream;

  ProjectDB _projectDB;
  bool isInboxVisible;

  MyProjectBloc(this._projectDB, {this.isInboxVisible = false}) {
    _loadProjects(isInboxVisible);
  }

  @override
  void dispose() {
    _projectsController.close();
    _colorController.close();
  }

  void _loadProjects(bool isInboxVisible) {
    _projectDB.getProjects(isInboxVisible: isInboxVisible).then((projects) {
      if (!_projectsController.isClosed) {
        _projectsController.sink.add(projects);
      }
    });
  }

  void createProject(Project project) {
    _projectDB.insertOrReplace(project).then((value) {
      if (value == null) return;
      _loadProjects(isInboxVisible);
    });
  }

  void updateColorSelection(ColorPalette colorPalette) {
    _colorController.sink.add(colorPalette);
  }

  void refresh() {
    _loadProjects(isInboxVisible);
  }
}
