import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:badges/badges.dart' as badges;

class TodayMenuItem extends StatefulWidget {
  const TodayMenuItem({super.key});

  @override
  State<TodayMenuItem> createState() => _TodayMenuItemState();
}

class _TodayMenuItemState extends State<TodayMenuItem> {
  final bool _isLooped = true;

  _TodayMenuItemState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        var todayCount = context.read<HomeBloc>().state.todayCount;
        bool useCountBadges = context.read<SettingsBloc>().state.useCountBadges;
        return useCountBadges && todayCount > 0
            ? ListTile(
                onTap: () {
                  context
                      .read<HomeBloc>()
                      .add(ApplyFilterEvent("Today", Filter.byToday()));
                  context
                      .read<TaskBloc>()
                      .add(FilterTasksEvent(filter: Filter.byToday()));
                  context.safePop();
                },
                leading: badges.Badge(
                  position: badges.BadgePosition.topEnd(end: -5, top: -5),
                  badgeStyle: const badges.BadgeStyle(
                    padding: EdgeInsets.all(4),
                  ),
                  badgeAnimation: badges.BadgeAnimation.fade(
                    animationDuration: const Duration(seconds: 1),
                    loopAnimation: _isLooped,
                  ),
                  badgeContent: Container(
                    height: 2,
                    width: 2,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                  ),
                  child: const Icon(Icons.calendar_today),
                ),
                title: badges.Badge(
                  badgeStyle: badges.BadgeStyle(
                    shape: badges.BadgeShape.square,
                    borderRadius: BorderRadius.circular(5),
                    padding: const EdgeInsets.all(2),
                    badgeGradient: const badges.BadgeGradient.linear(
                      colors: [
                        Colors.purple,
                        Colors.blue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  position: badges.BadgePosition.topStart(top: 5, start: 50),
                  badgeContent: Text(
                    '$todayCount',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                  child: Text(
                    "Today",
                    key: ValueKey(SideDrawerKeys.TODAY),
                  ),
                ),
              )
            : ListTile(
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
                ),
              );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
