// widgets/edit_payment_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';
import '../../../../../shared/widgets/widgets.dart';
import '../../bloc/bloc.dart';
import 'edit_payment_form.dart';
import 'edit_payment_header.dart';
import '../controllers/edit_payment_controller.dart';

class EditPaymentView extends StatefulWidget {
  final Payment payment;

  const EditPaymentView({super.key, required this.payment});

  @override
  State<EditPaymentView> createState() => _EditPaymentViewState();
}

class _EditPaymentViewState extends State<EditPaymentView>
    with TickerProviderStateMixin {
  late EditPaymentController controller;
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    controller = EditPaymentController(widget.payment);
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: _handleBlocState,
        builder: (context, state) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: EditPaymentForm(
                controller: controller,
                onSubmit: _submitForm,
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Modifier le paiement',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              controller.selectedType == PaymentType.income 
                  ? Colors.green 
                  : Colors.red,
              (controller.selectedType == PaymentType.income
                      ? Colors.green
                      : Colors.red)
                  .withOpacity(0.8),
            ],
          ),
        ),
      ),
      foregroundColor: Colors.white,
      actions: [
        if (controller.hasChanges)
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Text(
                  'Modifié',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _handleBlocState(BuildContext context, PaymentState state) {
    if (state is PaymentUpdated) {
      HapticFeedback.lightImpact();
      CustomSnackBar.showSuccess(
        context,
        message: 'Paiement mis à jour avec succès',
      );
      Navigator.of(context).pop(true);
    } else if (state is PaymentError) {
      HapticFeedback.mediumImpact();
      CustomSnackBar.showError(
        context,
        message: state.message,
      );
    }
  }

  void _submitForm() {
    if (!controller.validate()) {
      HapticFeedback.mediumImpact();
      return;
    }

    HapticFeedback.lightImpact();
    final updatedPayment = controller.createUpdatedPayment();
    
    context
        .read<PaymentBloc>()
        .add(UpdatePayment(updatedPayment, id: widget.payment.id));
  }
}