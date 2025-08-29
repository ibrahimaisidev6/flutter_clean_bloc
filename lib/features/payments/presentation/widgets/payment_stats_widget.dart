import 'package:flutter/material.dart';
import '../../domain/entities/payment.dart';
import 'package:payment_app/features/payments/domain/entities/payment_enums.dart';

class PaymentStatsWidget extends StatelessWidget {
  final List<Payment> payments;

  const PaymentStatsWidget({
    super.key,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé des paiements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Total',
                      '${payments.length}',
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Revenus',
                      '+${stats.totalIncome.toStringAsFixed(2)} €',
                      Icons.arrow_upward,
                      Colors.green,
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Dépenses',
                      '-${stats.totalExpense.toStringAsFixed(2)} €',
                      Icons.arrow_downward,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Solde',
                      '${stats.balance >= 0 ? '+' : ''}${stats.balance.toStringAsFixed(2)} €',
                      Icons.account_balance_wallet,
                      stats.balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'En attente',
                      '${stats.pendingCount}',
                      Icons.schedule,
                      Colors.orange,
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Complétés',
                      '${stats.completedCount}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  PaymentStats _calculateStats() {
    double totalIncome = 0;
    double totalExpense = 0;
    int pendingCount = 0;
    int completedCount = 0;
    int failedCount = 0;

    for (final payment in payments) {
      if (payment.isIncome) {
        totalIncome += payment.amount;
      } else {
        totalExpense += payment.amount;
      }

      switch (payment.status) {
        case PaymentStatus.pending:
          pendingCount++;
          break;
        case PaymentStatus.completed:
          completedCount++;
          break;
        case PaymentStatus.failed:
          failedCount++;
          break;
      }
    }

    return PaymentStats(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      pendingCount: pendingCount,
      completedCount: completedCount,
      failedCount: failedCount,
    );
  }
}

class PaymentStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int pendingCount;
  final int completedCount;
  final int failedCount;

  PaymentStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.pendingCount,
    required this.completedCount,
    required this.failedCount,
  });
}