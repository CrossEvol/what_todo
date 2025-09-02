import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import '../utils/logger_util.dart';

/// Platform compatibility validator for auto-update functionality
class PlatformValidator {
  static PlatformValidator? _instance;
  static PlatformValidator get instance {
    _instance ??= PlatformValidator._internal();
    return _instance!;
  }

  PlatformValidator._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Validate Android platform compatibility for auto-update
  Future<PlatformCompatibilityResult> validateAndroidCompatibility() async {
    try {
      if (!Platform.isAndroid) {
        return PlatformCompatibilityResult(
          isCompatible: false,
          issues: ['Platform is not Android'],
          warnings: [],
        );
      }

      final androidInfo = await _deviceInfo.androidInfo;
      final issues = <String>[];
      final warnings = <String>[];

      // Check minimum SDK version (API 21 for auto-update features)
      if (androidInfo.version.sdkInt < 21) {
        issues.add('Android API level ${androidInfo.version.sdkInt} is below minimum required (21)');
      }

      // Check for scoped storage (Android 10+, API 29)
      if (androidInfo.version.sdkInt >= 29) {
        logger.info('Scoped storage is enforced on Android ${androidInfo.version.release}');
        // This is handled by our FileProvider configuration
      }

      // Check for notification permission requirements (Android 13+, API 33)
      if (androidInfo.version.sdkInt >= 33) {
        warnings.add('Android 13+ requires explicit notification permissions');
      }

      // Check for install unknown apps permission (Android 8+, API 26)
      if (androidInfo.version.sdkInt >= 26) {
        warnings.add('Android 8+ requires "Install unknown apps" permission for APK installation');
      }

      // Check available storage space
      final storageInfo = await _checkStorageSpace();
      if (storageInfo.availableSpaceMB < 100) {
        warnings.add('Low storage space available: ${storageInfo.availableSpaceMB}MB');
      }

      // Check device manufacturer specific issues
      _checkManufacturerSpecificIssues(androidInfo as AndroidDeviceInfo, warnings);

      logger.info('Platform validation completed for Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})');

      return PlatformCompatibilityResult(
        isCompatible: issues.isEmpty,
        issues: issues,
        warnings: warnings,
        deviceInfo: AndroidDeviceInfo(
          model: androidInfo.model,
          manufacturer: androidInfo.manufacturer,
          androidVersion: androidInfo.version.release,
          apiLevel: androidInfo.version.sdkInt,
          isPhysicalDevice: androidInfo.isPhysicalDevice,
        ),
      );
    } catch (e) {
      logger.error('Failed to validate Android compatibility: $e');
      return PlatformCompatibilityResult(
        isCompatible: false,
        issues: ['Failed to validate platform compatibility: $e'],
        warnings: [],
      );
    }
  }

  /// Check manufacturer-specific issues that might affect auto-update
  void _checkManufacturerSpecificIssues(AndroidDeviceInfo androidInfo, List<String> warnings) {
    final manufacturer = androidInfo.manufacturer.toLowerCase();

    switch (manufacturer) {
      case 'xiaomi':
        warnings.add('Xiaomi devices may require disabling MIUI optimization for APK installation');
        break;
      case 'huawei':
        warnings.add('Huawei devices may have strict app installation restrictions');
        break;
      case 'oppo':
      case 'oneplus':
        warnings.add('OnePlus/OPPO devices may require enabling "Install from unknown sources"');
        break;
      case 'vivo':
        warnings.add('Vivo devices may have additional security restrictions for APK installation');
        break;
      case 'samsung':
        warnings.add('Samsung devices with Knox security may have installation restrictions');
        break;
    }
  }

  /// Check available storage space
  Future<StorageInfo> _checkStorageSpace() async {
    try {
      // This is a simplified implementation
      // In a real app, you might use a plugin like device_info_plus or path_provider
      // to get actual storage information
      return StorageInfo(
        totalSpaceMB: 32000, // Placeholder
        availableSpaceMB: 8000, // Placeholder
      );
    } catch (e) {
      logger.error('Failed to check storage space: $e');
      return StorageInfo(
        totalSpaceMB: 0,
        availableSpaceMB: 0,
      );
    }
  }

  /// Validate notification permissions (Android 13+)
  Future<bool> validateNotificationPermissions() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await _deviceInfo.androidInfo;
      
      // Android 13+ requires explicit notification permission
      if (androidInfo.version.sdkInt >= 33) {
        // This would typically check actual permission status
        // For now, we'll return true and let the runtime handle it
        logger.info('Android 13+ detected, notification permissions may be required');
        return true;
      }
      
