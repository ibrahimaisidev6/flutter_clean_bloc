import 'dart:convert';
import 'dart:math';
import '../error/exceptions.dart';

/// Mock API Service to simulate Laravel backend
/// This service provides realistic responses for the payment app
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  // Mock database
  final List<Map<String, dynamic>> _users = [
    {
      'id': 1,
      'name': 'Utilisateur Démo',
      'email': 'demo@dioko.com',
      'password': 'password123',
      'created_at': '2024-01-01T00:00:00.000000Z',
      'updated_at': '2024-01-01T00:00:00.000000Z',
    },
    {
      'id': 2,
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'created_at': '2024-01-01T00:00:00.000000Z',
      'updated_at': '2024-01-01T00:00:00.000000Z',
    },
  ];

  final List<Map<String, dynamic>> _payments = [
    {
      'id': 1,
      'user_id': 1,
      'amount': 150.50,
      'type': 'expense',
      'status': 'completed',
      'description': 'Facture Internet Février 2025',
      'reference': 'PAY-001-2025',
      'created_at': '2025-02-15T10:30:00.000000Z',
      'updated_at': '2025-02-15T10:30:00.000000Z',
    },
    {
      'id': 2,
      'user_id': 1,
      'amount': 75.25,
      'type': 'expense',
      'status': 'pending',
      'description': 'Facture Électricité Février 2025',
      'reference': 'PAY-002-2025',
      'created_at': '2025-02-20T14:45:00.000000Z',
      'updated_at': '2025-02-20T14:45:00.000000Z',
    },
    {
      'id': 3,
      'user_id': 1,
      'amount': 45.00,
      'type': 'expense',
      'status': 'completed',
      'description': 'Facture Eau Février 2025',
      'reference': 'PAY-003-2025',
      'created_at': '2025-02-18T09:15:00.000000Z',
      'updated_at': '2025-02-18T09:15:00.000000Z',
    },
    {
      'id': 4,
      'user_id': 1,
      'amount': 850.00,
      'type': 'expense',
      'status': 'completed',
      'description': 'Loyer Février 2025',
      'reference': 'PAY-004-2025',
      'created_at': '2025-02-01T08:00:00.000000Z',
      'updated_at': '2025-02-01T08:00:00.000000Z',
    },
    {
      'id': 5,
      'user_id': 1,
      'amount': 25.50,
      'type': 'expense',
      'status': 'failed',
      'description': 'Abonnement Netflix',
      'reference': 'PAY-005-2025',
      'created_at': '2025-02-22T16:20:00.000000Z',
      'updated_at': '2025-02-22T16:20:00.000000Z',
    },
  ];

  final Map<String, String> _tokens = {};
  int _nextUserId = 3;
  int _nextPaymentId = 6;

  // Simulate network delay
  Future<void> _simulateDelay([int? milliseconds]) async {
    await Future.delayed(Duration(milliseconds: milliseconds ?? Random().nextInt(500) + 200));
  }

  // Generate JWT token (mock)
  String _generateToken(int userId) {
    final payload = base64Encode(utf8.encode(jsonEncode({
      'sub': userId,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    })));
    
    final token = 'mock.token.$payload';
    _tokens[token] = userId.toString();
    return token;
  }

  // Validate token
  int? _getUserIdFromToken(String token) {
    final userId = _tokens[token];
    return userId != null ? int.tryParse(userId) : null;
  }

  // Auth endpoints
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateDelay();

    final user = _users.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw const AuthenticationException('Email ou mot de passe incorrect', 'INVALID_CREDENTIALS');
    }

    final token = _generateToken(user['id']);
    final userData = Map<String, dynamic>.from(user);
    userData.remove('password');

    return {
      'success': true,
      'message': 'Connexion réussie',
      'data': {
        'user': userData,
        'token': token,
      },
    };
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await _simulateDelay();

    // Check if email already exists
    final existingUser = _users.where((u) => u['email'] == email).firstOrNull;
    if (existingUser != null) {
      throw const ValidationException(
        'L\'email est déjà utilisé',
        'EMAIL_TAKEN',
        'email',
        {'email': ['L\'email est déjà utilisé par un autre compte']},
      );
    }

    final now = DateTime.now().toIso8601String();
    final newUser = {
      'id': _nextUserId++,
      'name': name,
      'email': email,
      'password': password,
      'created_at': now,
      'updated_at': now,
    };

    _users.add(newUser);

    final token = _generateToken(newUser['id'] as int);
    final userData = Map<String, dynamic>.from(newUser);
    userData.remove('password');

    return {
      'success': true,
      'message': 'Compte créé avec succès',
      'data': {
        'user': userData,
        'token': token,
      },
    };
  }

  Future<Map<String, dynamic>> logout(String token) async {
    await _simulateDelay();
    
    _tokens.remove(token);
    
    return {
      'success': true,
      'message': 'Déconnexion réussie',
    };
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final user = _users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw const AuthenticationException('Utilisateur introuvable', 'USER_NOT_FOUND');
    }

    final userData = Map<String, dynamic>.from(user);
    userData.remove('password');

    return {
      'success': true,
      'data': {
        'user': userData,
      },
    };
  }

  // Payment endpoints

  Future<Map<String, dynamic>> getPayments(
    String token, {
    String? status,
    String? type,
    String? dateFrom,
    String? dateTo,
    double? amountMin,
    double? amountMax,
    int page = 1,
    int perPage = 15,
  }) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    // Filter payments
    var filteredPayments = _payments.where((p) => p['user_id'] == userId).toList();

    if (status != null) {
      filteredPayments = filteredPayments.where((p) => p['status'] == status).toList();
    }
    if (type != null) {
      filteredPayments = filteredPayments.where((p) => p['type'] == type).toList();
    }
    if (amountMin != null) {
      filteredPayments = filteredPayments.where((p) => p['amount'] >= amountMin).toList();
    }
    if (amountMax != null) {
      filteredPayments = filteredPayments.where((p) => p['amount'] <= amountMax).toList();
    }

    // Sort by date (newest first)
    filteredPayments.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    // Pagination
    final total = filteredPayments.length;
    final lastPage = (total / perPage).ceil();
    final from = (page - 1) * perPage + 1;
    final to = (page * perPage < total) ? page * perPage : total;
    
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;
    final paginatedPayments = filteredPayments.sublist(
      startIndex,
      endIndex > filteredPayments.length ? filteredPayments.length : endIndex,
    );

    return {
      'success': true,
      'data': {
        'payments': paginatedPayments,
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
          'from': from,
          'to': to,
        },
      },
    };
  }

  Future<Map<String, dynamic>> getPayment(String token, int paymentId) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final payment = _payments.firstWhere(
      (p) => p['id'] == paymentId && p['user_id'] == userId,
      orElse: () => {},
    );

    if (payment.isEmpty) {
      throw const NotFoundException('Paiement introuvable', 'PAYMENT_NOT_FOUND');
    }

    return {
      'success': true,
      'data': {
        'payment': payment,
      },
    };
  }

  Future<Map<String, dynamic>> createPayment(
    String token,
    double amount,
    String type,
    String description, {
    String? reference,
  }) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final now = DateTime.now().toIso8601String();
    final newPayment = {
      'id': _nextPaymentId++,
      'user_id': userId,
      'amount': amount,
      'type': type,
      'status': 'pending',
      'description': description,
      'reference': reference ?? 'PAY-${_nextPaymentId - 1}-${DateTime.now().year}',
      'created_at': now,
      'updated_at': now,
    };

    _payments.add(newPayment);

    // Simulate payment processing (some succeed, some fail)
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final success = Random().nextBool();
    newPayment['status'] = success ? 'completed' : 'failed';
    newPayment['updated_at'] = DateTime.now().toIso8601String();

    return {
      'success': true,
      'message': 'Paiement créé avec succès',
      'data': {
        'payment': newPayment,
      },
    };
  }

  Future<Map<String, dynamic>> updatePayment(
    String token,
    int paymentId, {
    double? amount,
    String? type,
    String? status,
    String? description,
    String? reference,
  }) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final paymentIndex = _payments.indexWhere(
      (p) => p['id'] == paymentId && p['user_id'] == userId,
    );

    if (paymentIndex == -1) {
      throw const NotFoundException('Paiement introuvable', 'PAYMENT_NOT_FOUND');
    }

    final payment = _payments[paymentIndex];
    
    if (amount != null) payment['amount'] = amount;
    if (type != null) payment['type'] = type;
    if (status != null) payment['status'] = status;
    if (description != null) payment['description'] = description;
    if (reference != null) payment['reference'] = reference;
    payment['updated_at'] = DateTime.now().toIso8601String();

    return {
      'success': true,
      'message': 'Paiement mis à jour avec succès',
      'data': {
        'payment': payment,
      },
    };
  }

  Future<Map<String, dynamic>> deletePayment(String token, int paymentId) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final paymentIndex = _payments.indexWhere(
      (p) => p['id'] == paymentId && p['user_id'] == userId,
    );

    if (paymentIndex == -1) {
      throw const NotFoundException('Paiement introuvable', 'PAYMENT_NOT_FOUND');
    }

    _payments.removeAt(paymentIndex);

    return {
      'success': true,
      'message': 'Paiement supprimé avec succès',
    };
  }

  Future<Map<String, dynamic>> processPayment(
    String token,
    int paymentId,
  ) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final paymentIndex = _payments.indexWhere(
      (p) => p['id'] == paymentId && p['user_id'] == userId,
    );

    if (paymentIndex == -1) {
      throw const NotFoundException('Paiement introuvable', 'PAYMENT_NOT_FOUND');
    }

    final payment = _payments[paymentIndex];

    // Vérifier que le paiement est en attente
    // Remplacer cette partie dans processPayment:
    if (payment['status'] != 'pending') {
      throw const ValidationException(
        'Ce paiement ne peut pas être traité',
        'PAYMENT_ALREADY_PROCESSED',
        'status', // Correct parameter type
        {'status': ['Le paiement doit être en attente pour être traité']},
      );
    }

    // Simuler le traitement (90% de succès, 10% d'échec)
    await Future.delayed(const Duration(milliseconds: 2000));
    
    final success = Random().nextDouble() > 0.1; // 90% de succès
    final now = DateTime.now().toIso8601String();
    
    payment['status'] = success ? 'completed' : 'failed';
    payment['updated_at'] = now;
    
    if (success) {
      payment['processed_at'] = now;
    }

    return {
      'success': true,
      'message': success 
          ? 'Paiement traité avec succès' 
          : 'Le traitement du paiement a échoué',
      'data': {
        'payment': payment,
        'processing_result': {
          'status': success ? 'success' : 'failed',
          'processed_at': now,
          'transaction_id': success ? 'TXN-${payment['id']}-${DateTime.now().millisecondsSinceEpoch}' : null,
        },
      },
    };
  }

  // Dashboard endpoints

  Future<Map<String, dynamic>> getDashboardStats(String token, {String period = 'month'}) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final userPayments = _payments.where((p) => p['user_id'] == userId).toList();

    double totalIncome = 0;
    double totalExpense = 0;
    int pendingCount = 0;
    int completedCount = 0;
    int failedCount = 0;

    for (final payment in userPayments) {
      final amount = payment['amount'] as double;
      final type = payment['type'] as String;
      final status = payment['status'] as String;

      if (type == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }

      switch (status) {
        case 'pending':
          pendingCount++;
          break;
        case 'completed':
          completedCount++;
          break;
        case 'failed':
          failedCount++;
          break;
      }
    }

    final recentPayments = userPayments.take(5).toList();

    return {
      'success': true,
      'data': {
        'stats': {
          'total_income': totalIncome,
          'total_expense': totalExpense,
          'net_balance': totalIncome - totalExpense,
          'total_payments': userPayments.length,
          'pending_payments': pendingCount,
          'completed_payments': completedCount,
          'failed_payments': failedCount,
          'period': period,
        },
        'recent_payments': recentPayments,
        'monthly_chart': [
          {'month': 'Jan', 'income': 0, 'expense': 0},
          {'month': 'Fév', 'income': 0, 'expense': totalExpense},
        ],
      },
    };
  }

  // History endpoints
  Future<Map<String, dynamic>> getPaymentHistory(
    String token, {
    int page = 1,
    int perPage = 15,
  }) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    // Get all payments for the user and sort by date
    var userPayments = _payments.where((p) => p['user_id'] == userId).toList();
    userPayments.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    // Add some mock transaction history entries
    final List<Map<String, dynamic>> history = [
      ...userPayments.map((payment) => {
        ...payment,
        'transaction_type': 'payment',
        'category': _getCategoryFromDescription(payment['description'] as String),
      }),
      // Add some mock refunds and adjustments
      {
        'id': 100,
        'user_id': userId,
        'amount': 25.0,
        'type': 'refund',
        'status': 'completed',
        'description': 'Remboursement Abonnement Netflix',
        'reference': 'REF-001-2025',
        'transaction_type': 'refund',
        'category': 'Entertainment',
        'created_at': '2025-02-10T16:20:00.000000Z',
        'updated_at': '2025-02-10T16:20:00.000000Z',
      },
      {
        'id': 101,
        'user_id': userId,
        'amount': 5.0,
        'type': 'adjustment',
        'status': 'completed',
        'description': 'Ajustement de solde',
        'reference': 'ADJ-001-2025',
        'transaction_type': 'adjustment',
        'category': 'System',
        'created_at': '2025-02-05T12:00:00.000000Z',
        'updated_at': '2025-02-05T12:00:00.000000Z',
      },
    ];

    // Sort all history by date
    history.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    // Pagination
    final total = history.length;
    final lastPage = (total / perPage).ceil();
    final from = total > 0 ? (page - 1) * perPage + 1 : 0;
    final to = (page * perPage < total) ? page * perPage : total;
    
    final startIndex = (page - 1) * perPage;
    final endIndex = startIndex + perPage;
    final paginatedHistory = history.sublist(
      startIndex,
      endIndex > history.length ? history.length : endIndex,
    );

    return {
      'success': true,
      'data': {
        'transactions': paginatedHistory,
        'pagination': {
          'current_page': page,
          'per_page': perPage,
          'total': total,
          'last_page': lastPage,
          'from': from,
          'to': to,
        },
        'summary': {
          'total_transactions': total,
          'total_amount': history.fold<double>(0.0, (sum, t) => sum + (t['amount'] as double)),
          'categories': _getCategorySummary(history),
        },
      },
    };
  }

  // Profile endpoints
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final user = _users.firstWhere(
      (u) => u['id'] == userId,
      orElse: () => {},
    );

    if (user.isEmpty) {
      throw const AuthenticationException('Utilisateur introuvable', 'USER_NOT_FOUND');
    }

    final userData = Map<String, dynamic>.from(user);
    userData.remove('password');

    // Add additional profile information
    final profile = {
      ...userData,
      'phone': '+221 77 123 45 67',
      'avatar': null,
      'verified': true,
      'preferences': {
        'currency': 'XOF',
        'language': 'fr',
        'notifications': {
          'email': true,
          'sms': true,
          'push': true,
        },
        'security': {
          'two_factor_enabled': false,
          'biometric_enabled': true,
          'last_password_change': '2024-01-01T00:00:00.000000Z',
        },
      },
      'wallet': {
        'balance': _calculateUserBalance(userId),
        'currency': 'XOF',
        'status': 'active',
        'daily_limit': 100000.0,
        'monthly_limit': 500000.0,
      },
      'statistics': {
        'total_payments': _payments.where((p) => p['user_id'] == userId).length,
        'successful_payments': _payments.where((p) => p['user_id'] == userId && p['status'] == 'completed').length,
        'total_amount_spent': _payments
            .where((p) => p['user_id'] == userId && p['type'] == 'expense' && p['status'] == 'completed')
            .fold<double>(0.0, (sum, p) => sum + (p['amount'] as double)),
        'member_since': userData['created_at'],
      },
    };

    return {
      'success': true,
      'data': {
        'user': profile,
      },
    };
  }

  Future<Map<String, dynamic>> updateUserProfile(
    String token, {
    String? name,
    String? email,
    String? phone,
  }) async {
    await _simulateDelay();

    final userId = _getUserIdFromToken(token);
    if (userId == null) {
      throw const AuthenticationException('Token invalide', 'INVALID_TOKEN');
    }

    final userIndex = _users.indexWhere((u) => u['id'] == userId);
    if (userIndex == -1) {
      throw const AuthenticationException('Utilisateur introuvable', 'USER_NOT_FOUND');
    }

    // Check if email is already taken by another user
    // Check if email already exists
    final existingUser = _users.where((u) => u['email'] == email).firstOrNull;
    if (existingUser != null) {
      throw const ValidationException(
        'L\'email est déjà utilisé',
        'EMAIL_TAKEN',
        'email',
        {'email': ['L\'email est déjà utilisé par un autre compte']},
      );
    }

    final user = _users[userIndex];
    
    if (name != null) user['name'] = name;
    if (email != null) user['email'] = email;
    user['updated_at'] = DateTime.now().toIso8601String();

    final updatedProfile = await getUserProfile(token);

    return {
      'success': true,
      'message': 'Profil mis à jour avec succès',
      'data': updatedProfile['data'],
    };
  }

  // Helper methods
  String _getCategoryFromDescription(String description) {
    final desc = description.toLowerCase();
    if (desc.contains('internet') || desc.contains('mobile')) return 'Telecommunications';
    if (desc.contains('électricité') || desc.contains('eau') || desc.contains('gaz')) return 'Utilities';
    if (desc.contains('loyer') || desc.contains('appartement')) return 'Housing';
    if (desc.contains('netflix') || desc.contains('spotify') || desc.contains('abonnement')) return 'Entertainment';
    if (desc.contains('transport') || desc.contains('taxi')) return 'Transportation';
    if (desc.contains('alimentaire') || desc.contains('restaurant')) return 'Food';
    return 'Other';
  }

  Map<String, dynamic> _getCategorySummary(List<Map<String, dynamic>> transactions) {
    final categories = <String, Map<String, dynamic>>{};
    
    for (final transaction in transactions) {
      final category = transaction['category'] as String;
      final amount = transaction['amount'] as double;
      
      if (!categories.containsKey(category)) {
        categories[category] = {'count': 0, 'total_amount': 0.0};
      }
      
      categories[category]!['count'] = categories[category]!['count'] + 1;
      categories[category]!['total_amount'] = categories[category]!['total_amount'] + amount;
    }
    
    return categories;
  }

  double _calculateUserBalance(int userId) {
    final userPayments = _payments.where((p) => p['user_id'] == userId && p['status'] == 'completed');
    double income = 0.0;
    double expense = 0.0;
    
    for (final payment in userPayments) {
      final amount = payment['amount'] as double;
      if (payment['type'] == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
    }
    
    // Start with a base balance and subtract expenses
    return 5000.0 + income - expense;
  }
}