// utils/payment_utils.dart
import 'package:flutter/material.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';

class PaymentUtils {
  static String getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Complété';
      case PaymentStatus.failed:
        return 'Échoué';
    }
  }

  static String getTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.income:
        return 'Revenus';
      case PaymentType.expense:
        return 'Dépenses';
    }
  }

  static Color getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  static Color getTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.income:
        return Colors.green;
      case PaymentType.expense:
        return Colors.red;
    }
  }

  static IconData getTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.income:
        return Icons.trending_up;
      case PaymentType.expense:
        return Icons.trending_down;
    }
  }

  static String formatAmount(double amount, {bool showSign = false}) {
    final formattedAmount = amount.toStringAsFixed(2);
    if (!showSign) return '$formattedAmount F CFA';
    
    final sign = amount >= 0 ? '+' : '-';
    return '$sign${formattedAmount.replaceFirst('-', '')} F CFA';
  }

  static String formatAmountWithType(double amount, PaymentType type) {
    final sign = type == PaymentType.income ? '+' : '-';
    return '$sign${amount.toStringAsFixed(2)} F CFA';
  }
}