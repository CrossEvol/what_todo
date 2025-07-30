import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/task/task_bloc.dart';
import 'package:flutter_app/pages/tasks/bloc/filter.dart';
import 'package:flutter_app/pages/tasks/models/task.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class LabelsExpansionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelBloc, LabelState>(
      builder: (context, state) {
        if (state is LabelsLoaded) {
          return LabelExpansionTileWidget(state.labels);
        } else if (state is LabelLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadLabels));
        }
      },
    );
  }
}

class LabelExpansionTileWidget extends StatelessWidget {
  final List<Label> _labels;

  LabelExpansionTileWidget(this._labels);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: ValueKey(SideDrawerKeys.DRAWER_LABELS),
      leading: Icon(Icons.label),
      title: Text(AppLocalizations.of(context)!.labels,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildLabels(context),
    );
  }

  List<Widget> buildLabels(BuildContext context) {
    List<Widget> labelWidgetList = [];
    _labels.forEach((label) => labelWidgetList.add(LabelRow(label)));
    labelWidgetList.add(ListTile(
        leading: Icon(Icons.add),
        title: Text(
          AppLocalizations.of(context)!.addLabel,
          key: ValueKey(SideDrawerKeys.ADD_LABEL),
        ),
        onTap: () async {
          context.push('/label/add');
          context.read<LabelBloc>().add(RefreshLabelsEvent());
        }));
    return labelWidgetList;
  }
}

class LabelRow extends StatelessWidget {
  final Label label;

  LabelRow(this.label);

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.read<HomeBloc>();

    return ListTile(
      key: ValueKey("tile_${label.name}_${label.id}"),
      onTap: () {
        homeBloc.add(ApplyFilterEvent("@ ${label.name}",
            Filter.byLabel(label.name).copyWith(status: TaskStatus.PENDING)));
        context.read<TaskBloc>().add(LoadTasksByLabelEvent(
            labelName: label.name, status: TaskStatus.PENDING));
        context.safePop();
      },
      leading: Container(
        width: 24.0,
        height: 24.0,
        key: ValueKey("space_${label.name}_${label.id}"),
      ),
      title: Text(
        "@ ${label.name}",
        key: ValueKey("${label.name}_${label.id}"),
      ),
      trailing: Container(
        height: 10.0,
        width: 10.0,
        child: Icon(
          Icons.label,
          size: 16.0,
          key: ValueKey("icon_${label.name}_${label.id}"),
          color: Color(label.colorValue),
        ),
      ),
    );
  }
}
