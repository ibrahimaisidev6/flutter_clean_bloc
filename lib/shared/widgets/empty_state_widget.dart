import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              decoration: BoxDecoration(
                color: (iconColor ?? AppConstants.primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.paddingLarge),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppConstants.paddingLarge),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoPaymentsWidget extends StatelessWidget {
  final VoidCallback? onCreatePayment;

  const NoPaymentsWidget({
    super.key,
    this.onCreatePayment,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.payment,
      title: 'Aucun paiement',
      message: 'Vous n\'avez encore effectué aucun paiement.\nCommencez dès maintenant !',
      buttonText: 'Créer un paiement',
      onButtonPressed: onCreatePayment,
      iconColor: AppConstants.primaryColor,
    );
  }
}

class NoSearchResultsWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const NoSearchResultsWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      message: 'Aucun résultat trouvé pour "$searchQuery".\nEssayez avec d\'autres mots-clés.',
      buttonText: onClearSearch != null ? 'Effacer la recherche' : null,
      onButtonPressed: onClearSearch,
      iconColor: Colors.orange,
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Une erreur est survenue',
    required this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: icon ?? Icons.error_outline,
      title: title,
      message: message,
      buttonText: onRetry != null ? 'Réessayer' : null,
      onButtonPressed: onRetry,
      iconColor: AppConstants.errorColor,
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'Pas de connexion Internet',
      message: 'Vérifiez votre connexion Internet et réessayez.',
      onRetry: onRetry,
    );
  }
}