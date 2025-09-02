import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger_util.dart';

class DioConfig {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio();

    // Configure base options
    dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.addAll([
      RequestLoggingInterceptor(),
      ResponseLoggingInterceptor(),
      ErrorLoggingInterceptor(),
      RetryInterceptor(),
    ]);

    return dio;
  }

  static void reset() {
    _dio = null;
  }
}

/// Interceptor for logging HTTP requests
class RequestLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.info('HTTP Request: ${options.method} ${options.uri}');
    if (kDebugMode) {
      logger.debug('Request Headers: ${options.headers}');
      if (options.data != null) {
        logger.debug('Request Data: ${options.data}');
      }
      if (options.queryParameters.isNotEmpty) {
        logger.debug('Query Parameters: ${options.queryParameters}');
      }
    }
    handler.next(options);
  }
}

/// Interceptor for logging HTTP responses
class ResponseLoggingInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.info(
      'HTTP Response: ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
    );
    if (kDebugMode) {
      logger.debug('Response Headers: ${response.headers}');
      logger.debug('Response Data: ${response.data}');
    }
    handler.next(response);
  }
}

/// Interceptor for logging HTTP errors
class ErrorLoggingInterceptor extends Interceptor {
  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    logger.error(
      'HTTP Error: ${error.type} ${error.message}',
      message: 'Request: ${error.requestOptions.method} ${error.requestOptions.uri}',
    );

    if (kDebugMode) {
      if (error.response != null) {
        logger.debug('Error Response Status: ${error.response?.statusCode}');
        logger.debug('Error Response Data: ${error.response?.data}');
      }
      logger.debug('Error Stack Trace: ${error.stackTrace}');
    }

    handler.next(error);
  }
}

/// Interceptor for automatic retry on network failures
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  @override
  Future<void> onError(DioException error, ErrorInterceptorHandler handler) async {
    final extra = error.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(error)) {
      logger.warn('Retrying request (${retryCount + 1}/$maxRetries): ${error.requestOptions.uri}');
      
      // Wait before retry
      await Future.delayed(retryDelay * (retryCount + 1));

      // Update retry count
      error.requestOptions.extra['retryCount'] = retryCount + 1;

      try {
        // Retry the request
        final response = await DioConfig.instance.fetch(error.requestOptions);
        handler.resolve(response);
      } catch (e) {
        // If retry fails, continue with error handling
        handler.next(error);
      }
    } else {
      handler.next(error);
    }
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode != null && error.response!.statusCode! >= 500);
  }
}

/// Extension for commonly used HTTP methods with built-in error handling
extension DioExtensions on Dio {
  /// GET request with enhanced error handling
  Future<T?> getWithErrorHandling<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await get(path, queryParameters: queryParameters, options: options);
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T?;
    } on DioException catch (e) {
      logger.error('GET request failed: $path', message: e.message);
      return null;
    } catch (e) {
      logger.error('Unexpected error during GET request: $path', message: e.toString());
      return null;
    }
  }

  /// POST request with enhanced error handling
  Future<T?> postWithErrorHandling<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? fromJson,
  }) async {
    try {
      final response = await post(path, data: data, queryParameters: queryParameters, options: options);
      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T?;
    } on DioException catch (e) {
      logger.error('POST request failed: $path', message: e.message);
      return null;
    } catch (e) {
      logger.error('Unexpected error during POST request: $path', message: e.toString());
      return null;
    }
  }
}