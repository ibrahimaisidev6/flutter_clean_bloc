// features/history/data/datasources/history_remote_data_source.dart
import 'package:payment_app/core/network/dio_client.dart';
import 'package:payment_app/features/history/data/models/history_item.dart';

abstract class HistoryRemoteDataSource {
  Future<List<HistoryItem>> getHistory();
}

class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final DioClient dioClient;

  HistoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<HistoryItem>> getHistory() async {
    try {
      final response = await dioClient.get('/history');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => HistoryItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch history from server: $e');
    }
  }
}