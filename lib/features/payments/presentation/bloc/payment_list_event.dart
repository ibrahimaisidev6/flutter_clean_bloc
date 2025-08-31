// lib/features/payments/presentation/bloc/payment_list_event.dart
import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_enums.dart';

abstract class PaymentListEvent extends Equatable {
  const PaymentListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentListEvent {
  final int page;
  final int perPage;
  final PaymentStatus? status; // Changé en enum
  final PaymentType? type; // Changé en enum
  final DateTime? startDate;
  final DateTime? endDate;
  final File? attachmentFile;

  const LoadPayments({
    this.page = 1,
    this.perPage = 15,
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.attachmentFile,
  });

  @override
  List<Object?> get props => [page, perPage, status, type, startDate, endDate, attachmentFile];
}

class RefreshPayments extends PaymentListEvent {
  final PaymentStatus? status; // Changé en enum
  final PaymentType? type; // Changé en enum
  final DateTime? startDate;
  final DateTime? endDate;

  const RefreshPayments({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, type, startDate, endDate];
}

class FilterPayments extends PaymentListEvent {
  final PaymentStatus? status; // Changé en enum
  final PaymentType? type; // Changé en enum
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterPayments({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, type, startDate, endDate];
}

class LoadMorePayments extends PaymentListEvent {
  const LoadMorePayments();
}

class ClearFilters extends PaymentListEvent {
  const ClearFilters();
}