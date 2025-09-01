// edit_payment_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../../../../injection_container.dart';
import '../bloc/bloc.dart';
import './widgets/edit_payment_view.dart';

class EditPaymentPage extends StatelessWidget {
  final Payment payment;

  const EditPaymentPage({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<PaymentBloc>(),
      child: EditPaymentView(payment: payment),
    );
  }
}