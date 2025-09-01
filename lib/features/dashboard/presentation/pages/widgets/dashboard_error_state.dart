import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/constants/app_constants.dart';

class DashboardErrorState extends StatelessWidget {
  final String message;
  final bool showAppBar;
  final VoidCallback onRetry;

  const DashboardErrorState({
    super.key,
    required this.message,
    required this.showAppBar,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (showAppBar)
          const SliverAppBar(
            title: Text('Erreur'),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        SliverFillRemaining(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: _buildContainerDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildErrorIcon(),
                  const SizedBox(height: 24),
                  _buildErrorTitle(context),
                  const SizedBox(height: 12),
                  _buildErrorMessage(context),
                  const SizedBox(height: 24),
                  _buildRetryButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.error_outline,
        size: 48,
        color: Colors.red[400],
      ),
    );
  }

  Widget _buildErrorTitle(BuildContext context) {
    return Text(
      'Erreur de chargement',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey[600],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onRetry();
          },
          borderRadius: BorderRadius.circular(12),
          child: const Center(
            child: Text(
              'Réessayer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}