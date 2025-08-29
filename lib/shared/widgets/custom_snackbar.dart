import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final colors = _getColors(context, type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: colors.backgroundColor,
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.iconBackgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: colors.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: colors.actionColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        action: onAction != null && actionLabel != null
            ? null
            : SnackBarAction(
                label: 'OK',
                textColor: colors.actionColor,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static _SnackBarColors _getColors(BuildContext context, SnackBarType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (type) {
      case SnackBarType.success:
        return _SnackBarColors(
          backgroundColor: isDark ? Colors.green[800]! : Colors.green[600]!,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withOpacity(0.2),
          actionColor: Colors.white,
        );
      case SnackBarType.error:
        return _SnackBarColors(
          backgroundColor: isDark ? Colors.red[800]! : Colors.red[600]!,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withOpacity(0.2),
          actionColor: Colors.white,
        );
      case SnackBarType.warning:
        return _SnackBarColors(
          backgroundColor: isDark ? Colors.orange[800]! : Colors.orange[600]!,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withOpacity(0.2),
          actionColor: Colors.white,
        );
      case SnackBarType.info:
        return _SnackBarColors(
          backgroundColor: isDark ? Colors.blue[800]! : Colors.blue[600]!,
          textColor: Colors.white,
          iconColor: Colors.white,
          iconBackgroundColor: Colors.white.withOpacity(0.2),
          actionColor: Colors.white,
        );
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class _SnackBarColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color actionColor;

  _SnackBarColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.actionColor,
  });
}