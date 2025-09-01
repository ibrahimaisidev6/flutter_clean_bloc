import 'package:flutter/material.dart';
import '../../../domain/entities/payment.dart';

class PaymentAppBar extends StatelessWidget {
  final Payment payment;

  const PaymentAppBar({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              payment.isIncome ? Colors.green : Colors.red,
              (payment.isIncome ? Colors.green : Colors.red).withOpacity(0.8),
            ],
          ),
        ),
        child: const FlexibleSpaceBar(
          title: Text(
            'Détails du paiement',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
      ),
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }
}