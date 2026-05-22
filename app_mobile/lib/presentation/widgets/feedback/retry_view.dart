import 'package:flutter/material.dart';

import 'error_view.dart';

class RetryView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const RetryView({
    super.key,
    this.title = 'Chargement impossible',
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Réessayer',
  });

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      title: title,
      message: message,
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: Icons.refresh_rounded,
    );
  }
}
