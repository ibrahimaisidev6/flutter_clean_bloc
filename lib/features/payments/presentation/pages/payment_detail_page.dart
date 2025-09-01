import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/payment.dart';
import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import 'widgets/payment_hero_card.dart';
import 'widgets/payment_details_card.dart';
import 'widgets/payment_action_buttons.dart';
import 'widgets/payment_app_bar.dart';
import 'widgets/payment_loading_state.dart';
import 'widgets/payment_error_state.dart';
import 'widgets/payment_dialogs.dart';
import 'edit_payment_page.dart';

class PaymentDetailPage extends StatelessWidget {
  final String paymentId;

  const PaymentDetailPage({
    super.key,
    required this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<PaymentBloc>()..add(LoadPaymentDetail(int.parse(paymentId))),
      child: PaymentDetailView(paymentId: paymentId),
    );
  }
}

class PaymentDetailView extends StatefulWidget {
  final String paymentId;

  const PaymentDetailView({
    super.key,
    required this.paymentId,
  });

  @override
  State<PaymentDetailView> createState() => _PaymentDetailViewState();
}

class _PaymentDetailViewState extends State<PaymentDetailView>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _detailsController;
  late AnimationController _actionsController;
  late Animation<double> _heroAnimation;
  late Animation<Offset> _detailsAnimation;
  late Animation<double> _actionsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _actionsController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.elasticOut,
    ));

    _detailsAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _detailsController,
      curve: Curves.easeOutCubic,
    ));

    _actionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionsController,
      curve: Curves.easeInOut,
    ));

    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    _heroController.forward().then((_) {
      _detailsController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _actionsController.forward();
      });
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _detailsController.dispose();
    _actionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const PaymentLoadingState();
          }

          if (state is PaymentError && state.currentPayment == null) {
            return PaymentErrorState(
              message: state.message,
              onRetry: () => _reloadPayment(),
            );
          }

          final payment = _getPaymentFromState(state);
          if (payment == null) {
            return const PaymentNotFoundState();
          }

          return _buildPaymentContent(payment);
        },
      ),
    );
  }

  Widget _buildPaymentContent(Payment payment) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        PaymentAppBar(payment: payment),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ScaleTransition(
                scale: _heroAnimation,
                child: PaymentHeroCard(payment: payment),
              ),
              SlideTransition(
                position: _detailsAnimation,
                child: PaymentDetailsCard(payment: payment),
              ),
              FadeTransition(
                opacity: _actionsAnimation,
                child: PaymentActionButtons(
                  payment: payment,
                  onProcess: () => _processPayment(payment.id.toString()),
                  onEdit: () => _editPayment(payment),
                  onDelete: () => _showDeleteConfirmation(payment.id.toString()),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, PaymentState state) {
    if (state is PaymentDeleted) {
      _showSuccessMessage('Paiement supprimé avec succès');
      Navigator.of(context).pop();
    } else if (state is PaymentProcessed) {
      _showSuccessMessage('Paiement traité avec succès');
      _reloadPayment();
    } else if (state is PaymentError) {
      _showErrorMessage(state.message);
    }
  }

  void _showSuccessMessage(String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _processPayment(String paymentId) {
    PaymentDialogs.showProcessConfirmation(
      context,
      onConfirm: () {
        context.read<PaymentBloc>().add(ProcessPayment(int.parse(paymentId)));
      },
    );
  }

  void _editPayment(Payment payment) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditPaymentPage(payment: payment),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
      ),
    ).then((updated) {
      if (updated == true) {
        _reloadPayment();
      }
    });
  }

  void _showDeleteConfirmation(String paymentId) {
    PaymentDialogs.showDeleteConfirmation(
      context,
      onConfirm: () {
        context.read<PaymentBloc>().add(DeletePayment(int.parse(paymentId)));
      },
    );
  }

  void _reloadPayment() {
    context.read<PaymentBloc>().add(LoadPaymentDetail(int.parse(widget.paymentId)));
  }

  Payment? _getPaymentFromState(PaymentState state) {
    if (state is PaymentLoaded) return state.payment;
    if (state is PaymentError) return state.currentPayment;
    return null;
  }
}

class PaymentNotFoundState extends StatelessWidget {
  const PaymentNotFoundState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Paiement introuvable'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Aucun paiement trouvé'),
      ),
    );
  }
}