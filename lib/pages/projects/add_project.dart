import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/home/home_bloc.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart'; // Import SettingsBloc
import 'package:flutter_app/pages/home/screen_enum.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/bloc/project/project_bloc.dart';
import 'package:flutter_app/pages/projects/project.dart';
import 'package:flutter_app/utils/collapsable_expand_tile.dart';
import 'package:flutter_app/constants/color_constant.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/utils/extension.dart';
import 'package:flutter_app/l10n/app_localizations.dart';

class AddProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddProject();
  }
}

class AddProject extends StatelessWidget {
  final expansionTile = GlobalKey<CollapsibleExpansionTileState>();
  final GlobalKey<FormState> _formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Access SettingsBloc state here
    final settingsState = context
        .watch<SettingsBloc>()
        .state;
    final projectMaxLength = settingsState.projectLen;

    late ColorPalette currentSelectedPalette;
    String projectName = "";

    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if(state is ProjectExistenceChecked){
          if(state.exists){
            showSnackbar(context, AppLocalizations.of(context)!.projectAlreadyExists);
          }
        }else if (state is ProjectCreateSuccess) {
          context.safePop();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.addProject,
              key: ValueKey(AddProjectKeys.TITLE_ADD_PROJECT),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            key: ValueKey(AddProjectKeys.ADD_PROJECT_BUTTON),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: () {
              if (_formState.currentState!.validate()) {
                _formState.currentState!.save();
                var project = Project.create(
                  projectName,
                  currentSelectedPalette.colorValue,
                  currentSelectedPalette.colorName,
                );
                context.read<ProjectBloc>().add(CreateProjectEvent(project));
                if (context.isWiderScreen()) {
                  context.read<HomeBloc>().add(UpdateScreenEvent(SCREEN.HOME));
                }
              }
            },
          ),
          body: ListView(
            children: <Widget>[
              Form(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    key: ValueKey(AddProjectKeys.TEXT_FORM_PROJECT_NAME),
                    decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.projectName),
                    maxLength: projectMaxLength,
                    // Use setting value
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .projectNameCannotBeEmpty;
                      }
                      if (value.length > projectMaxLength) {
                        // You might need to add a specific localization message for this
                        return AppLocalizations.of(context)!
                            .valueTooLong(projectMaxLength);
                      }
                      return null;
                    },
                    onSaved: (value) {
                      projectName = value!;
                    },
                  ),
                ),
                key: _formState,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: BlocBuilder<ProjectBloc, ProjectState>(
                  builder: (context, state) {
                    if (state is ColorSelectionUpdated) {
                      currentSelectedPalette = state.colorPalette;
                    } else {
                      currentSelectedPalette =
                          ColorPalette("Grey", Colors.grey.value);
                    }
                    return CollapsibleExpansionTile(
                      key: expansionTile,
                      leading: Container(
                        width: 12.0,
                        height: 12.0,
                        child: CircleAvatar(
                          backgroundColor: Color(
                              currentSelectedPalette.colorValue),
                        ),
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
    List<Widget> projectWidgetList = [];
    colorsPalettes.forEach((colors) {
      projectWidgetList.add(ListTile(
        leading: Container(
          width: 12.0,
          height: 12.0,
          child: CircleAvatar(
            backgroundColor: Color(colors.colorValue),
          ),
        ),
        title: Text(colors.colorName),
        onTap: () {
          expansionTile.currentState!.collapse();
          context.read<ProjectBloc>().add(
            UpdateColorSelectionEvent(
              ColorPalette(colors.colorName, colors.colorValue),
            ),
          );
        },
      ));
    });
    return projectWidgetList;
  }
}
