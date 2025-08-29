import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int totalPayments;
  final int pendingPayments;
  final int completedPayments;
  final int failedPayments;
  final String period;

  const DashboardStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.totalPayments,
    required this.pendingPayments,
    required this.completedPayments,
    required this.failedPayments,
    required this.period,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netBalance,
        totalPayments,
        pendingPayments,
        completedPayments,
        failedPayments,
        period,
      ];

  @override
  String toString() {
    return 'DashboardStats{'
        'totalIncome: $totalIncome, '
        'totalExpense: $totalExpense, '
        'netBalance: $netBalance, '
        'totalPayments: $totalPayments, '
        'period: $period'
        '}';
  }
}