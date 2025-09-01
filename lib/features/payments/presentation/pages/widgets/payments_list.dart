// widgets/payments_list.dart
import 'package:flutter/material.dart';
import 'package:payment_app/features/payments/domain/entities/payment.dart';
import '../controllers/payments_controller.dart';
import 'payment_card.dart';

class PaymentsList extends StatelessWidget {
  final PaymentsController controller;
  final List<Payment> payments;
  final bool hasReachedMax;

  const PaymentsList({
    super.key,
    required this.controller,
    required this.payments,
    required this.hasReachedMax,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= payments.length) {
              return const _LoadMoreIndicator();
            }

            final payment = payments[index];
            return SlideTransition(
              position: controller.listAnimationValue,
              child: PaymentCard(
                payment: payment,
                index: index,
                onTap: () => _navigateToPaymentDetail(context, payment.id.toString()),
              ),
            );
          },
          childCount: hasReachedMax ? payments.length : payments.length + 1,
        ),
      ),
    );
  }

  void _navigateToPaymentDetail(BuildContext context, String paymentId) {
    Navigator.pushNamed(
      context,
      '/payment-detail',
      arguments: paymentId,
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class PaymentStatsWidget extends StatelessWidget {
  final List<Payment> payments;

  const PaymentStatsWidget({super.key, required this.payments});

  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    double totalIncome = 0;
    double totalExpense = 0;

    for (final payment in payments) {
      if (payment.isIncome) {
        totalIncome += payment.amount;
      } else {
        totalExpense += payment.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Solde actuel',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(2)} F CFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Revenus',
                  amount: totalIncome,
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Dépenses',
                  amount: totalExpense,
                  color: Colors.red,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${amount.toStringAsFixed(2)} F CFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}