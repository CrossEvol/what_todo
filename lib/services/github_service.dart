import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:github/github.dart';
import '../models/github_config.dart';
import '../utils/logger_util.dart';
import '../utils/dio_config.dart';

/// Service for interacting with GitHub API to upload and download task data
class GitHubService {
  /// Uploads tasks.json to the configured GitHub repository
  ///
  /// Creates a new file or updates an existing file with the provided JSON content.
  /// Automatically handles SHA retrieval for updates.
  ///
  /// Throws an exception if the upload fails.
  Future<void> uploadTasksJson({
    required GitHubConfig config,
    required String jsonContent,
  }) async {
    logger.info(
        'Starting upload to GitHub repository: ${config.owner}/${config.repo}');

    final github = GitHub(auth: Authentication.withToken(config.token));

    try {
      final slug = RepositorySlug(config.owner, config.repo);
      final filePath = _constructFilePath(config.pathPrefix, 'tasks.json');

      logger.debug('Uploading to path: $filePath on branch: ${config.branch}');

      // Get current file SHA if it exists (required for updates)
      String? sha;
      try {
        final existingFile = await github.repositories.getContents(
          slug,
          filePath,
          ref: config.branch,
        );
        if (existingFile.file != null) {
          sha = existingFile.file!.sha;
          logger.debug('Found existing file with SHA: $sha');
        }
      } catch (e) {
        // File doesn't exist, will create new file
        logger.debug('File does not exist, will create new file');
      }

      // Create or update file
      final commitMessage =
          'Update tasks.json - ${DateTime.now().toIso8601String()}';
      final base64Content = base64Encode(utf8.encode(jsonContent));

      // If file exists, update it; otherwise create it
      if (sha != null) {
        logger.debug('Updating existing file');
        await github.repositories.updateFile(
          slug,
          filePath,
          commitMessage,
          base64Content,
          sha,
          branch: config.branch,
        );
      } else {
        logger.debug('Creating new file');
        final fileRequest = CreateFile(
          path: filePath,
          message: commitMessage,
          content: base64Content,
          branch: config.branch,
        );
        await github.repositories.createFile(
          slug,
          fileRequest,
        );
      }

      logger.info('Successfully uploaded tasks.json to GitHub');
    } catch (e) {
      logger.error('Failed to upload tasks.json to GitHub: $e');
      rethrow;
    } finally {
      github.dispose();
    }
  }

  /// Downloads tasks.json from the configured GitHub repository
  ///
  /// Retrieves the file content from the specified path and branch.
  /// Returns the decoded JSON content as a string.
  ///
  /// Throws an exception if the download fails or file is not found.
  Future<String> downloadTasksJson({
    required GitHubConfig config,
  }) async {
    logger.info(
        'Starting download from GitHub repository: ${config.owner}/${config.repo}');

    final github = GitHub(auth: Authentication.withToken(config.token));

    try {
      final slug = RepositorySlug(config.owner, config.repo);
      final filePath = _constructFilePath(config.pathPrefix, 'tasks.json');

      logger.debug(
          'Downloading from path: $filePath on branch: ${config.branch}');

      final contents = await github.repositories.getContents(
        slug,
        filePath,
        ref: config.branch,
      );

      if (contents.file == null) {
        logger.error('tasks.json not found in repository');
        throw Exception('tasks.json not found in repository');
      }

      // Use downloadUrl to fetch the actual content
      final downloadUrl = contents.file!.downloadUrl;
      if (downloadUrl == null || downloadUrl.isEmpty) {
        logger.error('Download URL not available for tasks.json');
        throw Exception('Download URL not available for tasks.json');
      }

      logger.debug('Fetching content from download URL: $downloadUrl');

      // Use DioConfig instance with retry logic for better reliability
      final dio = DioConfig.instance;

      try {
        final response = await dio.get(
          downloadUrl,
          options: Options(
            responseType: ResponseType.plain,
            followRedirects: true,
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode != 200) {
          logger
              .error('Failed to download file content: ${response.statusCode}');
          throw Exception(
              'Failed to download file content: ${response.statusCode}');
        }

        final content = response.data as String;

        logger.info(
            'Successfully downloaded tasks.json from GitHub (${content.length} bytes)');
        return content;
      } on DioException catch (e) {
        logger.error('Dio error downloading file: ${e.type} - ${e.message}');
        throw Exception('Failed to download file from GitHub: ${e.message}');
      }
    } catch (e) {
      logger.error('Failed to download tasks.json from GitHub: $e');
      rethrow;
    } finally {
      github.dispose();
    }
  }

  /// Constructs the full file path by combining prefix and filename
  ///
  /// Handles various prefix formats:
  /// - Empty or "/" prefix returns just the filename
  /// - Normalizes prefix by removing leading slash and ensuring trailing slash
  ///
  /// Examples:
  /// - prefix: "/", filename: "tasks.json" -> "tasks.json"
  /// - prefix: "backup", filename: "tasks.json" -> "backup/tasks.json"
  /// - prefix: "/backup/", filename: "tasks.json" -> "backup/tasks.json"
  String _constructFilePath(String prefix, String filename) {
    if (prefix.isEmpty || prefix == '/') {
      return filename;
    }

    // Normalize prefix: remove leading slash, ensure trailing slash
    String normalizedPrefix = prefix;
    if (normalizedPrefix.startsWith('/')) {
      normalizedPrefix = normalizedPrefix.substring(1);
    }
    if (!normalizedPrefix.endsWith('/')) {
      normalizedPrefix += '/';
    }

    return '$normalizedPrefix$filename';
  }
}
