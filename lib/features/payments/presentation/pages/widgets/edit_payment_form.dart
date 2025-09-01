// widgets/edit_payment_form.dart
import 'package:flutter/material.dart';
import '../controllers/edit_payment_controller.dart';
import 'edit_payment_header.dart';
import 'edit_payment_type_selector.dart';
import 'edit_payment_form_fields.dart';
import 'edit_payment_submit_button.dart';

class EditPaymentForm extends StatelessWidget {
  final EditPaymentController controller;
  final VoidCallback onSubmit;

  const EditPaymentForm({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditPaymentHeader(controller: controller),
            const SizedBox(height: 32),
            EditPaymentTypeSelector(controller: controller),
            const SizedBox(height: 24),
            EditPaymentFormFields(controller: controller),
            const SizedBox(height: 32),
            EditPaymentSubmitButton(
              controller: controller,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}