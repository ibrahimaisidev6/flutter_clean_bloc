import 'package:flutter/material.dart';
import 'modern_text_field.dart';

class PaymentTitleField extends StatelessWidget {
  final TextEditingController controller;

  const PaymentTitleField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ModernTextField(
      controller: controller,
      label: 'Titre',
      hint: 'Ex: Courses alimentaires, Salaire mensuel...',
      icon: Icons.title,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Veuillez entrer un titre';
        }
        if (value.trim().length < 3) {
          return 'Le titre doit contenir au moins 3 caractères';
        }
        return null;
      },
    );
  }
}