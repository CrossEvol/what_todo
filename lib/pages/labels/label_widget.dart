import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/pages/home/home.dart';
import 'package:flutter_app/pages/tasks/bloc/my_task_bloc.dart';
import 'package:flutter_app/pages/labels/label_db.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/labels/add_label.dart';
import 'package:flutter_app/pages/labels/my_label_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:go_router/go_router.dart';

class LabelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MyLabelBloc labelBloc = CustomBlocProvider.of(context);
    return StreamBuilder<List<Label>>(
      stream: labelBloc.labels,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LabelExpansionTileWidget(snapshot.data!);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
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
      title: Text("Labels",
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
      children: buildLabels(context),
    );
  }

  List<Widget> buildLabels(BuildContext context) {
    final _labelBloc = context.bloc<MyLabelBloc>();
    List<Widget> projectWidgetList = [];
    _labels.forEach((label) => projectWidgetList.add(LabelRow(label)));
    projectWidgetList.add(ListTile(
        leading: Icon(Icons.add),
        title: Text(
          "Add Label",
          key: ValueKey(SideDrawerKeys.ADD_LABEL),
        ),
        onTap: () async {
          context.go('/label/add');
          // await context.adaptiveNavigate(SCREEN.ADD_LABEL, AddLabelPage());
          _labelBloc.refresh();
        }));
    return projectWidgetList;
  }
}

class LabelRow extends StatelessWidget {
  final Label label;

  LabelRow(this.label);

  @override
  Widget build(BuildContext context) {
    final homeBloc = context.bloc<MyHomeBloc>();
    return ListTile(
      key: ValueKey("tile_${label.name}_${label.id}"),
      onTap: () {
        homeBloc.applyFilter("@ ${label.name}", Filter.byLabel(label.name));
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

class AddLabelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomBlocProvider(
      bloc: MyLabelBloc(LabelDB.get()),
      child: AddLabel(),
    );
  }
}
