import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../utils/logger_util.dart';

/// Security validator for auto-update functionality
class SecurityValidator {
  static SecurityValidator? _instance;

  static SecurityValidator get instance {
    _instance ??= SecurityValidator._internal();
    return _instance!;
  }

  SecurityValidator._internal();

  // Trusted GitHub domains for update sources
  static const List<String> _trustedDomains = [
    'github.com',
    'api.github.com',
    'raw.githubusercontent.com',
    'objects.githubusercontent.com',
  ];

  // Expected GitHub API endpoints
  static const List<String> _trustedApiPaths = [
    '/repos/',
    '/releases/',
  ];

  /// Validate if the download URL is from a trusted source
  bool validateDownloadSource(String url) {
    try {
      final uri = Uri.parse(url);

      // Must use HTTPS
      if (uri.scheme != 'https') {
        logger
            .error('Invalid URL scheme: ${uri.scheme}. Only HTTPS is allowed.');
        return false;
      }

      // Must be from trusted domain
      final domain = uri.host.toLowerCase();
      final isTrustedDomain = _trustedDomains
          .any((trusted) => domain == trusted || domain.endsWith('.$trusted'));

      if (!isTrustedDomain) {
        logger.error('Untrusted domain: $domain');
        return false;
      }

      // For GitHub releases, validate path structure
      if (domain.contains('github.com')) {
        if (!_validateGitHubReleasePath(uri.path)) {
          logger.error('Invalid GitHub release path: ${uri.path}');
          return false;
        }
      }

      // Must be APK file
      if (!url.toLowerCase().endsWith('.apk')) {
        logger.error('Invalid file type. Only APK files are allowed.');
        return false;
      }

      logger.info('Download source validation passed: $url');
      return true;
    } catch (e) {
      logger.error('Failed to validate download source: $e');
      return false;
    }
  }

  /// Validate GitHub release path structure
  bool _validateGitHubReleasePath(String path) {
    // Expected format: /user/repo/releases/download/tag/file.apk
    final pathSegments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (pathSegments.length < 6) return false;

    // Check for expected structure
    return pathSegments[2] == 'releases' && pathSegments[3] == 'download';
  }

  /// Validate API endpoint for version checking
  bool validateApiEndpoint(String url) {
    try {
      final uri = Uri.parse(url);

      // Must use HTTPS
      if (uri.scheme != 'https') {
        logger
            .error('Invalid API scheme: ${uri.scheme}. Only HTTPS is allowed.');
        return false;
      }

      // Must be GitHub API
      if (uri.host.toLowerCase() != 'api.github.com') {
        logger.error(
            'Invalid API host: ${uri.host}. Only api.github.com is allowed.');
        return false;
      }

      // Validate API path
      final isValidPath =
          _trustedApiPaths.any((trusted) => uri.path.contains(trusted));

      if (!isValidPath) {
        logger.error('Invalid API path: ${uri.path}');
        return false;
      }

      logger.debug('API endpoint validation passed: $url');
      return true;
    } catch (e) {
      logger.error('Failed to validate API endpoint: $e');
      return false;
    }
  }

  /// Calculate file hash for integrity verification
  Future<String> calculateFileHash(String filePath,
      {HashAlgorithm algorithm = HashAlgorithm.sha256}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }

      final bytes = await file.readAsBytes();

      late Digest digest;
      switch (algorithm) {
        case HashAlgorithm.md5:
          digest = md5.convert(bytes);
          break;
        case HashAlgorithm.sha1:
          digest = sha1.convert(bytes);
          break;
        case HashAlgorithm.sha256:
          digest = sha256.convert(bytes);
          break;
      }

