import 'package:flutter/material.dart';

class PaymentErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PaymentErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Erreur'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildErrorIcon(),
              const SizedBox(height: 24),
              _buildErrorTitle(context),
              const SizedBox(height: 12),
              _buildErrorMessage(context),
              const SizedBox(height: 24),
              _buildRetryButton(context),
            ],
          ),
        ),
      ),
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
      'Oops ! Une erreur est survenue',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
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

  Widget _buildRetryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRetry,
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