      return true;
    } catch (e) {
      logger.error('Failed to validate notification permissions: $e');
      return false;
    }
  }

  /// Validate install unknown apps permission
  Future<bool> validateInstallPermissions() async {
    try {
      if (!Platform.isAndroid) return true;

      final androidInfo = await _deviceInfo.androidInfo;
      
      // Android 8+ requires install unknown apps permission
      if (androidInfo.version.sdkInt >= 26) {
        logger.info('Android 8+ detected, install unknown apps permission may be required');
        // The actual permission check would be handled by the permission_handler
        return true;
      }
      
      return true;
    } catch (e) {
      logger.error('Failed to validate install permissions: $e');
      return false;
    }
  }

  /// Get Android security patch level information
  Future<String?> getSecurityPatchLevel() async {
    try {
      if (!Platform.isAndroid) return null;

      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.securityPatch;
    } catch (e) {
      logger.error('Failed to get security patch level: $e');
      return null;
    }
  }

  /// Check if device supports APK installation
  Future<bool> supportsApkInstallation() async {
    try {
      if (!Platform.isAndroid) return false;

      final androidInfo = await _deviceInfo.androidInfo;
      
      // Check if it's a physical device (emulators might have different behaviors)
      if (!androidInfo.isPhysicalDevice) {
        logger.warn('Running on emulator, APK installation behavior may differ');
      }

      // Check API level compatibility
      if (androidInfo.version.sdkInt < 21) {
        logger.error('Android API level too low for auto-update functionality');
        return false;
      }

      return true;
    } catch (e) {
      logger.error('Failed to check APK installation support: $e');
      return false;
    }
  }

  /// Get detailed device information for troubleshooting
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      if (!Platform.isAndroid) {
        return {'platform': 'Not Android'};
      }

      final androidInfo = await _deviceInfo.androidInfo;
      
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'product': androidInfo.product,
        'androidVersion': androidInfo.version.release,
        'apiLevel': androidInfo.version.sdkInt,
        'securityPatch': androidInfo.version.securityPatch,
        'isPhysicalDevice': androidInfo.isPhysicalDevice,
        'fingerprint': androidInfo.fingerprint,
        'bootloader': androidInfo.bootloader,
        'hardware': androidInfo.hardware,
        'supported32BitAbis': androidInfo.supported32BitAbis,
        'supported64BitAbis': androidInfo.supported64BitAbis,
        'supportedAbis': androidInfo.supportedAbis,
      };
    } catch (e) {
      logger.error('Failed to get device info: $e');
      return {'error': e.toString()};
    }
  }

  /// Check if device has sufficient resources for download
  Future<bool> hasResourcesForDownload(int fileSizeBytes) async {
    try {
      final storageInfo = await _checkStorageSpace();
      final requiredSpaceMB = (fileSizeBytes / (1024 * 1024)).ceil();
      
      // Require at least 2x the file size for safe download and installation
      final requiredSpaceWithBuffer = requiredSpaceMB * 2;
      
      if (storageInfo.availableSpaceMB < requiredSpaceWithBuffer) {
        logger.warn('Insufficient storage space for download. Required: ${requiredSpaceWithBuffer}MB, Available: ${storageInfo.availableSpaceMB}MB');
        return false;
      }
      
      return true;
    } catch (e) {
      logger.error('Failed to check resources for download: $e');
      return false;
    }
  }
}

/// Result of platform compatibility validation
class PlatformCompatibilityResult {
  final bool isCompatible;
  final List<String> issues;
  final List<String> warnings;
  final AndroidDeviceInfo? deviceInfo;

  const PlatformCompatibilityResult({
    required this.isCompatible,
    required this.issues,
    required this.warnings,
    this.deviceInfo,
  });

  /// Check if there are any critical issues
  bool get hasCriticalIssues => issues.isNotEmpty;

  /// Check if there are warnings
  bool get hasWarnings => warnings.isNotEmpty;

  /// Get formatted summary
  String get summary {
    final buffer = StringBuffer();
    
    if (isCompatible) {
      buffer.writeln('✅ Platform is compatible with auto-update functionality');
    } else {
      buffer.writeln('❌ Platform compatibility issues detected');
    }
    
    if (issues.isNotEmpty) {
      buffer.writeln('\nIssues:');
      for (final issue in issues) {
        buffer.writeln('  • $issue');
      }
    }
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\nWarnings:');
      for (final warning in warnings) {
        buffer.writeln('  • $warning');
      }
    }
    
    if (deviceInfo != null) {
      buffer.writeln('\nDevice Info:');
      buffer.writeln('  • ${deviceInfo!.manufacturer} ${deviceInfo!.model}');
      buffer.writeln('  • Android ${deviceInfo!.androidVersion} (API ${deviceInfo!.apiLevel})');
      buffer.writeln('  • Physical device: ${deviceInfo!.isPhysicalDevice}');
    }
    
    return buffer.toString();
  }
}

/// Android device information
class AndroidDeviceInfo {
  final String model;
  final String manufacturer;
  final String androidVersion;
  final int apiLevel;
  final bool isPhysicalDevice;

  const AndroidDeviceInfo({
    required this.model,
    required this.manufacturer,
    required this.androidVersion,
    required this.apiLevel,
    required this.isPhysicalDevice,
  });
}

/// Storage information
class StorageInfo {
  final int totalSpaceMB;
  final int availableSpaceMB;

  const StorageInfo({
    required this.totalSpaceMB,
    required this.availableSpaceMB,
  });

  double get usagePercentage {
    if (totalSpaceMB == 0) return 0.0;
    return ((totalSpaceMB - availableSpaceMB) / totalSpaceMB) * 100;
  }
}