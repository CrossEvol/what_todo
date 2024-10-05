import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/projects/project_db.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/pages/about/about_us.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/labels/my_label_bloc.dart';
import 'package:flutter_app/pages/labels/label_widget.dart';
import 'package:flutter_app/pages/projects/my_project_bloc.dart';
import 'package:flutter_app/pages/projects/project_widget.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/extension.dart';

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyHomeBloc homeBloc = CustomBlocProvider.of(context);
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
                    await context.adaptiveNavigate(
                        SCREEN.ABOUT, AboutUsScreen());
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
                homeBloc.applyFilter(
                    project.name, Filter.byProject(project.id!));
                context.safePop();
              }),
          ListTile(
              onTap: () {
                homeBloc.applyFilter("Today", Filter.byToday());
                context.safePop();
              },
              leading: Icon(Icons.calendar_today),
              title: Text(
                "Today",
                key: ValueKey(SideDrawerKeys.TODAY),
              )),
          ListTile(
            onTap: () {
              homeBloc.applyFilter("Next 7 Days", Filter.byNextWeek());
              context.safePop();
            },
            leading: Icon(Icons.calendar_today),
            title: Text(
              "Next 7 Days",
              key: ValueKey(SideDrawerKeys.NEXT_7_DAYS),
            ),
          ),
          CustomBlocProvider(
            bloc: MyProjectBloc(ProjectDB.get()),
            child: ProjectPage(),
          ),
          CustomBlocProvider(
            bloc: MyLabelBloc(LabelDB.get()),
            child: LabelPage(),
          ),
          ListTile(
            onTap: () {
              showSnackbar(context, 'Unknown has not implemented.',materialColor: Colors.teal);
            },
            leading: Icon(Icons.unarchive_sharp),
            title: Text(
              'UNKNOWN',
              key: ValueKey(SideDrawerKeys.UNKNOWN),
            ),
          )
        ],
      ),
    );
  }
}
