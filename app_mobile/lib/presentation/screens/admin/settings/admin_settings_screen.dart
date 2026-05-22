import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../widgets/layout/admin_shell.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool notificationsEnabled = true;
  bool autoRefreshEnabled = true;
  bool criticalAlertsOnly = false;
  String selectedAccountMode = 'Administrateur';

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (_) => false,
    );
  }

  Future<void> _showThemeSelector(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    final colors = context.appColors;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t.text('settings.chooseTheme'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SelectionTile(
                  title: 'Dark',
                  subtitle: context.t.text('settings.darkTheme'),
                  selected: themeProvider.isDarkMode,
                  onTap: () {
                    themeProvider.setDarkMode();
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                _SelectionTile(
                  title: 'Light',
                  subtitle: context.t.text('settings.lightTheme'),
                  selected: themeProvider.isLightMode,
                  onTap: () {
                    themeProvider.setLightMode();
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLanguageSelector(BuildContext context) async {
    final languageProvider = context.read<LanguageProvider>();
    final colors = context.appColors;
    final languages = LanguageProvider.labelsByCode.entries.toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: FractionallySizedBox(
            heightFactor: 0.72,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t.text('settings.chooseLanguage'),
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ...languages.map(
                      (language) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SelectionTile(
                          title: language.value,
                          subtitle: context.t.text('settings.displayLanguage'),
                          selected: languageProvider.languageCode == language.key,
                          onTap: () {
                            languageProvider.setByCode(language.key);
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${context.t.text('settings.languageSelected')} : ${language.value}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAccountModeSelector(BuildContext context) async {
    final colors = context.appColors;
    final accountModes = ['Administrateur', 'Client', 'Super administrateur'];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.t.text('settings.chooseAccount'),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.t.text('settings.chooseAccountHelp'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...accountModes.map(
                    (mode) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _SelectionTile(
                        title: mode,
                        subtitle: context.t.text('settings.switchToProfile'),
                        selected: selectedAccountMode == mode,
                        onTap: () async {
                          setState(() => selectedAccountMode = mode);
                          final success = await context
                              .read<AuthProvider>()
                              .switchAccount(mode);

                          if (!mounted) return;
                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? '${context.t.text('settings.activeAccount')} : $mode'
                                    : context.read<AuthProvider>().errorMessage ??
                                        context.t.text('settings.switchFailed'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddAdminDialog(BuildContext context) async {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final emailController = TextEditingController();
    final colors = context.appColors;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          title: Text(
            context.t.text('settings.addAdmin'),
            style: AppTextStyles.sectionTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogTextField(
                  controller: nomController,
                  label: context.t.text('settings.lastName'),
                ),
                const SizedBox(height: AppSpacing.md),
                _DialogTextField(
                  controller: prenomController,
                  label: context.t.text('settings.firstName'),
                ),
                const SizedBox(height: AppSpacing.md),
                _DialogTextField(
                  controller: emailController,
                  label: AppStrings.email,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.t.text('common.cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final nom = nomController.text.trim();
                final prenom = prenomController.text.trim();
                final email = emailController.text.trim();

                if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.t.text('settings.requiredFields')),
                    ),
                  );
                  return;
                }

                final success = await context.read<AuthProvider>().createAdmin(
                      nom: nom,
                      prenom: prenom,
                      email: email,
                    );

                if (!mounted) return;
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? context.t.text('settings.adminCreated')
                          : context.read<AuthProvider>().errorMessage ??
                              context.t.text('settings.adminCreateFailed'),
                    ),
                  ),
                );
              },
              child: Text(context.t.text('common.save')),
            ),
          ],
        );
      },
    );

    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
  }

  Future<void> _showSecurityDialog(BuildContext context) async {
    final colors = context.appColors;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          title: Text(
            context.t.text('settings.securityTitle'),
            style: AppTextStyles.sectionTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          content: Text(
            context.t.text('settings.securityBody'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.t.text('common.close')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final colors = context.appColors;

    final currentName = authProvider.user?.nom ?? context.t.text('settings.profileFallback');
    final currentEmail = authProvider.user?.email ?? 'admin@parking.com';
    final currentRole = authProvider.user?.role ?? 'admin';

    return AdminShell(
      currentRoute: RouteNames.adminSettings,
      title: context.t.text('settings.title'),
      subtitle: context.t.text('settings.subtitle'),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 1000;

              final profile = _AdminProfileCard(
                name: currentName,
                email: currentEmail,
                role: currentRole,
              );
              final info = _AdminInfoCard(
                themeLabel: themeProvider.themeLabel,
                languageLabel: languageProvider.languageLabel,
              );

              if (compact) {
                return Column(
                  children: [
                    profile,
                    const SizedBox(height: AppSpacing.sectionGap),
                    info,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: profile),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 4, child: info),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _SectionTitle(context.t.text('settings.systemPreferences')),
          const SizedBox(height: AppSpacing.md),
          _SettingTile(
            title: context.t.text('settings.notifications'),
            subtitle: context.t.text('settings.notificationsSubtitle'),
            value: notificationsEnabled,
            onChanged: (value) => setState(() => notificationsEnabled = value),
          ),
          _SettingTile(
            title: context.t.text('settings.autoRefresh'),
            subtitle: context.t.text('settings.autoRefreshSubtitle'),
            value: autoRefreshEnabled,
            onChanged: (value) => setState(() => autoRefreshEnabled = value),
          ),
          _SettingTile(
            title: context.t.text('settings.criticalOnly'),
            subtitle: context.t.text('settings.criticalOnlySubtitle'),
            value: criticalAlertsOnly,
            onChanged: (value) => setState(() => criticalAlertsOnly = value),
          ),
          _ActionSettingTile(
            title: context.t.text('settings.theme'),
            subtitle: context.t.text('settings.themeSubtitle'),
            value: themeProvider.themeLabel,
            icon: Icons.palette_outlined,
            onTap: () => _showThemeSelector(context),
          ),
          _ActionSettingTile(
            title: context.t.text('settings.language'),
            subtitle: context.t.text('settings.languageSubtitle'),
            value: languageProvider.languageLabel,
            icon: Icons.language_rounded,
            onTap: () => _showLanguageSelector(context),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _SectionTitle(context.t.text('settings.adminManagement')),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.person_add_alt_1_rounded,
                  title: context.t.text('settings.addAdmin'),
                  subtitle: context.t.text('settings.addAdminSubtitle'),
                  onTap: () => _showAddAdminDialog(context),
                ),
                Divider(color: colors.border),
                _ActionRow(
                  icon: Icons.switch_account_rounded,
                  title: context.t.text('settings.switchAccount'),
                  subtitle: context.t.text('settings.switchAccountSubtitle'),
                  onTap: () => _showAccountModeSelector(context),
                ),
                Divider(color: colors.border),
                _ActionRow(
                  icon: Icons.lock_reset_rounded,
                  title: context.t.text('settings.security'),
                  subtitle: context.t.text('settings.securitySubtitle'),
                  onTap: () => _showSecurityDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(AppRadius.xxl),
              border: Border.all(
                color: colors.danger.withValues(alpha: 0.24),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.text('settings.logout'),
                        style: AppTextStyles.cardTitle.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        context.t.text('settings.logoutSubtitle'),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(context.t.text('settings.logoutButton')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(180, 52),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sectionTitle.copyWith(
        color: context.appColors.textPrimary,
      ),
    );
  }
}

class _AdminProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String role;

  const _AdminProfileCard({
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;
    final initials = _buildInitials(name);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _ProfileBadge(
                      label: _buildRoleLabel(context, role),
                      color: primary,
                    ),
                    _ProfileBadge(
                      label: context.t.text('settings.systemActive'),
                      color: colors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _buildInitials(String value) {
    final parts = value.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'AD';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  static String _buildRoleLabel(BuildContext context, String role) {
    final normalized = role.toLowerCase();
    if (normalized == 'admin') return context.t.text('settings.roleSuperAdmin');
    if (normalized == 'client') return context.t.text('settings.roleClient');
    return role;
  }
}

class _AdminInfoCard extends StatelessWidget {
  final String themeLabel;
  final String languageLabel;

  const _AdminInfoCard({
    required this.themeLabel,
    required this.languageLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.text('settings.systemInfo'),
            style: AppTextStyles.cardTitle.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoItem(label: context.t.text('settings.version'), value: '2.0.1'),
          _InfoItem(label: context.t.text('settings.environment'), value: context.t.text('settings.production')),
          _InfoItem(label: context.t.text('settings.theme'), value: themeLabel),
          _InfoItem(label: context.t.text('settings.language'), value: languageLabel),
          _InfoItem(label: context.t.text('settings.module'), value: context.t.text('settings.roleSuperAdmin')),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ProfileBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: colors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _ActionSettingTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionSettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: primary),
        ),
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.12) : colors.card,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: selected ? primary : colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? primary : colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _DialogTextField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
