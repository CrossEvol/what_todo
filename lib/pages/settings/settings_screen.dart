import 'package:flutter/material.dart';
import 'package:flutter_app/bloc/settings/settings_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/providers/theme_provider.dart';
import 'package:flutter_app/styles/theme_data_style.dart';
import 'package:flutter_app/utils/app_util.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import '../../utils/strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool useCustomTheme = false;

  final platformsMap = <DevicePlatform, String>{
    DevicePlatform.device: 'Default',
    DevicePlatform.android: 'Android',
    DevicePlatform.iOS: 'iOS',
    DevicePlatform.web: 'Web',
    DevicePlatform.fuchsia: 'Fuchsia',
    DevicePlatform.linux: 'Linux',
    DevicePlatform.macOS: 'MacOS',
    DevicePlatform.windows: 'Windows',
  };
  DevicePlatform selectedPlatform = DevicePlatform.device;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.status == ResultStatus.success) {
          showSnackbar(
              context, 'Update ${state.updatedKey} ${state.status.toString()}.',
              materialColor: Colors.green);
        } else if (state.status == ResultStatus.failure) {
          showSnackbar(
              context, 'Update ${state.updatedKey} ${state.status.toString()}.',
              materialColor: Colors.red);
        }
      },
      builder: (context, state) {
        final useCountBadges = state.useCountBadges;
        final enableImportExport = state.enableImportExport;
        final enableNotifications = state.enableNotifications;
        final environment = state.environment;
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: SettingsList(
            platform: selectedPlatform,
            lightTheme: !useCustomTheme
                ? null
                : const SettingsThemeData(
                    dividerColor: Colors.red,
                    tileDescriptionTextColor: Colors.yellow,
                    leadingIconsColor: Colors.pink,
                    settingsListBackground: Colors.white,
                    settingsSectionBackground: Colors.green,
                    settingsTileTextColor: Colors.tealAccent,
                    tileHighlightColor: Colors.blue,
                    titleTextColor: Colors.cyan,
                    trailingTextColor: Colors.deepOrangeAccent,
                  ),
            darkTheme: !useCustomTheme
                ? null
                : const SettingsThemeData(
                    dividerColor: Colors.pink,
                    tileDescriptionTextColor: Colors.blue,
                    leadingIconsColor: Colors.red,
                    settingsListBackground: Colors.grey,
                    settingsSectionBackground: Colors.tealAccent,
                    settingsTileTextColor: Colors.green,
                    tileHighlightColor: Colors.yellow,
                    titleTextColor: Colors.cyan,
                    trailingTextColor: Colors.orange,
                  ),
            sections: [
              SettingsSection(
                title: const Text('Common'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    key: ValueKey(SettingKeys.LANGUAGE),
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    value: Text(state.language.name.capitalizeFirstLetter()),
                    onPressed: _toggleLanguage,
                  ),
                  SettingsTile.navigation(
                    key: ValueKey(SettingKeys.Environment),
                    leading: const Icon(Icons.cloud_outlined),
                    title: const Text('Environment'),
                    value: Text(environment.name.capitalizeFirstLetter()),
                    onPressed: _toggleEnvironment,
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.USE_COUNT_BADGES),
                    onToggle: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleUseCountBadgesEvent());
                    },
                    initialValue: useCountBadges,
                    leading: const Icon(Icons.badge),
                    title: const Text('Enable count badges'),
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.ENABLE_IMPORT_EXPORT),
                    onToggle: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleEnableImportExport());
                    },
                    initialValue: enableImportExport,
                    leading: const Icon(Icons.import_export),
                    title: const Text('Enable Import/Export'),
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.CONFIRM_DELETION),
                    onToggle: (value) {
                      context.read<SettingsBloc>().add(ToggleConfirmDeletion());
                    },
                    initialValue: state.confirmDeletion,
                    leading: const Icon(Icons.delete_forever),
                    title: const Text('Confirm Deletion'),
                    description: const Text(
                        'Show confirmation dialog before deleting items'),
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.ENABLE_DARK_MODE),
                    onToggle: (value) {
                      themeProvider.changeTheme();
                    },
                    initialValue:
                        themeProvider.themeDataStyle == ThemeDataStyle.dark,
                    leading: const Icon(Icons.style_sharp),
                    title: const Text('Enable Dark Mode'),
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.ENABLE_CUSTOM_THEME),
                    onToggle: (value) {
                      setState(() {
                        useCustomTheme = value;
                      });
                    },
                    initialValue: useCustomTheme,
                    leading: const Icon(Icons.format_paint),
                    title: const Text('Enable custom theme'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Editor'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    key: ValueKey(SettingKeys.LABEL_LEN),
                    // Use new key
                    leading: const Icon(Icons.label_outline),
                    // Changed icon
                    title: const Text('Label Max Length'),
                    // Changed title
                    value: Text('${state.labelLen}'),
                    // Use state.labelLen
                    onPressed: (context) => _toggleLength(
                        context,
                        SettingKeys.LABEL_LEN,
                        state.labelLen), // Use new handler
                  ),
                  SettingsTile.navigation(
                    key: ValueKey(SettingKeys.PROJECT_LEN),
                    // Use new key
                    leading: const Icon(Icons.folder_outlined),
                    // Changed icon
                    title: const Text('Project Max Length'),
                    // Changed title
                    value: Text('${state.projectLen}'),
                    // Use state.projectLen
                    onPressed: (context) => _toggleLength(
                        context,
                        SettingKeys.PROJECT_LEN,
                        state.projectLen), // Use new handler
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Account'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone number'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.mail),
                    title: const Text('Email'),
                    enabled: false,
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign out'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Security'),
                tiles: <SettingsTile>[
                  SettingsTile.switchTile(
                    onToggle: (_) {},
                    initialValue: true,
                    leading: const Icon(Icons.phonelink_lock),
                    title: const Text('Lock app in background'),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (_) {},
                    initialValue: true,
                    leading: const Icon(Icons.fingerprint),
                    title: const Text('Use fingerprint'),
                    description: const Text(
                      'Allow application to access stored fingerprint IDs',
                    ),
                  ),
                  SettingsTile.switchTile(
                    onToggle: (_) {},
                    initialValue: true,
                    leading: const Icon(Icons.lock),
                    title: const Text('Change password'),
                  ),
                  SettingsTile.switchTile(
                    key: ValueKey(SettingKeys.ENABLE_NOTIFICATIONS),
                    onToggle: (value) {
                      context
                          .read<SettingsBloc>()
                          .add(ToggleEnableNotificationsEvent());
                    },
                    initialValue: enableNotifications,
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Enable notifications'),
                  ),
                ],
              ),
              SettingsSection(
                title: const Text('Misc'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.collections_bookmark),
                    title: const Text('Open source license'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleEnvironment(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Environment.values
                  .map((env) => GestureDetector(
                        key: ValueKey('env-${env.name}'),
                        onTap: () {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleEnvironment(environment: env));
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: ListTile(
                            leading: const FlutterLogo(),
                            title: Text(env.name.capitalizeFirstLetter()),
                            trailing: const Icon(Icons.arrow_right),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: SizedBox(
          width: 300,
          height: 200,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Language.values
                  .map((lang) => GestureDetector(
                        key: ValueKey('lang-${lang.name}'),
                        onTap: () {
                          context
                              .read<SettingsBloc>()
                              .add(ToggleLanguage(language: lang));
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(lang.name.capitalizeFirstLetter()),
                            trailing: const Icon(Icons.arrow_right),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  // Added method to handle length toggling
  void _toggleLength(BuildContext context, String key, int currentValue) {
    // Define updated predefined length options
    final List<int> lengthOptions = [4, 8, 12, 16, 20]; // Updated options
    String title = key == SettingKeys.LABEL_LEN
        ? 'Select Label Max Length'
        : 'Select Project Max Length';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 300,
          // Adjust height based on options or make scrollable
          height: lengthOptions.length * 60.0, // Simple height calculation
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: lengthOptions
                  .map((len) => GestureDetector(
                        key: ValueKey('$key-$len'),
                        onTap: () {
                          if (key == SettingKeys.LABEL_LEN) {
                            context
                                .read<SettingsBloc>()
                                .add(ToggleLabelLen(len: len));
                          } else if (key == SettingKeys.PROJECT_LEN) {
                            context
                                .read<SettingsBloc>()
                                .add(ToggleProjectLen(len: len));
                          }
                          Navigator.pop(context);
                        },
                        child: Card(
                          child: ListTile(
                            title: Text('$len characters'),
                            trailing: currentValue == len
                                ? const Icon(Icons.check, color: Colors.blue)
                                : null,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class PlatformPickerScreen extends StatelessWidget {
  final DevicePlatform platform;
  final Map<DevicePlatform, String> platforms;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platforms')),
      body: SettingsList(
        platform: platform,
        sections: [
          SettingsSection(
            title: const Text('Select the platform you want'),
            tiles: platforms.keys.map((e) {
              final platform = platforms[e];

              return SettingsTile(
                title: Text(platform!),
                onPressed: (_) {
                  Navigator.of(context).pop(e);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  const PlatformPickerScreen(
      {super.key, required this.platform, required this.platforms});
}
