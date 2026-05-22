import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../providers/language_provider.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final colors = context.appColors;

    final languages = [
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    ];

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Langue'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = languageProvider.languageCode == lang['code'];

          return GestureDetector(
            onTap: () {
              languageProvider.setByCode(lang['code']!);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : colors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    lang['flag']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lang['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
