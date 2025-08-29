// lib/features/payments/domain/entities/payment_enums.dart
enum PaymentStatus {
  pending,
  completed,
  failed,
}

enum PaymentType {
  income,
  expense,
}

// Extensions utiles pour les enums
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échoué';
    }
  }
}

extension PaymentTypeExtension on PaymentType {
  String get displayName {
    switch (this) {
      case PaymentType.income:
        return 'Revenus';
      case PaymentType.expense:
        return 'Dépenses';
    }
  }
}