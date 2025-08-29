import '../../domain/entities/dashboard_data.dart';

class ChartDataPointModel extends ChartDataPoint {
  const ChartDataPointModel({
    required String month,
    required double income,
    required double expense,
  }) : super(
          month: month,
          income: income,
          expense: expense,
        );

  factory ChartDataPointModel.fromJson(Map<String, dynamic> json) {
    return ChartDataPointModel(
      month: json['month'] ?? '',
      income: (json['income'] ?? 0).toDouble(),
      expense: (json['expense'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'income': income,
      'expense': expense,
    };
  }

  factory ChartDataPointModel.fromEntity(ChartDataPoint point) {
    return ChartDataPointModel(
      month: point.month,
      income: point.income,
      expense: point.expense,
    );
  }
}