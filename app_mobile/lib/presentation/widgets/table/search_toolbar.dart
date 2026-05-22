import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

class SearchToolbar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Widget? trailing;
  final TextEditingController? controller;

  const SearchToolbar({
    super.key,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.trailing,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
      ),
    );

    if (trailing == null) {
      return searchField;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            children: [
              searchField,
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: trailing!,
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              flex: 3,
              child: searchField,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 4,
              child: Align(
                alignment: Alignment.centerLeft,
                child: trailing!,
              ),
            ),
          ],
        );
      },
    );
  }
}
