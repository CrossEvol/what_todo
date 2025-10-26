import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
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

import '../../bloc/update/update_bloc.dart';
import '../../widgets/update_dialog.dart';

class SideDrawer extends StatefulWidget {
  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  @override
  void initState() {
    super.initState();
    // Load basic data when the widget is initialized
    context.read<LabelBloc>().add(LoadLabelsEvent());
    context.read<ProjectBloc>().add(LoadProjectsEvent());
  }

  void _showUpdateProgressDialog(BuildContext context, dynamic state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateProgressDialog(
        versionInfo: state.versionInfo,
        progress: state.progress,
        startTime: state.startTime ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final environment = context.read<SettingsBloc>().state.environment;
    final homeBloc = context.read<HomeBloc>();

    return Drawer(
      child: BlocListener<UpdateBloc, UpdateState>(
        listener: (context, state) {
          // Auto-show progress dialog when download starts
          if (state is UpdateDownloading || state is UpdateDownloadPaused) {
            // Only show if no dialog is currently shown
            if (ModalRoute.of(context)?.isCurrent == true) {
              _showUpdateProgressDialog(context, state);
            }
          }
          // Show success message when download completes
          else if (state is UpdateDownloaded) {
            showSnackbar(context, 'Download completed! Tap to install.',
                materialColor: Colors.green);
          }
          // Show error if download fails
          else if (state is UpdateError) {
            showSnackbar(context, 'Update failed: ${state.message}',
                materialColor: Colors.red);
          }
        },
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
                      project.name, Filter.byStatus(TaskStatus.PENDING)));
                  context.read<TaskBloc>().add(FilterTasksEvent(
                      filter: Filter.byStatus(TaskStatus.PENDING)));
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
            // Update menu item with badge
            BlocBuilder<UpdateBloc, UpdateState>(
              builder: (context, updateState) {
                final hasUpdate =
                    updateState is UpdateAvailable && !updateState.isSkipped;
                final isDownloading = updateState is UpdateDownloading;
                final isDownloadPaused = updateState is UpdateDownloadPaused;
                final isChecking = updateState is UpdateChecking;
                final isDownloaded = updateState is UpdateDownloaded;
                final isInstalling = updateState is UpdateInstalling;

                return ListTile(
                  onTap: () {
                    context.safePop(); // Close the drawer
                    context
                        .push('/update_manager'); // Navigate to Update Manager
                  },
                  leading: Icon(
                    hasUpdate
                        ? Icons.system_update
                        : isDownloading
                            ? Icons.download
                            : isDownloadPaused
                                ? Icons.pause_circle_outline
                                : isDownloaded
                                    ? Icons.install_mobile
                                    : isInstalling
                                        ? Icons.settings_applications
                                        : isChecking
                                            ? Icons.refresh
                                            : Icons.update,
                    color: hasUpdate
                        ? Colors.orange
                        : isDownloading
                            ? Colors.green
                            : isDownloadPaused
                                ? Colors.orange
                                : isDownloaded
                                    ? Colors.blue
                                    : isInstalling
                                        ? Colors.purple
                                        : isChecking
                                            ? Colors.blue
                                            : null,
                  ),
                  title: hasUpdate
                      ? badges.Badge(
                          badgeStyle: const badges.BadgeStyle(
                            shape: badges.BadgeShape.circle,
                            padding: EdgeInsets.all(4),
                            badgeColor: Colors.red,
                          ),
                          position:
                              badges.BadgePosition.topEnd(top: -8, end: -8),
                          child: const Text('Update Manager'),
                        )
                      : isDownloading
                          ? const Text('Downloading...')
                          : isDownloadPaused
                              ? const Text('Download Paused')
                              : isDownloaded
                                  ? badges.Badge(
                                      badgeStyle: const badges.BadgeStyle(
                                        shape: badges.BadgeShape.circle,
                                        padding: EdgeInsets.all(4),
                                        badgeColor: Colors.blue,
                                      ),
                                      position: badges.BadgePosition.topEnd(
                                          top: -8, end: -8),
                                      child: const Text('Update Manager'),
                                    )
                                  : isInstalling
                                      ? const Text('Installing...')
                                      : isChecking
                                          ? const Text('Checking...')
                                          : const Text('Update Manager'),
                );
              },
            ),
            ListTile(
              onTap: () {
                context.push('/settings');
              },
              leading: Icon(Icons.settings_sharp),
              title: Text(
                AppLocalizations.of(context)!.settings,
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
                showSnackbar(context,
                    AppLocalizations.of(context)!.unknownNotImplemented,
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

    // Reminder Grid
    gridItems.add(
      ListTile(
        onTap: () {
          context.push('/reminder/grid');
        },
        leading: Icon(Icons.notifications_active_outlined),
        title: Text(
          "Reminder Grid",
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
