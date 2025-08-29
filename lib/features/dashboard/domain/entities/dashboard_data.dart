import 'package:equatable/equatable.dart';

import 'dashboard_stats.dart';
import '../../../payments/domain/entities/payment.dart';

class DashboardData extends Equatable {
  final DashboardStats stats;
  final List<Payment> recentPayments;
  final List<ChartDataPoint> monthlyChart;

  const DashboardData({
    required this.stats,
    required this.recentPayments,
    required this.monthlyChart,
  });

  @override
  List<Object?> get props => [stats, recentPayments, monthlyChart];

  @override
  String toString() {
    return 'DashboardData{'
        'stats: $stats, '
        'recentPayments: ${recentPayments.length} items, '
        'monthlyChart: ${monthlyChart.length} points'
        '}';
  }
}

class ChartDataPoint extends Equatable {
  final String month;
  final double income;
  final double expense;

  const ChartDataPoint({
    required this.month,
    required this.income,
    required this.expense,
  });

  @override
  List<Object?> get props => [month, income, expense];

  @override
  String toString() {
    return 'ChartDataPoint{month: $month, income: $income, expense: $expense}';
  }
}