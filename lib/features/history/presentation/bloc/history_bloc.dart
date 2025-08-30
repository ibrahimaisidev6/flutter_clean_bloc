// features/history/presentation/bloc/history_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_app/features/history/data/models/history_item.dart';
import 'package:payment_app/features/history/presentation/bloc/history_event.dart';
import 'package:payment_app/features/history/presentation/bloc/history_state.dart';
import '../../domain/usecases/get_history_usecase.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUseCase getHistoryUseCase;

  HistoryBloc({required this.getHistoryUseCase}) : super(HistoryInitial()) {
    on<LoadHistory>((event, emit) async {
      emit(HistoryLoading());
      try {
        final items = await getHistoryUseCase();
        emit(HistoryLoaded(items.cast<HistoryItem>()));
      } catch (e) {
        emit(HistoryError(e.toString()));
      }
    });
  }
}