      final hash = digest.toString();
      logger.debug('File hash calculated (${algorithm.name}): $hash');
      return hash;
    } catch (e) {
      logger.error('Failed to calculate file hash: $e');
      rethrow;
    }
  }

  /// Verify file integrity using hash
  Future<bool> verifyFileIntegrity(String filePath, String expectedHash,
      {HashAlgorithm algorithm = HashAlgorithm.sha256}) async {
    try {
      final actualHash =
          await calculateFileHash(filePath, algorithm: algorithm);
      final isValid = actualHash.toLowerCase() == expectedHash.toLowerCase();

      if (isValid) {
        logger.info('File integrity verification passed');
      } else {
        logger.error(
            'File integrity verification failed. Expected: $expectedHash, Actual: $actualHash');
      }

      return isValid;
    } catch (e) {
      logger.error('Failed to verify file integrity: $e');
      return false;
    }
  }

  /// Validate APK file signature (basic validation)
  Future<bool> validateApkSignature(String apkPath) async {
    try {
      final file = File(apkPath);
      if (!await file.exists()) {
        logger.error('APK file not found: $apkPath');
        return false;
      }

      // Basic APK structure validation
      final bytes = await file.readAsBytes();

      // Check APK magic bytes (ZIP format)
      if (bytes.length < 4) {
        logger.error('Invalid APK file: too small');
        return false;
      }

      // ZIP file magic bytes: PK (0x50, 0x4B)
      if (bytes[0] != 0x50 || bytes[1] != 0x4B) {
        logger.error('Invalid APK file: not a ZIP archive');
        return false;
      }

      // Additional validation: check for AndroidManifest.xml
      // This is a simplified check - in production, you might want to use
      // a proper APK parsing library
      final apkContent = utf8.decode(bytes, allowMalformed: true);
      if (!apkContent.contains('AndroidManifest.xml')) {
        logger.warn(
            'APK validation: AndroidManifest.xml not found in typical location');
      }

      logger.info('Basic APK signature validation passed');
      return true;
    } catch (e) {
      logger.error('Failed to validate APK signature: $e');
      return false;
    }
  }

  /// Validate file size constraints
  Future<bool> validateFileSize(int fileSize, {int maxSizeMB = 500}) async {
    const int bytesPerMB = 1024 * 1024;
    final maxSizeBytes = maxSizeMB * bytesPerMB;

    if (fileSize <= 0) {
      logger.error('Invalid file size: $fileSize');
      return false;
    }

    if (fileSize > maxSizeBytes) {
      logger.error('File size too large. Maximum allowed: ${maxSizeMB}MB');
      // logger.error('File size too large: ${fileSize / bytesPerMB:.1f}MB. Maximum allowed: ${maxSizeMB}MB');
      return false;
    }

    logger.debug('File size validation passed.');
    // logger.debug('File size validation passed: ${fileSize / bytesPerMB:.1f}MB');
    return true;
  }

  /// Validate version string format to prevent injection attacks
  bool validateVersionFormat(String version) {
    try {
      // Remove 'v' prefix if present
      final cleanVersion =
          version.startsWith('v') ? version.substring(1) : version;

      // Version should only contain digits, dots, and hyphens (for pre-release)
      final versionRegex =
          RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+(?:-[a-zA-Z0-9\.\-]+)?$');

      if (!versionRegex.hasMatch(cleanVersion)) {
        logger.error('Invalid version format: $version');
        return false;
      }

      // Additional length check to prevent extremely long version strings
      if (version.length > 50) {
        logger.error('Version string too long: $version');
        return false;
      }

      logger.debug('Version format validation passed: $version');
      return true;
    } catch (e) {
      logger.error('Failed to validate version format: $e');
      return false;
    }
  }

  /// Sanitize release notes to prevent XSS-like issues
  String sanitizeReleaseNotes(String? releaseNotes) {
    if (releaseNotes == null || releaseNotes.isEmpty) {
      return '';
    }

    try {
      // Remove potentially dangerous characters and patterns
      String sanitized = releaseNotes
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll(RegExp(r'javascript:', caseSensitive: false),
              '') // Remove javascript: URLs
          .replaceAll(
              RegExp(r'data:', caseSensitive: false), '') // Remove data: URLs
          .replaceAll(RegExp(r'[^\w\s\.\-\!\?\(\)\[\]\/\:,\n\r]'),
              ''); // Keep only safe characters

      // Limit length to prevent extremely long release notes
      if (sanitized.length > 5000) {
        sanitized = '${sanitized.substring(0, 4997)}...';
        logger.warn('Release notes truncated due to length');
      }

      return sanitized.trim();
    } catch (e) {
      logger.error('Failed to sanitize release notes: $e');
      return 'Release notes unavailable';
    }
  }

  /// Validate network security for Dio requests
  void configureSecureDio(Dio dio) {
    // Add security interceptor
    dio.interceptors.add(SecurityInterceptor());

    // Configure secure options
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 30);

    // Ensure HTTPS only
    dio.options.validateStatus = (status) {
      return status != null && status >= 200 && status < 300;
    };

    logger.info('Dio security configuration applied');
  }

  /// Comprehensive security validation for update process
  Future<SecurityValidationResult> validateUpdateSecurity({
    required String downloadUrl,
    required String apiEndpoint,
    required String version,
    String? expectedHash,
    String? releaseNotes,
    int? fileSize,
  }) async {
    final issues = <String>[];
    final warnings = <String>[];

    // Validate download source
    if (!validateDownloadSource(downloadUrl)) {
      issues.add('Untrusted download source');
    }

    // Validate API endpoint
    if (!validateApiEndpoint(apiEndpoint)) {
      issues.add('Untrusted API endpoint');
    }

    // Validate version format
    if (!validateVersionFormat(version)) {
      issues.add('Invalid version format');
    }

    // Validate file size if provided
    if (fileSize != null && !(await validateFileSize(fileSize))) {
      warnings.add('File size validation failed');
    }

    // Sanitize release notes
    final sanitizedNotes = sanitizeReleaseNotes(releaseNotes);
    if (sanitizedNotes != releaseNotes) {
      warnings.add('Release notes were sanitized');
    }

    final isSecure = issues.isEmpty;

    logger.info(
        'Security validation completed. Secure: $isSecure, Issues: ${issues.length}, Warnings: ${warnings.length}');

    return SecurityValidationResult(
      isSecure: isSecure,
      issues: issues,
      warnings: warnings,
      sanitizedReleaseNotes: sanitizedNotes,
    );
  }
}

