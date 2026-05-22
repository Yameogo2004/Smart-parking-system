import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Alerte critique',
        'message': 'Un capteur au niveau 2 ne répond plus.',
        'time': 'Il y a 5 min',
        'color': AppColors.danger,
        'icon': Icons.warning_amber_rounded,
      },
      {
        'title': 'Paiement confirmé',
        'message': 'Un paiement de 25 DH a été validé.',
        'time': 'Il y a 20 min',
        'color': AppColors.success,
        'icon': Icons.payments_rounded,
      },
      {
        'title': 'Nouveau stationnement',
        'message': 'Le véhicule AB-123-CD est entré au parking.',
        'time': 'Il y a 1 h',
        'color': AppColors.info,
        'icon': Icons.local_parking_rounded,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = notifications[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              leading: CircleAvatar(
                backgroundColor:
                    (item['color'] as Color).withValues(alpha: 0.15),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                ),
              ),
              title: Text(
                item['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(item['message'] as String),
              ),
              trailing: Text(
                item['time'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
