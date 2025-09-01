import 'package:flutter/material.dart';
import '../../../domain/entities/payment.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';

class PaymentHeroCard extends StatelessWidget {
  final Payment payment;

  const PaymentHeroCard({
    super.key,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            payment.isIncome ? Colors.green[50]! : Colors.red[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (payment.isIncome ? Colors.green : Colors.red).withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildIcon(),
          const SizedBox(height: 20),
          _buildTitle(context),
          const SizedBox(height: 12),
          _buildAmount(),
          const SizedBox(height: 16),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            payment.isIncome ? Colors.green : Colors.red,
            (payment.isIncome ? Colors.green : Colors.red).withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (payment.isIncome ? Colors.green : Colors.red)
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        payment.isIncome ? Icons.trending_up : Icons.trending_down,
        color: Colors.white,
        size: 40,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      payment.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAmount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            payment.isIncome ? Colors.green : Colors.red,
            (payment.isIncome ? Colors.green : Colors.red).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${payment.isIncome ? '+' : '-'}${payment.amount.toStringAsFixed(2)} F CFA',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor(payment.status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            payment.status.displayName,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }
}