import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Comment réserver une place ?',
        'a':
            'Depuis l’écran principal, utilisez le bouton de réservation puis remplissez les informations demandées.'
      },
      {
        'q': 'Comment retrouver mon véhicule ?',
        'a':
            'Utilisez l’option de localisation en entrant votre plaque ou en consultant votre stationnement actif.'
      },
      {
        'q': 'Comment sortir du parking ?',
        'a':
            'Présentez votre QR code ou votre ticket RFID au terminal de sortie.'
      },
      {
        'q': 'Que faire si une erreur apparaît ?',
        'a':
            'Vérifiez votre connexion internet ou contactez l’administrateur du parking.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          const Text(
            'Questions fréquentes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...faqs.map(
            (faq) => Card(
              child: ExpansionTile(
                title: Text(faq['q']!),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      16,
                    ),
                    child: Text(faq['a']!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
