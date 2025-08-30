import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.showAppBar = true});
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: BlocProvider.of<ProfileBloc>(context)..add(LoadProfile()),
      child: Scaffold(
        appBar: showAppBar ? AppBar(title: const Text('Profil utilisateur')) : null,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Nom: ${state.profile.username}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Email: ${state.profile.email}', style: Theme.of(context).textTheme.titleMedium),
                ],
              );
            } else if (state is ProfileError) {
              return Center(child: Text('Erreur: ${state.message}'));
            }
            return const Center(child: Text('Aucune information.'));
          },
        ),
      ),
    );
  }
}