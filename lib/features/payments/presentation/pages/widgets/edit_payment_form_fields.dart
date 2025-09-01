// widgets/edit_payment_form_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../controllers/edit_payment_controller.dart';
import 'form_field_widgets.dart';

class EditPaymentFormFields extends StatelessWidget {
  final EditPaymentController controller;

  const EditPaymentFormFields({super.key, required this.controller});

  static const List<String> categories = [
    'Alimentation',
    'Transport',
    'Logement',
    'Santé',
    'Loisirs',
    'Shopping',
    'Éducation',
    'Services',
    'Salaire',
    'Freelance',
    'Investissement',
    'Autres',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context),
              const SizedBox(height: 24),
              _buildTitleField(context),
              const SizedBox(height: 20),
              _buildDescriptionField(context),
              const SizedBox(height: 20),
              _buildAmountField(context),
              const SizedBox(height: 20),
              _buildCategoryField(context),
              const SizedBox(height: 20),
              _buildReferenceField(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.edit_document,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          'Informations du paiement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return ModernTextField(
      controller: controller.titleController,
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

  Widget _buildDescriptionField(BuildContext context) {
    return ModernTextField(
      controller: controller.descriptionController,
      label: 'Description',
      hint: 'Description détaillée (optionnel)',
      icon: Icons.description,
      maxLines: 3,
      isOptional: true,
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return AmountField(
      controller: controller.amountController,
      paymentType: controller.selectedType,
    );
  }

  Widget _buildCategoryField(BuildContext context) {
    return CategoryField(
      controller: controller.categoryController,
      categories: categories,
      onCategorySelected: controller.setCategory,
    );
  }

  Widget _buildReferenceField(BuildContext context) {
    return ModernTextField(
      controller: controller.referenceController,
      label: 'Référence',
      hint: 'Référence du paiement (optionnel)',
      icon: Icons.receipt_long,
      isOptional: true,
    );
  }
}