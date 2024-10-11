import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

late final ILogger logger;

Future<void> setupLogger() async => logger = ILogger();

class ILogger {
  static final ILogger _instance = ILogger._internal();
  late l.Logger _logger;

  factory ILogger() {
    return _instance;
  }

  ILogger._internal() {
    _initLogger();
  }

  Future<void> _initLogger() async {
    var filePath = "";
    if (!kDebugMode && !kIsWeb) {
      var dir = await getApplicationDocumentsDirectory();
      filePath = join(dir.path, 'logs', 'app.log');
    }

    _logger = l.Logger(
      filter: l.ProductionFilter(),
      printer: l.PrettyPrinter(),
      output:
          kDebugMode ? l.ConsoleOutput() : l.FileOutput(file: File(filePath)),
    );
  }

  l.Logger get logger => _logger;

  void trace(String message) => _logger.t(message);

  void debug(String message) => _logger.d(message);

  void info(String message) => _logger.i(message);

  void warn(String message) => _logger.w(message);

  void error(dynamic error, {String? message}) =>
      _logger.e(message ?? error.runtimeType.toString(), error: error);

  void fatal(dynamic error, {StackTrace? stackTrace, String? message}) =>
      _logger.f(message ?? error.runtimeType.toString(),
          error: error, stackTrace: stackTrace);
}
