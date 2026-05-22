import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/services/api_service.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/fields/custom_text_field.dart';
import 'reservation_history_screen.dart';

class ReservationFormScreen extends StatefulWidget {
  const ReservationFormScreen({super.key});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  final TextEditingController _plaqueController = TextEditingController();
  final TextEditingController _modeleController = TextEditingController();
  final TextEditingController _chargeController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  DateTime _dateDebut = DateTime.now().add(const Duration(hours: 1));
  DateTime _dateFin = DateTime.now().add(const Duration(hours: 3));
  double _chargeSupplementaire = 0;
  bool _isLoading = false;

  Position? _currentPosition;
  double _distanceParking = 0;
  int _tempsTrajet = 0;
  bool _isLoadingLocation = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _prefillUserData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _plaqueController.dispose();
    _modeleController.dispose();
    _chargeController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _prefillUserData() async {
    try {
      final response = await ApiService.get('/api/auth/me');
      final user = response['user'];

      if (user == null || !mounted) return;

      setState(() {
        _nomController.text = (user['nom'] ?? '').toString();
        _prenomController.text = (user['prenom'] ?? '').toString();
        _emailController.text = (user['email'] ?? '').toString();
        _telephoneController.text = (user['telephone'] ?? '').toString();
      });
    } catch (_) {
      // pas bloquant
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      await _calculerDistanceEtTemps();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _calculerDistanceEtTemps() async {
    if (_currentPosition == null) return;

    const double parkingLat = 35.5889;
    const double parkingLng = -5.3626;

    final distance = _calculerDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      parkingLat,
      parkingLng,
    );

    final temps = (distance / 35 * 60).round();

    if (!mounted) return;
    setState(() {
      _distanceParking = distance;
      _tempsTrajet = temps;
    });
  }

  double _calculerDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double r = 6371;

    final double radLat1 = lat1 * math.pi / 180;
    final double radLat2 = lat2 * math.pi / 180;
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLng = (lng2 - lng1) * math.pi / 180;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radLat1) *
            math.cos(radLat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  double _calculerMontant() {
    final dureeMinutes = _dateFin.difference(_dateDebut).inMinutes;
    final dureeHeures = dureeMinutes / 60;
    final prixBase = dureeHeures * 2.50;
    final prixCharge = _chargeSupplementaire * 0.10;
    return prixBase + prixCharge;
  }

  Future<void> _creerReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateFin.isBefore(_dateDebut) ||
        _dateFin.isAtSameMomentAs(_dateDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La date de fin doit être après la date de début.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reservationData = {
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'email': _emailController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        'plaque': _plaqueController.text.trim().toUpperCase(),
        'modele': _modeleController.text.trim(),
        'charge_supplementaire': _chargeSupplementaire,
        'date_debut': _dateDebut.toIso8601String(),
        'date_fin': _dateFin.toIso8601String(),
        'latitude': _currentPosition?.latitude,
        'longitude': _currentPosition?.longitude,
        'distance': _distanceParking,
        'temps_trajet': _tempsTrajet,
      };

      final response = await ApiService.post('/api/reservation', reservationData);

      if (!mounted) return;

      final paymentResult = await Navigator.pushNamed(
        context,
        RouteNames.clientPayment,
        arguments: {
          'montant': _calculerMontant(),
          'reservationId': response['reservation_id'] ?? 0,
          'reservationCode': response['code_confirmation'] ?? '',
        },
      );

      if (!mounted) return;

      if (paymentResult == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation confirmée et paiement effectué.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation créée, paiement en attente.'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Réservation'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.edit_calendar_outlined),
                text: 'Nouvelle',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Historique',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildReservationForm(context),
            ),
            const ReservationHistoryScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationForm(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildLocationCard(context),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Informations personnelles',
              Icons.person_outline,
            ),
            const SizedBox(height: 12),
            _buildPersonalInfoForm(context),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Informations véhicule',
              Icons.directions_car_outlined,
            ),
            const SizedBox(height: 12),
            _buildVehicleInfoForm(context),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Date et heure',
              Icons.calendar_today_outlined,
            ),
            const SizedBox(height: 12),
            _buildDateTimePicker(context),
            const SizedBox(height: 20),
            _buildSectionTitle(
              context,
              'Charge supplémentaire',
              Icons.fitness_center_outlined,
            ),
            const SizedBox(height: 12),
            _buildChargeSlider(context),
            const SizedBox(height: 20),
            _buildSummaryCard(context),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Confirmer la réservation',
              onPressed: _creerReservation,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Distance du parking',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                if (_isLoadingLocation)
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${_distanceParking.toStringAsFixed(1)} km • $_tempsTrajet min',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.directions_car_outlined,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _nomController,
                  label: 'Nom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _prenomController,
                  label: 'Prénom',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Champ requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _telephoneController,
            label: 'Téléphone',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Champ requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoForm(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: _plaqueController,
            label: 'Plaque d’immatriculation',
            prefixIcon: Icons.badge_outlined,
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Champ requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _modeleController,
            label: 'Modèle du véhicule',
            prefixIcon: Icons.directions_car_outlined,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Champ requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _chargeController,
            label: 'Charge supplémentaire (kg)',
            prefixIcon: Icons.fitness_center_outlined,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _chargeSupplementaire = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Début'),
            subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateDebut)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateDebut,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );

              if (date == null || !mounted) return;

              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_dateDebut),
              );

              if (time == null || !mounted) return;

              setState(() {
                _dateDebut = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );

                if (!_dateFin.isAfter(_dateDebut)) {
                  _dateFin = _dateDebut.add(const Duration(hours: 2));
                }
              });

              _calculerDistanceEtTemps();
            },
          ),
          Divider(color: colors.border),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_outlined),
            title: const Text('Fin'),
            subtitle: Text(DateFormat('dd/MM/yyyy à HH:mm').format(_dateFin)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _dateFin,
                firstDate: _dateDebut,
                lastDate: _dateDebut.add(const Duration(days: 7)),
              );

              if (date == null || !mounted) return;

              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_dateFin),
              );

              if (time == null || !mounted) return;

              setState(() {
                _dateFin = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  time.hour,
                  time.minute,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChargeSlider(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Charge supplémentaire',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '${_chargeSupplementaire.toStringAsFixed(0)} kg',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: _chargeSupplementaire,
            min: 0,
            max: 500,
            divisions: 10,
            label: '${_chargeSupplementaire.toStringAsFixed(0)} kg',
            onChanged: (value) {
              setState(() {
                _chargeSupplementaire = value;
                _chargeController.text = value.toStringAsFixed(0);
              });
            },
          ),
          Text(
            'Frais supplémentaires: +${(_chargeSupplementaire * 0.10).toStringAsFixed(2)} DH',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final dureeMinutes = _dateFin.difference(_dateDebut).inMinutes;
    final dureeHeures = dureeMinutes / 60;
    final montantBase = dureeHeures * 2.50;
    final montantCharge = _chargeSupplementaire * 0.10;
    final montantTotal = montantBase + montantCharge;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.78),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RÉCAPITULATIF',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow('Durée', '${dureeHeures.toStringAsFixed(1)} h'),
          const SizedBox(height: 8),
          _summaryRow('Tarif horaire', '2.50 DH / h'),
          const SizedBox(height: 8),
          _summaryRow('Montant base', '${montantBase.toStringAsFixed(2)} DH'),
          if (_chargeSupplementaire > 0) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Charge supp.',
              '+${montantCharge.toStringAsFixed(2)} DH',
            ),
          ],
          const Divider(color: Colors.white30, height: 24),
          _summaryRow(
            'TOTAL',
            '${montantTotal.toStringAsFixed(2)} DH',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            fontSize: isBold ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
