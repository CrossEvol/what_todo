import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../models/github_config.dart';
import '../utils/logger_util.dart';

/// Service for handling QR code generation and scanning for GitHub configuration
class QRCodeService {
  /// Generates QR code data from GitHubConfig
  /// Returns a JSON string representation of the config
  String generateQRData(GitHubConfig config) {
    try {
      final jsonString = jsonEncode(config.toMap());
      logger.debug('Generated QR data for GitHub config');
      return jsonString;
    } catch (e) {
      logger.error('Failed to generate QR data: $e');
      rethrow;
    }
  }

  /// Parses QR code data string to GitHubConfig
  /// Throws an exception if the QR data format is invalid
  GitHubConfig parseQRData(String qrData) {
    try {
      final map = jsonDecode(qrData) as Map<String, dynamic>;
      final config = GitHubConfig.fromMap(map);
      logger.debug('Successfully parsed QR data to GitHubConfig');
      return config;
    } catch (e) {
      logger.error('Failed to parse QR data: $e');
      throw Exception('Invalid QR code format: $e');
    }
  }

  /// Scans a QR code using the device camera
  /// Returns the scanned data as a string, or null if scan was cancelled or failed
  Future<String?> scanQRCode() async {
    try {
      logger.info('Starting QR code scan');
      final result = await BarcodeScanner.scan();
      
      if (result.type == ResultType.Barcode) {
        logger.info('QR code scanned successfully');
        return result.rawContent;
      } else if (result.type == ResultType.Cancelled) {
        logger.info('QR code scan cancelled by user');
        return null;
      } else {
        logger.warn('QR code scan returned unexpected result type: ${result.type}');
        return null;
      }
    } catch (e) {
      logger.error('QR scan error: $e');
      return null;
    }
  }
}
