// features/history/domain/usecases/get_history_usecase.dart
import 'package:payment_app/features/history/data/models/history_item.dart';

import '../repositories/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<List<HistoryItem>> call() {
    return repository.getHistory();
  }
}
