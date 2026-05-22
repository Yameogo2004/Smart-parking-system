import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/services/api_service.dart';
import '../../../widgets/buttons/custom_button.dart';

class LocateVehicleScreen extends StatefulWidget {
  const LocateVehicleScreen({super.key});

  @override
  State<LocateVehicleScreen> createState() => _LocateVehicleScreenState();
}

class _LocateVehicleScreenState extends State<LocateVehicleScreen> {
  final TextEditingController _plaqueController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _plaqueController.dispose();
    super.dispose();
  }

  Future<void> _localiser() async {
    if (_plaqueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une plaque')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final response = await ApiService.get(
        '/api/vehicule/${_plaqueController.text.trim()}/localisation',
      );

      if (!mounted) return;
      setState(() {
        _result = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Localiser mon véhicule'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.location_searching,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Entrez votre plaque d’immatriculation',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _plaqueController,
                    decoration: InputDecoration(
                      labelText: 'Plaque',
                      prefixIcon: const Icon(Icons.directions_car),
                      hintText: 'AB-123-CD',
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    label: 'Localiser',
                    onPressed: _localiser,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null) _buildResultCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final colors = context.appColors;
    final found = _result!['trouve'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: found ? colors.success.withValues(alpha: 0.40) : colors.warning,
        ),
      ),
      child: Column(
        children: [
          Icon(
            found ? Icons.check_circle : Icons.info_outline,
            size: 50,
            color: found ? colors.success : colors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            _result!['message'] ?? (found ? 'Véhicule trouvé' : 'Aucune donnée'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (found) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(
                    'Niveau ${_result!['niveau']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Place ${_result!['place']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
