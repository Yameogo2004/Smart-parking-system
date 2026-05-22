import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../../../data/services/api_service.dart';

enum ClientPaymentMethod {
  card,
  cash,
  appMoney,
}

class PaymentScreen extends StatefulWidget {
  final double montant;
  final int reservationId;
  final String reservationCode;

  const PaymentScreen({
    super.key,
    required this.montant,
    required this.reservationId,
    required this.reservationCode,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ClientPaymentMethod _selectedMethod = ClientPaymentMethod.card;
  bool _isLoading = false;
  bool _paymentSuccess = false;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();
  String _selectedAppMoneyProvider = 'Orange Money';

  final List<String> _appMoneyProviders = const [
    'Orange Money',
    'Wave',
    'Free Money',
    'Express Union',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 16) {
      cleaned = cleaned.substring(0, 16);
    }

    final groups = <String>[];
    for (int i = 0; i < cleaned.length; i += 4) {
      final end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
      groups.add(cleaned.substring(i, end));
    }

    return groups.join(' ');
  }

  String _formatExpiry(String value) {
    String cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length > 4) {
      cleaned = cleaned.substring(0, 4);
    }

    if (cleaned.length >= 3) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }

    return cleaned;
  }

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final paymentData = <String, dynamic>{
        'montant': widget.montant,
        'reservation_id': widget.reservationId,
        'reservation_code': widget.reservationCode,
        'payment_method': _selectedMethod.name,
      };

      if (_selectedMethod == ClientPaymentMethod.card) {
        if (_cardNumberController.text.replaceAll(' ', '').length < 16) {
          throw Exception('Numéro de carte invalide');
        }
        if (_expiryController.text.length < 5) {
          throw Exception('Date d’expiration invalide');
        }
        if (_cvvController.text.length < 3) {
          throw Exception('CVV invalide');
        }
        if (_cardHolderController.text.trim().isEmpty) {
          throw Exception('Nom du titulaire requis');
        }

        paymentData['card_details'] = {
          'card_number': _cardNumberController.text.replaceAll(' ', ''),
          'expiry_date': _expiryController.text,
          'cvv': _cvvController.text,
          'card_holder': _cardHolderController.text.trim(),
        };
      } else if (_selectedMethod == ClientPaymentMethod.appMoney) {
        if (_phoneNumberController.text.trim().length < 9) {
          throw Exception('Numéro de téléphone invalide');
        }

        paymentData['app_money_details'] = {
          'provider': _selectedAppMoneyProvider,
          'phone_number': _phoneNumberController.text.trim(),
        };
      } else if (_selectedMethod == ClientPaymentMethod.cash) {
        paymentData['cash_details'] = {
          'message': 'Paiement à effectuer à la sortie',
        };
      }

      final response = await ApiService.post('/api/payment/process', paymentData);

      if (response['success'] == true) {
        if (!mounted) return;

        setState(() {
          _paymentSuccess = true;
          _isLoading = false;
        });

        _showSuccessDialog();
      } else {
        throw Exception(response['message'] ?? 'Paiement échoué');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      _showErrorDialog(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              SizedBox(height: 10),
              Text('Paiement réussi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Montant payé : ${widget.montant.toStringAsFixed(2)} DH'),
              const SizedBox(height: 8),
              Text('Code réservation : ${widget.reservationCode}'),
              const SizedBox(height: 14),
              const Text(
                'Un reçu a été enregistré pour cette opération.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Text('Erreur de paiement'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Paiement'),
        centerTitle: true,
      ),
      body: _paymentSuccess
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 18),
                    Text(
                      'Paiement effectué avec succès',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Montant : ${widget.montant.toStringAsFixed(2)} DH',
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Terminer'),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAmountCard(context),
                  const SizedBox(height: 24),
                  Text(
                    'Méthode de paiement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentMethodTile(
                    context,
                    method: ClientPaymentMethod.card,
                    title: 'Carte bancaire',
                    icon: Icons.credit_card,
                    color: Colors.blue,
                  ),
                  _buildPaymentMethodTile(
                    context,
                    method: ClientPaymentMethod.appMoney,
                    title: 'App Money',
                    icon: Icons.phone_android,
                    color: Colors.orange,
                  ),
                  _buildPaymentMethodTile(
                    context,
                    method: ClientPaymentMethod.cash,
                    title: 'Espèces',
                    icon: Icons.payments_outlined,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  if (_selectedMethod == ClientPaymentMethod.card)
                    _buildCardForm(context),
                  if (_selectedMethod == ClientPaymentMethod.appMoney)
                    _buildAppMoneyForm(context),
                  if (_selectedMethod == ClientPaymentMethod.cash)
                    _buildCashForm(context),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Payer'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAmountCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.80),
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
            'MONTANT À PAYER',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.montant.toStringAsFixed(2)} DH',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Code réservation : ${widget.reservationCode}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context, {
    required ClientPaymentMethod method,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    final colors = context.appColors;
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.10) : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : colors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm(BuildContext context) {
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
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: const InputDecoration(
              labelText: 'Numéro de carte',
              hintText: '1234 5678 9012 3456',
              prefixIcon: Icon(Icons.credit_card),
            ),
            onChanged: (value) {
              final formatted = _formatCardNumber(value);
              if (formatted != _cardNumberController.text) {
                _cardNumberController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    labelText: 'MM/AA',
                    hintText: '12/25',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  onChanged: (value) {
                    final formatted = _formatExpiry(value);
                    if (formatted != _expiryController.text) {
                      _expiryController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 3,
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Titulaire de la carte',
              hintText: 'Jean DUPONT',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppMoneyForm(BuildContext context) {
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
          DropdownButtonFormField<String>(
            value: _selectedAppMoneyProvider,
            decoration: const InputDecoration(
              labelText: 'Opérateur',
            ),
            items: _appMoneyProviders.map((provider) {
              return DropdownMenuItem<String>(
                value: provider,
                child: Text(provider),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _selectedAppMoneyProvider = value;
              });
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneNumberController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              hintText: '77 123 45 67',
              prefixIcon: Icon(Icons.phone_android),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Une confirmation sera demandée sur votre téléphone.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashForm(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Vous pourrez payer en espèces au terminal de sortie.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
