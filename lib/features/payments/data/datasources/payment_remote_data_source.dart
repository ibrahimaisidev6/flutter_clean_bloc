import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  /// Get payments from API
  /// Throws [ServerException] for server errors
  Future<List<PaymentModel>> getPayments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get payment by ID from API
  /// Throws [ServerException] for server errors
  Future<PaymentModel> getPaymentById(int id);

  /// Create payment via API with optional attachment
  /// Throws [ServerException] for server errors
  /// Throws [ValidationException] for validation errors
  Future<PaymentModel> createPayment({
    required double amount,
    required String type,
    required String title,
    String? description,
    String? reference,
    String? category,
    File? attachmentFile,
  });

  /// Update payment via API with optional attachment
  /// Throws [ServerException] for server errors
  /// Throws [ValidationException] for validation errors
  Future<PaymentModel> updatePayment({
    required int id,
    double? amount,
    String? type,
    String? status,
    String? title,
    String? description,
    String? reference,
    String? category,
    File? attachmentFile,
  });

  /// Delete payment via API
  /// Throws [ServerException] for server errors
  Future<bool> deletePayment(int id);

  /// Process payment via API
  /// Throws [ServerException] for server errors
  Future<PaymentModel> processPayment(int id);

  /// Download attachment for a payment
  /// Throws [ServerException] for server errors
  Future<File> downloadAttachment(int paymentId, String fileName);

  /// Delete attachment for a payment
  /// Throws [ServerException] for server errors
  Future<bool> deleteAttachment(int paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final DioClient dioClient;

  PaymentRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PaymentModel>> getPayments({
    int page = 1,
    int perPage = 15,
    String? status,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (status != null) queryParameters['status'] = status;
      if (type != null) queryParameters['type'] = type;
      if (startDate != null) {
        queryParameters['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParameters['end_date'] = endDate.toIso8601String();
      }

      final response = await dioClient.get('/payments', queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw const ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw const ServerException('Section data manquante', '500');
        }
        
        final paymentsData = dataSection['payments'];
        if (paymentsData is! List) {
          throw const ServerException('Liste des paiements invalide', '500');
        }
        
        return paymentsData.map((json) => PaymentModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get payments',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<PaymentModel> getPaymentById(int id) async {
    try {
      final response = await dioClient.get('/payments/$id');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw const ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw const ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw const ServerException('Données de paiement invalides', '500');
        }
        
        return PaymentModel.fromJson(paymentData);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Payment not found',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<PaymentModel> createPayment({
    required double amount,
    required String type,
    required String title,
    String? description,
    String? reference,
    String? category,
    File? attachmentFile,
  }) async {
    try {
      dynamic data;
      
      if (attachmentFile != null) {
        // Création d'un FormData pour l'upload de fichier
        data = FormData.fromMap({
          'amount': amount,
          'type': type,
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
          if (reference != null && reference.isNotEmpty) 'reference': reference,
          if (category != null && category.isNotEmpty) 'category': category,
          'justificatif': await MultipartFile.fromFile(
            attachmentFile.path,
            filename: attachmentFile.path.split('/').last,
          ),
        });
      } else {
        // Données JSON classiques sans fichier
        data = {
          'amount': amount,
          'type': type,
          'title': title,
          if (description != null && description.isNotEmpty) 'description': description,
          if (reference != null && reference.isNotEmpty) 'reference': reference,
          if (category != null && category.isNotEmpty) 'category': category,
        };
      }

      final response = await dioClient.post(
        '/payments',
        data: data,
        options: attachmentFile != null 
            ? Options(
                headers: {'Content-Type': 'multipart/form-data'},
              )
            : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw const ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw const ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw const ServerException('Données de paiement invalides', '500');
        }
        
        return PaymentModel.fromJson(paymentData);
      } else {
        final errorMessage = response.data is Map<String, dynamic> 
            ? response.data['message'] ?? 'Failed to create payment'
            : 'Failed to create payment';
            
        throw ServerException(
          errorMessage,
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException || e is ValidationException) {
        rethrow;
      }
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw const ServerException('Timeout lors de l\'upload du fichier', '408');
        }
        if (e.response?.statusCode == 413) {
          throw const ServerException('Fichier trop volumineux', '413');
        }
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<PaymentModel> updatePayment({
    required int id,
    double? amount,
    String? type,
    String? status,
    String? title,
    String? description,
    String? reference,
    String? category,
    File? attachmentFile,
  }) async {
    try {
      dynamic data;
      
      if (attachmentFile != null) {
        // Mise à jour avec un nouveau fichier
        data = FormData.fromMap({
          if (amount != null) 'amount': amount,
          if (type != null) 'type': type,
          if (title != null) 'title': title,
          if (status != null) 'status': status,
          if (description != null) 'description': description,
          if (reference != null) 'reference': reference,
          if (category != null) 'category': category,
          'justificatif': await MultipartFile.fromFile(
            attachmentFile.path,
            filename: attachmentFile.path.split('/').last,
          ),
        });
      } else {
        // Mise à jour sans fichier
        data = <String, dynamic>{};
        if (amount != null) data['amount'] = amount;
        if (type != null) data['type'] = type;
        if (title != null) data['title'] = title;
        if (status != null) data['status'] = status;
        if (description != null) data['description'] = description;
        if (reference != null) data['reference'] = reference;
        if (category != null) data['category'] = category;
      }

      final response = await dioClient.put(
        '/payments/$id',
        data: data,
        options: attachmentFile != null 
            ? Options(
                headers: {'Content-Type': 'multipart/form-data'},
              )
            : null,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw const ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw const ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw const ServerException('Données de paiement invalides', '500');
        }
        
        return PaymentModel.fromJson(paymentData);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to update payment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException || e is ValidationException) {
        rethrow;
      }
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout) {
          throw const ServerException('Timeout lors de l\'upload du fichier', '408');
        }
        if (e.response?.statusCode == 413) {
          throw const ServerException('Fichier trop volumineux', '413');
        }
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<bool> deletePayment(int id) async {
    try {
      final response = await dioClient.delete('/payments/$id');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to delete payment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<PaymentModel> processPayment(int id) async {
    try {
      final response = await dioClient.post('/payments/$id/process');

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw const ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw const ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw const ServerException('Données de paiement invalides', '500');
        }
        
        return PaymentModel.fromJson(paymentData);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to process payment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<File> downloadAttachment(int paymentId, String fileName) async {
    try {
      final response = await dioClient.get(
        '/payments/$paymentId/attachment',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        // Créer un fichier temporaire pour stocker le téléchargement
        final directory = Directory.systemTemp;
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        
        await file.writeAsBytes(response.data);
        return file;
      } else {
        throw ServerException(
          'Failed to download attachment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to download attachment: ${e.toString()}',
        '500',
      );
    }
  }

  @override
  Future<bool> deleteAttachment(int paymentId) async {
    try {
      final response = await dioClient.delete('/payments/$paymentId/attachment');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to delete attachment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }

  /// Méthode helper pour valider les fichiers
  void _validateAttachmentFile(File file) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
    
    // Vérifier la taille du fichier
    final fileSize = file.lengthSync();
    if (fileSize > maxSizeInBytes) {
      throw ValidationException(
        'Le fichier ne peut pas dépasser 5MB',
        {'file_size': 'File too large'} as String?,
      );
    }
    
    // Vérifier l'extension
    final fileName = file.path.split('/').last.toLowerCase();
    final extension = fileName.split('.').last;
    
    if (!allowedExtensions.contains(extension)) {
      throw ValidationException(
        'Format de fichier non supporté. Utilisez: PDF, JPG, JPEG, PNG',
        {'file_type': 'Unsupported file type'} as String?,
      );
    }
  }
}