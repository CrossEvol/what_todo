import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // load some basic data
    context.read<AdminBloc>().add(AdminLoadLabelsEvent());
    context.read<AdminBloc>().add(AdminLoadProjectsEvent());

    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Agnimon Frontier"),
            accountEmail: Text("AgnimonFrontier@gmail.com"),
            otherAccountsPictures: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.info,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: () async {
                    context.go('/about');
                  })
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: AssetImage("assets/Agnimon.jpg"),
            ),
          ),
          ListTile(
              leading: Icon(Icons.inbox),
              title: Text(
                "Inbox",
                key: ValueKey(SideDrawerKeys.INBOX),
              ),
              onTap: () {
                var project = Project.getInbox();
                context.read<HomeBloc>().add(ApplyFilterEvent(
                    project.name, Filter.byProject(project.id!)));
                context.read<TaskBloc>().add(
                    FilterTasksEvent(filter: Filter.byProject(project.id)));
                context.safePop();
              }),
          ListTile(
              onTap: () {
                context
                    .read<HomeBloc>()
                    .add(ApplyFilterEvent("Today", Filter.byToday()));
                context
                    .read<TaskBloc>()
                    .add(FilterTasksEvent(filter: Filter.byToday()));
                context.safePop();
              },
              leading: Icon(Icons.calendar_today),
              title: Text(
                "Today",
                key: ValueKey(SideDrawerKeys.TODAY),
              )),
          ListTile(
            onTap: () {
              context
                  .read<HomeBloc>()
                  .add(ApplyFilterEvent("Next 7 Days", Filter.byNextWeek()));
              context
                  .read<TaskBloc>()
                  .add(FilterTasksEvent(filter: Filter.byNextWeek()));
              context.safePop();
            },
            leading: Icon(Icons.calendar_view_day_rounded),
            title: Text(
              "Next 7 Days",
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          ProjectPage(),
          LabelPage(),
          ListTile(
            onTap: () {
              context.go('/project/grid');
            },
            leading: Icon(Icons.grid_view_outlined),
            title: Text(
              'Project Grid',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              key: ValueKey(SideDrawerKeys.PROJECT_GRID),
            ),
          ),
          ListTile(
            onTap: () {
              context.go('/label/grid');
            },
            leading: Icon(Icons.view_comfortable_outlined),
            title: Text(
              'Label Grid',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              key: ValueKey(SideDrawerKeys.LABEL_GRID),
            ),
          ),
          ListTile(
            onTap: () {
              showSnackbar(context, 'Unknown has not implemented.',
                  materialColor: Colors.teal);
            },
            leading: Icon(Icons.unarchive_sharp),
            title: Text(
              'UNKNOWN',
              key: ValueKey(SideDrawerKeys.UNKNOWN),
            ),
          ),
        ],
      ),
    );
  }
}
