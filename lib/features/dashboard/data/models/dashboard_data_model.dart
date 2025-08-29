import '../../domain/entities/dashboard_data.dart';
import '../../../payments/data/models/payment_model.dart';
import 'dashboard_stats_model.dart';
import 'chart_data_point_model.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required DashboardStatsModel stats,
    required List<PaymentModel> recentPayments,
    required List<ChartDataPointModel> monthlyChart,
  }) : super(
          stats: stats,
          recentPayments: recentPayments,
          monthlyChart: monthlyChart,
        );

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      stats: DashboardStatsModel.fromJson(json['stats'] ?? {}),
      recentPayments: (json['recent_payments'] as List<dynamic>? ?? [])
          .map((payment) => PaymentModel.fromJson(payment))
          .toList(),
      monthlyChart: (json['monthly_chart'] as List<dynamic>? ?? [])
          .map((point) => ChartDataPointModel.fromJson(point))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stats': (stats as DashboardStatsModel).toJson(),
      'recent_payments': recentPayments
          .map((payment) => (payment as PaymentModel).toJson())
          .toList(),
      'monthly_chart': monthlyChart
          .map((point) => (point as ChartDataPointModel).toJson())
          .toList(),
    };
  }

  factory DashboardDataModel.fromEntity(DashboardData data) {
    return DashboardDataModel(
      stats: DashboardStatsModel.fromEntity(data.stats),
      recentPayments: data.recentPayments
          .map((payment) => PaymentModel.fromEntity(payment))
          .toList(),
      monthlyChart: data.monthlyChart
          .map((point) => ChartDataPointModel.fromEntity(point))
          .toList(),
    );
  }
}