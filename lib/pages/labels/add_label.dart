import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/custom_bloc_provider.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/pages/home/my_home_bloc.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/pages/labels/my_label_bloc.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'label_db.dart';

class AddLabel extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  @override
  Widget build(BuildContext context) {
    late ColorPalette currentSelectedPalette;
    String labelName = "";

    return BlocProvider(
      create: (context) => LabelBloc(LabelDB.get()),
      child: BlocConsumer<LabelBloc, LabelState>(
        listener: (context, state) {
          if (state is LabelExistenceChecked) {
            if (state.exists) {
              showSnackbar(context, "Label already exists");
            } else {
              context.safePop();
              if (context.isWiderScreen()) {
                context.bloc<MyHomeBloc>().updateScreen(SCREEN.HOME);
              }
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Add Label",
                key: ValueKey(AddLabelKeys.TITLE_ADD_LABEL),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              key: ValueKey(AddLabelKeys.ADD_LABEL_BUTTON),
              child: Icon(
                Icons.send,
                color: Colors.white,
              ),
              onPressed: () async {
                if (_formState.currentState?.validate() ?? false) {
                  _formState.currentState?.save();
                  var label = Label.create(
                    labelName,
                    currentSelectedPalette.colorValue,
                    currentSelectedPalette.colorName,
                  );
                  context.read<LabelBloc>().add(CheckLabelExist(label));
                }
              },
            ),
            body: ListView(
              children: <Widget>[
                Form(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      key: ValueKey(AddLabelKeys.TEXT_FORM_LABEL_NAME),
                      decoration: InputDecoration(hintText: "Label Name"),
                      maxLength: 20,
                      validator: (value) {
                        return value!.isEmpty ? "Label Cannot be empty" : null;
                      },
                      onSaved: (value) {
                        labelName = value!;
                      },
                    ),
                  ),
                  key: _formState,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: BlocBuilder<LabelBloc, LabelState>(
                    buildWhen: (previous, current) => current is ColorSelectionUpdated,
                    builder: (context, state) {
                      if (state is ColorSelectionUpdated) {
                        currentSelectedPalette = state.colorPalette;
                      } else {
                        currentSelectedPalette = ColorPalette("Grey", Colors.grey.value);
                      }
                      return CollapsibleExpansionTile(
                        key: expansionTile,
                        leading: Icon(
                          Icons.label,
                          size: 16.0,
                          color: Color(currentSelectedPalette.colorValue),
                        ),
                        title: Text(currentSelectedPalette.colorName),
                        children: buildMaterialColors(context),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildMaterialColors(BuildContext context) {
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          context.read<LabelBloc>().add(
            UpdateColorSelection(
              ColorPalette(colors.colorName, colors.colorValue),
            ),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}