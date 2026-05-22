import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_radius.dart';

/// Widget qui affiche une plaque d'immatriculation marocaine
/// correctement — chiffres | lettre arabe | chiffres — en LTR
/// Exemple : 44871ب12  ou  69538أ26
class PlaqueMarocaine extends StatelessWidget {
  final String matricule;
  final double fontSize;
  final bool showBorder;

  const PlaqueMarocaine({
    super.key,
    required this.matricule,
    this.fontSize = 15,
    this.showBorder = false,
  });

  /// Sépare la plaque en 3 parties : chiffres gauche / lettre / chiffres droite
  List<String> _parsePlaque(String m) {
    // Pattern : une ou plusieurs lettres arabes au milieu
    final regex = RegExp(r'^(\d+)([^\d]+)(\d+)$');
    final match = regex.firstMatch(m.trim());
    if (match != null) {
      return [match.group(1)!, match.group(2)!, match.group(3)!];
    }
    return [m, '', ''];
  }

  @override
  Widget build(BuildContext context) {
    final parts = _parsePlaque(matricule);
    final chiffresGauche = parts[0];
    final lettre = parts[1];
    final chiffresDroite = parts[2];

    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
      color: AppColors.textPrimary,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chiffres gauche — LTR
        Text(chiffresGauche, style: style),
        if (lettre.isNotEmpty) ...[
          const SizedBox(width: 4),
          // Séparateur gauche
          Text('|',
              style: style.copyWith(
                  color: AppColors.textMuted, fontWeight: FontWeight.w300)),
          const SizedBox(width: 4),
          // Lettre arabe — RTL isolé
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(lettre,
                style: style.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 4),
          // Séparateur droit
          Text('|',
              style: style.copyWith(
                  color: AppColors.textMuted, fontWeight: FontWeight.w300)),
          const SizedBox(width: 4),
          // Chiffres droite — LTR
          Text(chiffresDroite, style: style),
        ],
      ],
    );

    if (showBorder) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: content,
      );
    }

    return content;
  }
}
