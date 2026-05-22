import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/utils/snackbars.dart';
import '../../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Aucun utilisateur connecté',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.15),
                                child: Text(
                                  user.nom.isNotEmpty
                                      ? user.nom[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nom,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        user.role.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Informations du compte',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _ProfileInfoTile(
                                label: 'Identifiant',
                                value: user.id.toString(),
                                icon: Icons.badge_outlined,
                              ),
                              _ProfileInfoTile(
                                label: 'Nom',
                                value: user.nom,
                                icon: Icons.person_outline_rounded,
                              ),
                              _ProfileInfoTile(
                                label: 'Email',
                                value: user.email,
                                icon: Icons.email_outlined,
                              ),
                              _ProfileInfoTile(
                                label: 'Rôle',
                                value: user.role,
                                icon: Icons.admin_panel_settings_outlined,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AppSnackbars.info(
                                  context,
                                  'Modification du profil bientôt disponible',
                                );
                              },
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Modifier'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await context.read<AuthProvider>().logout();

                                if (context.mounted) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    RouteNames.login,
                                    (_) => false,
                                  );
                                }
                              },
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Déconnexion'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileInfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
