// lib/features/payments/presentation/bloc/payment_event.dart
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../../domain/entities/payment_enums.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPaymentDetail extends PaymentEvent {
  final int id;

  const LoadPaymentDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class CreatePayment extends PaymentEvent {
  final int userId; // Ajouté
  final String title; // Ajouté
  final double amount;
  final PaymentType type;
  final String? description;
  final String? category;
  final String? reference;
  // Le fichier justificatif sera géré dans le BLoC, pas besoin de le passer ici
  final File? attachmentFile;

  const CreatePayment(Payment payment, {
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.description,
    this.category,
    this.reference,
    this.attachmentFile,
  });

  @override
  List<Object?> get props => [userId, title, amount, type, description, category, reference, attachmentFile];
}

class UpdatePayment extends PaymentEvent {
  final int id;
  final String? title; // Ajouté
  final double? amount;
  final PaymentType? type;
  final PaymentStatus? status;
  final String? description;
  final String? category;
  final String? reference;
  final File? attachmentFile;

  const UpdatePayment(Payment updatedPayment, {
    required this.id,
    this.title,
    this.amount,
    this.type,
    this.status,
    this.description,
    this.category,
    this.reference,
    this.attachmentFile, File? newAttachment,
  });

  @override
  List<Object?> get props => [id, title, amount, type, status, description, category, reference, attachmentFile];
}

class DeletePayment extends PaymentEvent {
  final int id;

  const DeletePayment(this.id);

  @override
  List<Object?> get props => [id];
}

class ProcessPayment extends PaymentEvent {
  final int id;

  const ProcessPayment(this.id);

  @override
  List<Object?> get props => [id];
}

class ResetPaymentState extends PaymentEvent {
  const ResetPaymentState();
}