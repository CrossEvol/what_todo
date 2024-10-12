import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/admin/admin_bloc.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/profile/profile_bloc.dart';
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

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  Widget _buildAvatarWidget(String avatarUrl) {
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(avatarUrl),
          ),
        ),
      );
    } else if (avatarUrl.startsWith("assets/")) {
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: AssetImage(avatarUrl),
      );
    } else {
      var file = File(avatarUrl);
      var fileImage = FileImage(file);
      return CircleAvatar(
        radius: 75,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: fileImage,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Load basic data when the widget is initialized
    context.read<AdminBloc>().add(AdminLoadLabelsEvent());
    context.read<AdminBloc>().add(AdminLoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: <Widget>[
          GestureDetector(
            key: ValueKey(SideDrawerKeys.PROFILE),
            onTap: () {
              context.go('/profile');
            },
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoaded) {
                  return UserAccountsDrawerHeader(
                    accountName: Text(state.profile.name),
                    accountEmail: Text(state.profile.email),
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
                    currentAccountPicture: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: _buildAvatarWidget(state.profile.avatarUrl),
                    ),
                  );
                }
                return UserAccountsDrawerHeader(
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
                  currentAccountPicture: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: AssetImage("assets/Agnimon.jpg"),
                    ),
                  ),
                );
              },
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
