import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';

class PaymentAmountField extends StatelessWidget {
  final TextEditingController controller;
  final PaymentType selectedType;

  const PaymentAmountField({
    super.key,
    required this.controller,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    final color = selectedType == PaymentType.income ? Colors.green : Colors.red;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context),
        const SizedBox(height: 8),
        _buildAmountField(context, color),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Text(
      'Montant',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
    );
  }

  Widget _buildAmountField(BuildContext context, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          hintText: '0.00',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.euro,
              color: Colors.white,
              size: 20,
            ),
          ),
          suffixText: 'F CFA',
          suffixStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: color, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        validator: _validateAmount,
      ),
    );
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer un montant';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Veuillez entrer un montant valide';
    }
    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }
    if (amount > 1000000) {
      return 'Le montant ne peut pas dépasser 1 000 000 F CFA';
    }
    return null;
  }
}