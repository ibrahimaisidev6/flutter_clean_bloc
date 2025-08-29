import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/dashboard_data_model.dart';

abstract class DashboardRemoteDataSource {
  /// Get dashboard statistics and data from API
  /// Throws [ServerException] for server errors
  Future<DashboardDataModel> getDashboardStats({String period = 'month'});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final DioClient dioClient;

  DashboardRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DashboardDataModel> getDashboardStats({String period = 'month'}) async {
    try {
      final response = await dioClient.get('/dashboard/stats', queryParameters: {
        'period': period,
      });

      if (response.statusCode == 200) {
        return DashboardDataModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get dashboard stats',
          response.statusCode?.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException(
        'Failed to connect to server: ${e.toString()}',
        '500',
      );
    }
  }
}