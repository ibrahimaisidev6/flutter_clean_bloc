import 'dart:io';

import '../../domain/entities/payment.dart';
import '../../domain/entities/payment_enums.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required int id,
    required int userId,
    required String title,
    required double amount,
    String? description,
    String? category,
    required String reference,
    required PaymentType type,
    required PaymentStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? processedAt,
    File? attachmentFile,
  }) : super(
          id: id,
          userId: userId,
          title: title,
          amount: amount,
          description: description,
          category: category,
          reference: reference,
          type: type,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
          processedAt: processedAt,
          attachmentFile: attachmentFile,
        );

  // ✅ CORRECTION : Utiliser 'description' comme 'title' car le mock n'a pas de champ 'title'
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      title: json['description'] ?? '', // Utiliser description comme titre
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      category: json['category'],
      reference: json['reference'] ?? '',
      type: _parsePaymentType(json['type']),
      status: _parsePaymentStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      processedAt: json['processed_at'] != null ? DateTime.parse(json['processed_at']) : null,
      attachmentFile: json['attachment_file'] != null ? File(json['attachment_file']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'description': description,
      'category': category,
      'reference': reference,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'attachment_file': attachmentFile?.path,
    };
  }

  factory PaymentModel.fromEntity(Payment payment) {
    return PaymentModel(
      id: payment.id,
      userId: payment.userId,
      title: payment.title,
      amount: payment.amount,
      description: payment.description,
      category: payment.category,
      reference: payment.reference,
      type: payment.type,
      status: payment.status,
      createdAt: payment.createdAt,
      updatedAt: payment.updatedAt,
      processedAt: payment.processedAt,
      attachmentFile: payment.attachmentFile,
    );
  }

  // Méthodes utilitaires pour parser les enums
  static PaymentType _parsePaymentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'income':
        return PaymentType.income;
      case 'expense':
        return PaymentType.expense;
      default:
        return PaymentType.expense;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'completed':
        return PaymentStatus.completed;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}