import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'stats_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  final dynamic stats;

  const DashboardStatsGrid({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildIncomeCard(),
          _buildExpenseCard(),
          _buildBalanceCard(),
          _buildPendingCard(),
        ],
      ),
    );
  }

  Widget _buildIncomeCard() {
    return StatsCard(
      title: 'Revenus totaux',
      value: NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'F CFA',
        decimalDigits: 0,
      ).format(stats.totalIncome),
      icon: Icons.trending_up,
      color: Colors.green,
      subtitle: '+${stats.completedPayments} paiements',
    );
  }

  Widget _buildExpenseCard() {
    return StatsCard(
      title: 'Dépenses totales',
      value: NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'F CFA',
        decimalDigits: 0,
      ).format(stats.totalExpense),
      icon: Icons.trending_down,
      color: Colors.red,
      subtitle: '${stats.totalPayments} paiements',
    );
  }

  Widget _buildBalanceCard() {
    return StatsCard(
      title: 'Balance nette',
      value: NumberFormat.currency(
        locale: 'fr_FR',
        symbol: 'F CFA',
        decimalDigits: 0,
      ).format(stats.netBalance),
      icon: stats.netBalance >= 0
          ? Icons.account_balance_wallet
          : Icons.warning,
      color: stats.netBalance >= 0 ? Colors.blue : Colors.orange,
      subtitle: stats.period,
    );
  }

  Widget _buildPendingCard() {
    return StatsCard(
      title: 'En attente',
      value: '${stats.pendingPayments}',
      icon: Icons.schedule,
      color: Colors.orange,
      subtitle: '${stats.failedPayments} échecs',
    );
  }
}