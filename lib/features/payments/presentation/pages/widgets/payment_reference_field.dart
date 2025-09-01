import 'package:flutter/material.dart';
import 'modern_text_field.dart';

class PaymentReferenceField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentReferenceField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: controller,
      label: 'Référence',
      hint: 'Référence du paiement (optionnel)',
      icon: Icons.receipt_long,
      isOptional: true,
    );
  }
}