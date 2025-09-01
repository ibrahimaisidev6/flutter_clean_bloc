import 'package:flutter/material.dart';
import 'stats_card.dart';
import 'recent_payments_card.dart';
import 'monthly_chart_card.dart';
import 'dashboard_welcome_header.dart';
import 'dashboard_stats_grid.dart';

class DashboardContent extends StatelessWidget {
  final dynamic data;
  final String selectedPeriod;
  final Map<String, String> periodLabels;

  const DashboardContent({
    super.key,
    required this.data,
    required this.selectedPeriod,
    required this.periodLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        DashboardWelcomeHeader(
          selectedPeriod: selectedPeriod,
          periodLabels: periodLabels,
        ),
        const SizedBox(height: 24),
        DashboardStatsGrid(stats: data.stats),
        const SizedBox(height: 24),
        MonthlyChartCard(chartData: data.monthlyChart),
        const SizedBox(height: 24),
        RecentPaymentsCard(
          payments: data.recentPayments,
          onSeeAll: () {
            // TODO: Navigate to payments page
          },
          onViewAll: () {
            // TODO: Navigate to all payments page
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}