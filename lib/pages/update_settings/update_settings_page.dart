import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/update/update_bloc.dart';
import '../../models/update_models.dart';
import '../../utils/logger_util.dart';
import '../../widgets/update_dialog.dart';

class UpdateSettingsPage extends StatefulWidget {
  const UpdateSettingsPage({super.key});

  @override
  State<UpdateSettingsPage> createState() => _UpdateSettingsPageState();
}

class _UpdateSettingsPageState extends State<UpdateSettingsPage> {
  UpdatePreferences? _currentPreferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final updateBloc = context.read<UpdateBloc>();
      final preferences = await updateBloc.getPreferences();
      setState(() {
        _currentPreferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      logger.error('Failed to load update preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePreference<T>(T value, T Function(UpdatePreferences) getter,
      UpdatePreferences Function(UpdatePreferences, T) setter) {
    if (_currentPreferences == null) return;

    final newPreferences = setter(_currentPreferences!, value);
    setState(() {
      _currentPreferences = newPreferences;
    });

    context.read<UpdateBloc>().add(UpdatePreferencesEvent(newPreferences));
    logger.debug('Updated preference: ${newPreferences.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentPreferences == null
              ? const Center(child: Text('Failed to load preferences'))
              : _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    final preferences = _currentPreferences!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Automatic Updates'),
          _buildSwitchTile(
            title: 'Auto-check for updates',
            subtitle: 'Automatically check for app updates daily',
            value: preferences.autoCheckEnabled,
            onChanged: (value) => _updatePreference(
              value,
              (p) => p.autoCheckEnabled,
              (p, v) => p.copyWith(autoCheckEnabled: v),
            ),
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'Show update notifications',
            subtitle: 'Display notifications when updates are available',
            value: preferences.showNotifications,
            onChanged: (value) => _updatePreference(
              value,
              (p) => p.showNotifications,
              (p, v) => p.copyWith(showNotifications: v),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Download Settings'),
          _buildSwitchTile(
            title: 'WiFi only downloads',
            subtitle: 'Only download updates when connected to WiFi',
            value: preferences.wifiOnlyDownload,
            onChanged: (value) => _updatePreference(
              value,
              (p) => p.wifiOnlyDownload,
              (p, v) => p.copyWith(wifiOnlyDownload: v),
            ),
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: 'Auto-download updates',
            subtitle: 'Automatically download available updates',
            value: preferences.autoDownload,
            onChanged: (value) => _updatePreference(
              value,
              (p) => p.autoDownload,
              (p, v) => p.copyWith(autoDownload: v),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Update Information'),
          _buildInfoTile(
            title: 'Last check',
            subtitle: _formatLastCheckTime(preferences.lastCheckTime),
            icon: Icons.schedule,
          ),
          const SizedBox(height: 8),
          _buildInfoTile(
            title: 'Skipped versions',
            subtitle: preferences.skippedVersions.isEmpty
                ? 'No versions skipped'
                : '${preferences.skippedVersions.length} version(s) skipped',
            icon: Icons.skip_next,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Actions'),
          _buildActionButton(
            title: 'Check for updates now',
            subtitle: 'Manually check for available updates',
            icon: Icons.refresh,
            onTap: _checkForUpdatesNow,
          ),
          const SizedBox(height: 8),
          _buildActionButton(
            title: 'Clear skipped versions',
            subtitle: 'Reset all skipped version preferences',
            icon: Icons.clear_all,
            onTap: _clearSkippedVersions,
            enabled: preferences.skippedVersions.isNotEmpty,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: enabled
                ? null
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: enabled
                ? null
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        enabled: enabled,
        onTap: enabled ? onTap : null,
      ),
    );
  }

  String _formatLastCheckTime(DateTime? lastCheck) {
    if (lastCheck == null) {
      return 'Never checked';
    }

    final now = DateTime.now();
    final difference = now.difference(lastCheck);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  void _checkForUpdatesNow() {
    logger.info('Manual update check triggered from settings');
    context.read<UpdateBloc>().add(const CheckForUpdatesEvent(isManual: true));

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocListener<UpdateBloc, UpdateState>(
        listener: (context, state) {
          Navigator.of(context).pop(); // Close loading dialog

          if (state is UpdateAvailable) {
            UpdateDialog.show(
              context,
              versionInfo: state.versionInfo,
              currentVersion: state.currentVersion,
            );
          } else if (state is UpdateNotAvailable) {
            _showSnackBar('No updates available');
          } else if (state is UpdateError) {
            _showSnackBar('Failed to check for updates: ${state.message}');
          }
        },
        child: const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Checking for updates...')),
            ],
          ),
        ),
      ),
    );
  }

  void _clearSkippedVersions() {
    if (_currentPreferences == null ||
        _currentPreferences!.skippedVersions.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Skipped Versions'),
        content: Text(
          'This will clear ${_currentPreferences!.skippedVersions.length} skipped version(s). '
          'You will receive notifications for these versions again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updatePreference(
                <String>[],
                (p) => p.skippedVersions,
                (p, v) => p.copyWith(skippedVersions: v),
              );
              _showSnackBar('Skipped versions cleared');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
