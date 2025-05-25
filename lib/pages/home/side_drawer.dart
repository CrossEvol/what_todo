import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/search/search_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/l10n/app_localizations.dart';
import 'package:flutter_app/pages/home/profile_card.dart';
import 'package:flutter_app/pages/home/today_menu_item.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  void initState() {
    super.initState();
    // Load basic data when the widget is initialized
    context.read<AdminBloc>().add(AdminLoadLabelsEvent());
    context.read<AdminBloc>().add(AdminLoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final environment = context.read<SettingsBloc>().state.environment;
    final homeBloc = context.read<HomeBloc>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          ProfileCard(),
          ListTile(
              leading: Icon(Icons.inbox),
              title: Text(
                AppLocalizations.of(context)!.inbox,
                key: ValueKey(SideDrawerKeys.INBOX),
              ),
              onTap: () {
                var project = Project.inbox();
                homeBloc.add(ApplyFilterEvent(
                    project.name,
                    Filter.byProject(project.id!)
                        .copyWith(status: TaskStatus.PENDING)));
                context.read<TaskBloc>().add(FilterTasksEvent(
                    filter: Filter.byProject(project.id)
                        .copyWith(status: TaskStatus.PENDING)));
                context.safePop();
              }),
          TodayMenuItem(),
          ListTile(
            onTap: () {
              homeBloc.add(ApplyFilterEvent(
                  AppLocalizations.of(context)!.next7Days,
                  Filter.byNextWeek().copyWith(status: TaskStatus.PENDING)));
              context.read<TaskBloc>().add(FilterTasksEvent(
                  filter: Filter.byNextWeek()
                      .copyWith(status: TaskStatus.PENDING)));
              context.safePop();
            },
            leading: Icon(Icons.calendar_view_day_rounded),
            title: Text(
              AppLocalizations.of(context)!.next7Days,
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          ProjectsExpansionTile(),
          LabelsExpansionTile(),
          GridsExpansionTile(),
          ListTile(
            onTap: () {
              context.push('/settings');
            },
            leading: Icon(Icons.settings_sharp),
            title: Text(
              AppLocalizations.of(context)!.settings,
              key: ValueKey(SideDrawerKeys.UNKNOWN),
            ),
          ),
          if (environment == Environment.test)
            ListTile(
              onTap: () {
                context.push('/order');
              },
              leading: Icon(Icons.unarchive_sharp),
              title: Text(
                AppLocalizations.of(context)!.orderTest,
                key: ValueKey(SideDrawerKeys.UNKNOWN),
              ),
            ),
          ListTile(
            onTap: () {
              showSnackbar(
                  context, AppLocalizations.of(context)!.unknownNotImplemented,
                  materialColor: Colors.teal);
            },
            leading: Icon(Icons.unarchive_sharp),
            title: Text(
              AppLocalizations.of(context)!.unknown,
              key: ValueKey(SideDrawerKeys.UNKNOWN),
            ),
          ),
        ],
      ),
    );
  }
}

class GridsExpansionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(SideDrawerKeys.DRAWER_GRIDS),
      leading: Icon(Icons.account_tree),
      title: Text(
        AppLocalizations.of(context)!.controls,
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      children: buildGridItems(context),
    );
  }

  List<Widget> buildGridItems(BuildContext context) {
    List<Widget> gridItems = [];

    // Task Grid
    gridItems.add(
      ListTile(
        onTap: () {
          context.push('/task/grid');
          context.read<SearchBloc>().add(ResetSearchEvent());
        },
        leading: Icon(Icons.task_alt_outlined),
        title: Text(
          AppLocalizations.of(context)!.taskGrid,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          key: ValueKey(SideDrawerKeys.TASK_GRID_TITLE),
        ),
      ),
    );

    // Project Grid
    gridItems.add(
      ListTile(
        onTap: () {
          context.push('/project/grid');
        },
        leading: Icon(Icons.grid_view_outlined),
        title: Text(
          AppLocalizations.of(context)!.projectGrid,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          key: ValueKey(SideDrawerKeys.PROJECT_GRID),
        ),
      ),
    );

    // Label Grid
    gridItems.add(
      ListTile(
        onTap: () {
          context.push('/label/grid');
        },
        leading: Icon(Icons.view_comfortable_outlined),
        title: Text(
          AppLocalizations.of(context)!.labelGrid,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
          key: ValueKey(SideDrawerKeys.LABEL_GRID),
        ),
      ),
    );

    // Divider
    gridItems.add(Divider());

    // Import/Export section (conditional)
    if (context.read<SettingsBloc>().state.enableImportExport) {
      // Export Tasks
      gridItems.add(
        ListTile(
          onTap: () {
            context.push('/export');
            context.safePop();
          },
          leading: Icon(Icons.upload_file),
          title: Text(
            'Export Tasks',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            key: ValueKey(CompletedTaskPageKeys.EXPORT_DATA),
          ),
        ),
      );

      // Import Tasks
      gridItems.add(
        ListTile(
          onTap: () {
            context.push('/import');
            context.safePop();
          },
          leading: Icon(Icons.download_rounded),
          title: Text(
            'Import Tasks',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            key: ValueKey(CompletedTaskPageKeys.IMPORT_DATA),
          ),
        ),
      );
    }

    return gridItems;
  }
}
