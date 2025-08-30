import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<HistoryBloc>(context)..add(LoadHistory()),
      child: Scaffold(
        appBar: showAppBar ? AppBar(title: const Text('Historique')) : null,
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryLoaded) {
              return ListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return ListTile(
                    title: Text(item.description),
                    subtitle: Text(item.date.toString()),
                  );
                },
              );
            } else if (state is HistoryError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            return const Center(child: Text('Aucun historique.'));
          },
        ),
      ),
    );
  }
}