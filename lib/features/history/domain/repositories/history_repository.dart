// features/history/domain/repositories/history_repository.dart
import 'package:payment_app/features/history/data/models/history_item.dart';

abstract class HistoryRepository {
  Future<List<HistoryItem>> getHistory();
}