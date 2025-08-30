// features/history/data/repositories/history_repository_impl.dart
import 'package:payment_app/core/network/network_info.dart';
import 'package:payment_app/features/history/data/datasources/history_remote_data_source.dart';
import 'package:payment_app/features/history/data/models/history_item.dart';
import 'package:payment_app/features/history/domain/repositories/history_repository.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<HistoryItem>> getHistory() async {
    if (await networkInfo.isConnected) {
      try {
        final historyList = await remoteDataSource.getHistory();
        return historyList;
      } catch (e) {
        throw Exception('Failed to fetch history: $e');
      }
    } else {
      throw Exception('No internet connection');
    }
  }
}