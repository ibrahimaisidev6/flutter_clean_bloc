import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_constants.dart';
import '../../../../../../shared/widgets/loading_widget.dart';

class DashboardLoadingState extends StatelessWidget {
  final bool showAppBar;

  const DashboardLoadingState({
    super.key,
    required this.showAppBar,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (showAppBar)
          const SliverAppBar(
            title: Text('Dashboard'),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLoadingContainer(),
                const SizedBox(height: 24),
                _buildLoadingText(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const LoadingWidget(),
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    return Text(
      'Chargement du dashboard...',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.grey[600],
      ),
    );
  }
}