import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/projects/my_project_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/pages/home/home.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/projects/add_project.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:go_router/go_router.dart';

class ProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectBloc, ProjectState>(
      builder: (context, state) {
        if (state is ProjectsLoaded) {
          return ProjectExpansionTileWidget(state.projects);
        } else if (state is ProjectLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Center(
            child: Text('Failed to load projects'),
          );
        }
      },
    );
  }
}

class ProjectExpansionTileWidget extends StatelessWidget {
  final List<Project> _projects;

  ProjectExpansionTileWidget(this._projects);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(SideDrawerKeys.DRAWER_PROJECTS),
      leading: Icon(Icons.book),
      title: Text("Projects",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildProjects(context),
    );
  }

  List<Widget> buildProjects(BuildContext context) {
    List<Widget> projectWidgetList = [];
    _projects.forEach((project) => projectWidgetList.add(ProjectRow(project)));
    projectWidgetList.add(ListTile(
      key: ValueKey(SideDrawerKeys.ADD_PROJECT),
      leading: Icon(Icons.add),
      title: Text("Add Project"),
      onTap: () async {
        context.go('/project/add');
        context.read<ProjectBloc>().add(RefreshProjects());
      },
    ));
    return projectWidgetList;
  }
}

class ProjectRow extends StatelessWidget {
  final Project project;

  ProjectRow(this.project);

  @override
  Widget build(BuildContext context) {
    MyHomeBloc homeBloc = CustomBlocProvider.of(context);
    return ListTile(
      key: ValueKey("tile_${project.name}_${project.id}"),
      onTap: () {
        homeBloc.applyFilter(project.name, Filter.byProject(project.id!));
        context.safePop();
      },
      leading: Container(
        key: ValueKey("space_${project.name}_${project.id}"),
        width: 24.0,
        height: 24.0,
      ),
      title: Text(
        project.name,
        key: ValueKey("${project.name}_${project.id}"),
      ),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: CircleAvatar(
          key: ValueKey("dot_${project.name}_${project.id}"),
          backgroundColor: Color(project.colorValue),
        ),
      ),
    );
  }
}

class AddProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomBlocProvider(
      bloc: MyProjectBloc(ProjectDB.get()),
      child: AddProject(),
    );
  }
}
