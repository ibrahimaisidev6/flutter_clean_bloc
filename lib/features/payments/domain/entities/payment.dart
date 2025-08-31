// lib/features/payments/domain/entities/payment.dart
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'payment_enums.dart';

class Payment extends Equatable {
  final int id;
  final int userId; // Ajouté pour correspondre au modèle
  final String title;
  final double amount;
  final String? description;
  final String? category;
  final String reference; // Ajouté pour correspondre au modèle
  final PaymentType type;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt; // Remplace processedAt
  final DateTime? processedAt;
  final File? attachmentFile; // Géré dans le BLoC, pas dans l'entité

  const Payment({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    this.description,
    this.category,
    required this.reference,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.processedAt,
    this.attachmentFile,
  });

  // Getters ajoutés pour correspondre aux erreurs
  bool get isIncome => type == PaymentType.income;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isPending => status == PaymentStatus.pending;

  Payment copyWith({
    int? id,
    int? userId,
    String? title,
    double? amount,
    String? description,
    String? category,
    String? reference,
    PaymentType? type,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? processedAt,
    File? attachmentFile, 
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      reference: reference ?? this.reference,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processedAt: processedAt ?? this.processedAt,
      attachmentFile: attachmentFile ?? this.attachmentFile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        description,
        category,
        reference,
        type,
        status,
        createdAt,
        updatedAt,
        processedAt,
        attachmentFile,
      ];
}