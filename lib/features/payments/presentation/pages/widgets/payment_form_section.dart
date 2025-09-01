import 'dart:io';
import 'package:flutter/material.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import 'payment_title_field.dart';
import 'payment_description_field.dart';
import 'payment_amount_field.dart';
import 'payment_category_field.dart';
import 'payment_reference_field.dart';
import 'payment_attachment_section.dart';

class PaymentFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final TextEditingController categoryController;
  final TextEditingController referenceController;
  final PaymentType selectedType;
  final List<String> categories;
  final File? attachmentFile;
  final String? attachmentFileName;
  final Function(String) onCategorySelected;
  final Function(File?, String?) onAttachmentChanged;

  const PaymentFormSection({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    required this.categoryController,
    required this.referenceController,
    required this.selectedType,
    required this.categories,
    required this.attachmentFile,
    required this.attachmentFileName,
    required this.onCategorySelected,
    required this.onAttachmentChanged,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildHeader(context),
          const SizedBox(height: 24),
          PaymentTitleField(controller: titleController),
          const SizedBox(height: 20),
          PaymentDescriptionField(controller: descriptionController),
          const SizedBox(height: 20),
          PaymentAmountField(
            controller: amountController,
            selectedType: selectedType,
          ),
          const SizedBox(height: 20),
          PaymentCategoryField(
            controller: categoryController,
            categories: categories,
            onCategorySelected: onCategorySelected,
          ),
          const SizedBox(height: 20),
          PaymentReferenceField(controller: referenceController),
          const SizedBox(height: 24),
          PaymentAttachmentSection(
            attachmentFile: attachmentFile,
            attachmentFileName: attachmentFileName,
            onAttachmentChanged: onAttachmentChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
}