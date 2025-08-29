import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required double totalIncome,
    required double totalExpense,
    required double netBalance,
    required int totalPayments,
    required int pendingPayments,
    required int completedPayments,
    required int failedPayments,
    required String period,
  }) : super(
          totalIncome: totalIncome,
          totalExpense: totalExpense,
          netBalance: netBalance,
          totalPayments: totalPayments,
          pendingPayments: pendingPayments,
          completedPayments: completedPayments,
          failedPayments: failedPayments,
          period: period,
        );

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      netBalance: (json['net_balance'] ?? 0).toDouble(),
      totalPayments: json['total_payments'] ?? 0,
      pendingPayments: json['pending_payments'] ?? 0,
      completedPayments: json['completed_payments'] ?? 0,
      failedPayments: json['failed_payments'] ?? 0,
      period: json['period'] ?? 'month',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_balance': netBalance,
      'total_payments': totalPayments,
      'pending_payments': pendingPayments,
      'completed_payments': completedPayments,
      'failed_payments': failedPayments,
      'period': period,
    };
  }

  factory DashboardStatsModel.fromEntity(DashboardStats stats) {
    return DashboardStatsModel(
      totalIncome: stats.totalIncome,
      totalExpense: stats.totalExpense,
      netBalance: stats.netBalance,
      totalPayments: stats.totalPayments,
      pendingPayments: stats.pendingPayments,
      completedPayments: stats.completedPayments,
      failedPayments: stats.failedPayments,
      period: stats.period,
    );
  }
}