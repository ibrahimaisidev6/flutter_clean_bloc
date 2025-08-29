import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../error/exceptions.dart';
import 'mock_api_service.dart';
import 'network_info.dart';

class DioClient {
  late Dio _dio;
  final Logger _logger = Logger();
  final NetworkInfo _networkInfo;
  final MockApiService _mockApi = MockApiService();
  
  // Use mock API in development mode
  static const bool _useMockApi = true;

  DioClient(this._networkInfo) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('REQUEST: ${options.method} ${options.path}');
          _logger.i('HEADERS: ${options.headers}');
          if (options.data != null) {
            _logger.i('DATA: ${options.data}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          _logger.i('DATA: ${response.data}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          _logger.e('ERROR DATA: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock API if enabled
    if (_useMockApi) {
      return await _handleMockRequest<T>(path, 'GET', queryParameters: queryParameters);
    }
    
    try {
      if (!await _networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock API if enabled
    if (_useMockApi) {
      return await _handleMockRequest<T>(path, 'POST', data: data, queryParameters: queryParameters);
    }
    
    try {
      if (!await _networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock API if enabled
    if (_useMockApi) {
      return await _handleMockRequest<T>(path, 'PUT', data: data, queryParameters: queryParameters);
    }
    
    try {
      if (!await _networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    // Use mock API if enabled
    if (_useMockApi) {
      return await _handleMockRequest<T>(path, 'DELETE', data: data, queryParameters: queryParameters);
    }
    
    try {
      if (!await _networkInfo.isConnected) {
        throw const NetworkException('No internet connection');
      }

      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Connection timeout. Please check your internet connection.',
          'TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Connection error. Please check your internet connection.',
          'CONNECTION_ERROR',
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response!);

      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled', 'CANCELLED');

      case DioExceptionType.unknown:
      default:
        return NetworkException(
          'An unexpected error occurred: ${error.message}',
          'UNKNOWN',
        );
    }
  }

  AppException _handleHttpError(Response response) {
    final statusCode = response.statusCode;
    final data = response.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          data?['message'] ?? 'Bad request',
          'BAD_REQUEST',
          data?['errors'],
        );

      case 401:
        return const AuthenticationException(
          'Authentication failed. Please login again.',
          'UNAUTHORIZED',
        );

      case 403:
        return const AuthorizationException(
          'You are not authorized to perform this action.',
          'FORBIDDEN',
        );

      case 404:
        return NotFoundException(
          data?['message'] ?? 'Resource not found',
          'NOT_FOUND',
        );

      case 422:
        return ValidationException(
          data?['message'] ?? 'Validation failed',
          'VALIDATION_ERROR',
          data?['errors'],
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          data?['message'] ?? 'Server error. Please try again later.',
          'SERVER_ERROR',
        );

      default:
        return ServerException(
          data?['message'] ?? 'An unexpected error occurred',
          'HTTP_ERROR_$statusCode',
        );
    }
  }

  // Mock API request handler
  Future<Response<T>> _handleMockRequest<T>(
    String path,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    _logger.i('MOCK REQUEST: $method $path');
    if (data != null) {
      _logger.i('MOCK DATA: $data');
    }
    if (queryParameters != null) {
      _logger.i('MOCK QUERY: $queryParameters');
    }

    try {
      Map<String, dynamic> responseData;
      final token = _dio.options.headers['Authorization']?.toString().replaceFirst('Bearer ', '');

      switch (path) {
        // Auth endpoints
        case '/auth/login':
          responseData = await _mockApi.login(
            data['email'],
            data['password'],
          );
          break;

        case '/auth/register':
          responseData = await _mockApi.register(
            data['name'],
            data['email'],
            data['password'],
          );
          break;

        case '/auth/logout':
          responseData = await _mockApi.logout(token ?? '');
          break;

        case '/auth/me':
          responseData = await _mockApi.getCurrentUser(token ?? '');
          break;

        // Payment endpoints
        case '/payments':
          if (method == 'GET') {
            responseData = await _mockApi.getPayments(
              token ?? '',
              status: queryParameters?['status'],
              type: queryParameters?['type'],
              dateFrom: queryParameters?['date_from'],
              dateTo: queryParameters?['date_to'],
              amountMin: queryParameters?['amount_min']?.toDouble(),
              amountMax: queryParameters?['amount_max']?.toDouble(),
              page: int.tryParse(queryParameters?['page']?.toString() ?? '1') ?? 1,
              perPage: int.tryParse(queryParameters?['per_page']?.toString() ?? '15') ?? 15,
            );
          } else if (method == 'POST') {
            responseData = await _mockApi.createPayment(
              token ?? '',
              data['amount'].toDouble(),
              data['type'],
              data['description'],
              reference: data['reference'],
            );
          } else {
            throw const ServerException('Method not allowed', 'METHOD_NOT_ALLOWED');
          }
          break;

        // Dashboard endpoints
        case '/dashboard/stats':
          responseData = await _mockApi.getDashboardStats(
            token ?? '',
            period: queryParameters?['period'] ?? 'month',
          );
          break;

        default:
          // Handle payment detail endpoints (e.g., /payments/1)
          if (path.startsWith('/payments/')) {
            final segments = path.split('/');
            if (segments.length == 3) {
              final paymentId = int.tryParse(segments[2]);
              if (paymentId != null) {
                if (method == 'GET') {
                  responseData = await _mockApi.getPayment(token ?? '', paymentId);
                } else if (method == 'PUT') {
                  responseData = await _mockApi.updatePayment(
                    token ?? '',
                    paymentId,
                    amount: data?['amount']?.toDouble(),
                    type: data?['type'],
                    status: data?['status'],
                    description: data?['description'],
                    reference: data?['reference'],
                  );
                } else if (method == 'DELETE') {
                  responseData = await _mockApi.deletePayment(token ?? '', paymentId);
                } else {
                  throw const ServerException('Method not allowed', 'METHOD_NOT_ALLOWED');
                }
              } else {
                throw const NotFoundException('Invalid payment ID', 'INVALID_ID');
              }
            } else if (segments.length == 4) {
              // Handle /payments/:id/process endpoint
              final paymentId = int.tryParse(segments[2]);
              final action = segments[3];
              
              if (paymentId != null && action == 'process' && method == 'POST') {
                responseData = await _mockApi.processPayment(token ?? '', paymentId);
              } else {
                throw const NotFoundException('Endpoint not found', 'NOT_FOUND');
              }
            } else {
              throw const NotFoundException('Endpoint not found', 'NOT_FOUND');
            }
          } else {
            throw const NotFoundException('Endpoint not found', 'NOT_FOUND');
          }
      }

      _logger.i('MOCK RESPONSE: $responseData');

      return Response<T>(
        data: responseData as T,
        statusCode: 200,
        requestOptions: RequestOptions(path: path),
      );
    } catch (e) {
      _logger.e('MOCK ERROR: $e');
      
      if (e is AppException) {
        // Convert to DioException for consistent error handling
        throw DioException(
          requestOptions: RequestOptions(path: path),
          response: Response(
            data: {
              'success': false,
              'message': e.message,
              'code': e.code,
            },
            statusCode: _getStatusCodeForException(e),
            requestOptions: RequestOptions(path: path),
          ),
        );
      }
      
      throw ServerException('Mock API error: ${e.toString()}');
    }
  }

  int _getStatusCodeForException(AppException exception) {
    if (exception is AuthenticationException) return 401;
    if (exception is AuthorizationException) return 403;
    if (exception is NotFoundException) return 404;
    if (exception is ValidationException) return 422;
    if (exception is ServerException) return 500;
    return 500;
  }
}