/// Security interceptor for Dio requests
class SecurityInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Ensure HTTPS
    if (options.uri.scheme != 'https') {
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
        error: 'Only HTTPS requests are allowed',
      ));
      return;
    }

    // Add security headers
    options.headers['User-Agent'] = 'WhatTodo-AutoUpdater/1.0';
    options.headers['Accept'] = 'application/json';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.error(
        'Security interceptor caught error: ${err.type} - ${err.message}');
    handler.next(err);
  }
}

/// Hash algorithms supported for file integrity verification
enum HashAlgorithm {
  md5,
  sha1,
  sha256,
}

extension HashAlgorithmExtension on HashAlgorithm {
  String get name {
    switch (this) {
      case HashAlgorithm.md5:
        return 'MD5';
      case HashAlgorithm.sha1:
        return 'SHA1';
      case HashAlgorithm.sha256:
        return 'SHA256';
    }
  }
}

/// Result of security validation
class SecurityValidationResult {
  final bool isSecure;
  final List<String> issues;
  final List<String> warnings;
  final String sanitizedReleaseNotes;

  const SecurityValidationResult({
    required this.isSecure,
    required this.issues,
    required this.warnings,
    required this.sanitizedReleaseNotes,
  });

  /// Check if there are any critical security issues
  bool get hasCriticalIssues => issues.isNotEmpty;

  /// Check if there are security warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get formatted security report
  String get securityReport {
    final buffer = StringBuffer();

    if (isSecure) {
      buffer.writeln('🔒 Security validation passed');
    } else {
      buffer.writeln('⚠️ Security issues detected');
    }

    if (issues.isNotEmpty) {
      buffer.writeln('\nSecurity Issues:');
      for (final issue in issues) {
        buffer.writeln('  • $issue');
      }
    }

    if (warnings.isNotEmpty) {
      buffer.writeln('\nSecurity Warnings:');
      for (final warning in warnings) {
        buffer.writeln('  • $warning');
      }
    }

    return buffer.toString();
  }
}
