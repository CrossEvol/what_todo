import 'dart:convert';
import 'package:github/github.dart';
import '../models/github_config.dart';
import '../utils/logger_util.dart';

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
    logger.info('Starting upload to GitHub repository: ${config.owner}/${config.repo}');
    
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
      final commitMessage = 'Update tasks.json - ${DateTime.now().toIso8601String()}';
      final createFileRequest = CreateFile(
        path: filePath,
        message: commitMessage,
        content: base64Encode(utf8.encode(jsonContent)),
        branch: config.branch,
      );
      
      // If file exists, we need to provide the SHA for update
      if (sha != null) {
        await github.repositories.updateFile(
          slug,
          filePath,
          commitMessage,
          jsonContent,
          sha,
          branch: config.branch,
        );
      } else {
        await github.repositories.createFile(
          slug,
          createFileRequest,
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
    logger.info('Starting download from GitHub repository: ${config.owner}/${config.repo}');
    
    final github = GitHub(auth: Authentication.withToken(config.token));
    
    try {
      final slug = RepositorySlug(config.owner, config.repo);
      final filePath = _constructFilePath(config.pathPrefix, 'tasks.json');
      
      logger.debug('Downloading from path: $filePath on branch: ${config.branch}');
      
      final contents = await github.repositories.getContents(
        slug,
        filePath,
        ref: config.branch,
      );
      
      if (contents.file == null) {
        logger.error('tasks.json not found in repository');
        throw Exception('tasks.json not found in repository');
      }
      
      // Decode the base64 content
      final decodedContent = utf8.decode(
        base64Decode(contents.file!.content!.replaceAll('\n', '')),
      );
      
      logger.info('Successfully downloaded tasks.json from GitHub');
      return decodedContent;
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
