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

  /// Create payment via API
  /// Throws [ServerException] for server errors
  /// Throws [ValidationException] for validation errors
  Future<PaymentModel> createPayment({
    required double amount,
    required String type,
    required String description,
    String? reference,
  });

  /// Update payment via API
  /// Throws [ServerException] for server errors
  /// Throws [ValidationException] for validation errors
  Future<PaymentModel> updatePayment({
    required int id,
    double? amount,
    String? type,
    String? status,
    String? description,
    String? reference,
  });

  /// Delete payment via API
  /// Throws [ServerException] for server errors
  Future<bool> deletePayment(int id);

  /// Process payment via API
  /// Throws [ServerException] for server errors
  Future<PaymentModel> processPayment(int id);
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
        // ✅ CORRECTION : Vérifier la structure de la réponse
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Format de réponse invalide', '500');
        }
        
        // Accéder à la section data
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw ServerException('Section data manquante', '500');
        }
        
        // Accéder aux paiements dans data.payments
        final paymentsData = dataSection['payments'];
        if (paymentsData is! List) {
          throw ServerException('Liste des paiements invalide', '500');
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
        // ✅ CORRECTION : Vérifier la structure de la réponse
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw ServerException('Données de paiement invalides', '500');
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
    required String description,
    String? reference,
  }) async {
    try {
      final data = {
        'amount': amount,
        'type': type,
        'description': description,
        if (reference != null) 'reference': reference,
      };

      final response = await dioClient.post('/payments', data: data);

      if (response.statusCode == 200) { // Mock retourne 200, pas 201
        // ✅ CORRECTION : Vérifier la structure de la réponse
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw ServerException('Données de paiement invalides', '500');
        }
        
        return PaymentModel.fromJson(paymentData);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to create payment',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException || e is ValidationException) {
        rethrow;
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
    String? description,
    String? reference,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (amount != null) data['amount'] = amount;
      if (type != null) data['type'] = type;
      if (status != null) data['status'] = status;
      if (description != null) data['description'] = description;
      if (reference != null) data['reference'] = reference;

      final response = await dioClient.put('/payments/$id', data: data);

      if (response.statusCode == 200) {
        // ✅ CORRECTION : Vérifier la structure de la réponse
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw ServerException('Données de paiement invalides', '500');
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
        // ✅ CORRECTION : Vérifier la structure de la réponse
        final responseData = response.data;
        
        if (responseData is! Map<String, dynamic>) {
          throw ServerException('Format de réponse invalide', '500');
        }
        
        final dataSection = responseData['data'];
        if (dataSection is! Map<String, dynamic>) {
          throw ServerException('Section data manquante', '500');
        }
        
        final paymentData = dataSection['payment'];
        if (paymentData is! Map<String, dynamic>) {
          throw ServerException('Données de paiement invalides', '500');
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
}