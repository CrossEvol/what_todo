import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/constants/keys.dart';
import 'package:flutter_app/models/github_config.dart';
import 'package:flutter_app/utils/logger_util.dart';
import 'package:flutter_app/utils/shard_prefs_util.dart';

/// A Cubit to manage GitHub configuration state.
/// Follows the CommentCubit pattern for state management.
class GitHubCubit extends Cubit<GitHubConfig> {
  GitHubCubit() : super(GitHubConfig.empty()) {
    _loadConfig();
  }

  /// Load GitHub configuration from shared_preferences on initialization
  Future<void> _loadConfig() async {
    try {
      final jsonString = prefs.getString(SettingKeys.GITHUB_CONFIG);
      if (jsonString != null && jsonString.isNotEmpty) {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        emit(GitHubConfig.fromMap(map));
        logger.info('GitHub config loaded successfully');
      }
    } catch (e) {
      logger.error(e, message: 'Failed to load GitHub config');
    }
  }

  /// Update GitHub configuration and persist to shared_preferences
  Future<void> updateConfig(GitHubConfig config) async {
    try {
      await prefs.setString(
        SettingKeys.GITHUB_CONFIG,
        jsonEncode(config.toMap()),
      );
      emit(config);
      logger.info('GitHub config updated successfully');
    } catch (e) {
      logger.error(e, message: 'Failed to update GitHub config');
    }
  }

  /// Clear GitHub configuration from shared_preferences
  Future<void> clearConfig() async {
    try {
      await prefs.remove(SettingKeys.GITHUB_CONFIG);
      emit(GitHubConfig.empty());
      logger.info('GitHub config cleared successfully');
    } catch (e) {
      logger.error(e, message: 'Failed to clear GitHub config');
    }
  }

  /// Check if GitHub is configured with valid credentials
  bool get isConfigured => state.isValid();
}
