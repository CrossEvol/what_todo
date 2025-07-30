import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/utils/logger_util.dart';

part 'project_event.dart';

part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectDB _projectDB;

  static int inboxID = 1;

  ProjectBloc(this._projectDB) : super(ProjectInitialState()) {
    on<LoadProjectsEvent>(_onLoadProjects);
    on<CreateProjectEvent>(_onCreateProject);
    on<ProjectRemoveEvent>(_removeProject);
    on<ProjectUpdateEvent>(_updateProject);
    on<UpdateColorSelectionEvent>(_onUpdateColorSelection);
    on<RefreshProjectsEvent>(_onRefreshProjects);
  }

  Future<void> _onLoadProjects(
      LoadProjectsEvent event, Emitter<ProjectState> emit) async {
    emit(ProjectLoadingState());
    try {
      final projects =
          await _projectDB.getProjects(isInboxVisible: event.isInboxVisible);
      final projectsWithCount = await _projectDB.getProjectsWithCount();
      emit(ProjectsLoadedState(projects, projectsWithCount));
    } catch (e) {
      emit(ProjectError('Failed to load projects'));
    }
  }

  Future<void> _onCreateProject(
      CreateProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      final exists = await _projectDB.isProjectExists(event.project);
      if (!exists) {
        await _projectDB.insertProject(event.project);
        emit(ProjectCreateSuccess());
      } else {
        emit(ProjectExistenceChecked(true));
      }
    } catch (e) {
      emit(ProjectError('Failed to create project'));
    }
  }

  Future<void> _removeProject(
      ProjectRemoveEvent event, Emitter<ProjectState> emit) async {
    if (event.projectID == inboxID) return;
    try {
      final hasMoved = await _projectDB.moveTasksToInbox(event.projectID);
      if (!hasMoved) return;
      final hasRemoved = await _projectDB.deleteProject(event.projectID);
      if (!hasRemoved) return;
      add(LoadProjectsEvent());
    } catch (e) {
      logger.error(e);
    }
  }

  Future<void> _updateProject(
      ProjectUpdateEvent event, Emitter<ProjectState> emit) async {
    if (event.project.id == inboxID) return;
    try {
      await _projectDB.upsertProject(event.project);
      add(LoadProjectsEvent());
    } catch (e) {
      logger.error(e);
    }
  }

  void _onUpdateColorSelection(
      UpdateColorSelectionEvent event, Emitter<ProjectState> emit) {
    emit(ColorSelectionUpdated(event.colorPalette));
  }

  Future<void> _onRefreshProjects(
      RefreshProjectsEvent event, Emitter<ProjectState> emit) async {
    add(LoadProjectsEvent(isInboxVisible: event.isInboxVisible));
  }
}
