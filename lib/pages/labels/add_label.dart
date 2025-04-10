import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/label/label_bloc.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/pages/labels/label.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart'; // Import SettingsBloc
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/l10n/app_localizations.dart';


class AddLabelPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddLabel();
  }
}

class AddLabel extends StatelessWidget {
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();

  @override
  Widget build(BuildContext context) {
    late ColorPalette currentSelectedPalette;
    String labelName = "";

    return BlocConsumer<LabelBloc, LabelState>(
      listener: (context, state) {
        if (state is LabelExistenceChecked) {
          if (state.exists) {
            showSnackbar(
                context, AppLocalizations.of(context)!.labelAlreadyExists);
          } else {
            context.safePop();
            if (context.isWiderScreen()) {
              context.read<HomeBloc>().add(UpdateScreenEvent(SCREEN.HOME));
            }
          }
        } else if (state is ColorSelectionUpdated) {
          return;
        } else {
          context.safePop();
        }
      },
      builder: (context, labelState) { // Rename state to avoid conflict
        // Access SettingsBloc state here
        final settingsState = context.watch<SettingsBloc>().state;
        final labelMaxLength = settingsState.labelLen;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.addLabel,
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
                context.read<LabelBloc>().add(CreateLabelEvent(label));
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
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.labelName),
                    maxLength: labelMaxLength, // Use setting value
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!.labelCannotBeEmpty;
                      }
                      if (value.length > labelMaxLength) {
                        return AppLocalizations.of(context)!
                            .valueTooLong(labelMaxLength); // Add localization if needed
                      }
                      return null;
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
                  buildWhen: (previous, current) =>
                      current is ColorSelectionUpdated,
                  builder: (context, state) {
                    if (state is ColorSelectionUpdated) {
                      currentSelectedPalette = state.colorPalette;
                    } else {
                      currentSelectedPalette =
                          ColorPalette("Grey", Colors.grey.value);
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
    );
  }

  List<Widget> buildMaterialColors(BuildContext context) {
    List<Widget> colorSelectionWidgets = [];
    colorsPalettes.forEach((colors) {
      colorSelectionWidgets.add(ListTile(
        leading: Icon(
          Icons.label,
          size: 16.0,
          color: Color(colors.colorValue),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          context.read<LabelBloc>().add(
                UpdateColorSelectionEvent(
                  ColorPalette(colors.colorName, colors.colorValue),
                ),
              );
        },
      ));
    });
    return colorSelectionWidgets;
  }
}
