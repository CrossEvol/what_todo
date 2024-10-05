import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/constants/color_constant.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectDB _projectDB;

  ProjectBloc(this._projectDB) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<CreateProject>(_onCreateProject);
    on<UpdateColorSelection>(_onUpdateColorSelection);
    on<RefreshProjects>(_onRefreshProjects);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final projects = await _projectDB.getProjects(isInboxVisible: event.isInboxVisible);
      emit(ProjectsLoaded(projects));
    } catch (e) {
      emit(ProjectError('Failed to load projects'));
    }
  }

  Future<void> _onCreateProject(CreateProject event, Emitter<ProjectState> emit) async {
    try {
      await _projectDB.insertOrReplace(event.project);
      add(RefreshProjects(isInboxVisible: event.isInboxVisible));
    } catch (e) {
      emit(ProjectError('Failed to create project'));
    }
  }

  void _onUpdateColorSelection(UpdateColorSelection event, Emitter<ProjectState> emit) {
    emit(ColorSelectionUpdated(event.colorPalette));
  }

  Future<void> _onRefreshProjects(RefreshProjects event, Emitter<ProjectState> emit) async {
    add(LoadProjects(isInboxVisible: event.isInboxVisible));
  }
}
